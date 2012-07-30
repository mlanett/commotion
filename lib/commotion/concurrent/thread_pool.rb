require "thread"

class Commotion::Concurrent::ThreadPool

  MAX = 20

  def initialize( options = nil )
    @logger  = options && options[:logger] || Commotion.logger
    @max     = options && options[:max] || MAX
    @name    = options && options[:name] || object_id.to_s
    @queue   = Commotion::Concurrent::HandoffQueue.new

    @mutex   = Mutex.new
    @open    = true
    @threads = []
    @threadn = 0
  end

  # You can only enqueue tasks if workers are available.
  # When the pool is closed, all waiting enqueues will abort.
  def enqueue( task )
    raise Closed if ! open?
    @logger.debug { "Enqueuing #{task}" }
    cleanup
    spawn
    @queue.push( task )
    @logger.info "Enqueued #{task}"
  end

  # When the pool is closed, all waiting enqueues will abort.
  # Workers in progress will be given an expiration period.
  # nice is how many seconds to wait for workers to complete; 0 = none, of course.
  def close( nice = 1 )
    expire = Time.now + nice
    @open = false
    @queue.close

    loop do
      break if expire <= Time.now
      break if @threads.size == 0 # XXX
    end
    @threads.each { |t| t.kill }
    cleanup
    @logger.info "#{self}: Closed"
  end

  def to_s
    open? ? "ThreadPool(#{@name})" : "ThreadPool(#{@name},CLOSED)"
  end

  protected

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
    dead_list.each { |t| @logger.warn "#{self}: Warning: #{t} was dead" }
  end

  # if a task in the tasks queue, run it
  # otherwise go to sleep
  def thread_loop
    loop do
      raise Closed if ! open?
      task = @queue.pop
      result = begin
        case task
        when Proc
          task.call
        else
          @logger.info "#{self}: Performed #{task.inspect}"
        end
      end
      @logger.info "#{self}: Performed #{task.inspect}"
    end
  end # thread_loop

  def thread_lifetime
    @logger.debug "#{self}: Thread Starting"
    yield
  rescue => x
    @logger.error "#{self}: Thread Exit due to #{x.inspect}"
  else
    @logger.debug "#{self}: Thread Finished"
  end

  def spawn
    @mutex.synchronize do
      return if @threads.size == @max
      t = Thread.new do         # Force this thread to wait
        @mutex.synchronize {}   # until the @threads << is done.
        thread_lifetime { thread_loop }
        @mutex.synchronize { @threads.delete( Thread.current ) }
      end
      @threadn += 1
      t[:name] = @threadn
      @threads << t
    end # synchronize
    @logger.debug "#{self}: Spawned new thread"
  end

  def open?
    @mutex.synchronize { @open }
  end

  class Closed < StandardError
  end

end
