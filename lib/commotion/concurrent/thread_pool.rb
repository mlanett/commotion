require "thread"
require "commotion/helpers"

module Commotion
  class ThreadPool
    include ThreadLog

    MAX = 20

    def initialize( max = MAX )
      @max     = max
      @open    = true
      @queue   = HandoffQueue.new

      @mutex   = Mutex.new
      @threads = []
    end

    # You can only enqueue tasks if workers are available.
    # When the pool is closed, all waiting enqueues will abort.
    def enqueue( task )
      raise Closed if ! @open
      puts "Enqueuing #{task}"
      cleanup
      spawn
      @queue.push( task )
    end

    # if a task in the tasks queue, run it
    # otherwise go to sleep
    def thread_loop
      puts "Thread Starting"

      begin
        while @open do
          task = @queue.pop
          puts "Result: #{task}"
          sleep 1
        end
      rescue HandoffQueue::Closed
        puts "Normal Termination"
      rescue => x
        puts "Abnormal Exit due to #{x.inspect}"
      end

      @mutex.synchronize do
        @threads.delete( Thread.current )
      end

      puts "Thread Finished"
    end # thread_loop

    # When the pool is closed, all waiting enqueues will abort.
    # Workers in progress will be given an expiration period.
    # nice is how many seconds to wait for threads to complete; 0 = none, of course.
    def close( nice = 0 )
      @open = false
      expire = Time.now + nice

      loop do
        break if expire <= Time.now
        break if @threads.size == 0 # XXX
      end
      @queue.close
      @threads.each { |t| t.kill }
      cleanup
      puts "CLOSED"
    end

    def cleanup
      dead_list = []
      @mutex.synchronize {
        @threads.dup.each { |t|
          if ! t.alive? then
            @threads.delete(t)
            dead_list << t
          end
        }
      }
      dead_list.each { |t| puts "Thread Pool: Warning: #{t} was dead" }
    end

    def spawn
      @mutex.synchronize do
        return if @threads.size == @max
        @threads << Thread.new do # Force this thread to wait
          @mutex.synchronize {}   # until the @threads << is done.
          thread_loop
        end
      end # synchronize
      puts "Thread Pool: Spawned new thread"
    end

    class Closed < StandardError
    end

  end
end
