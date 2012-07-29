require "commotion"
require "thread"

class Commotion::Concurrent::BlockingQueue

  DEFAULT_MAX = 10

  def initialize( options = nil )
    @max       = options && options[:max] || DEFAULT_MAX

    @mutex     = Mutex.new
    @non_empty = ConditionVariable.new
    @not_full  = ConditionVariable.new

    @open      = true
    @queue     = []
  end

  # blocks if the queue is full, until popped or closed
  def push( x )
    @mutex.synchronize do
      loop do
        raise Closed if ! @open
        break if @queue.size < @max
        @not_full.wait(@mutex)
      end

      @queue << x
      @non_empty.signal
    end
  end

  # blocks if the queue is empty, until pushed or closed
  def pop
    @mutex.synchronize do
      loop do
        raise Closed if ! @open
        break if @queue.size > 0
        @non_empty.wait(@mutex)
      end

      it = @queue.shift
      @not_full.signal
      it
    end
  end

  # kick off any thread which is blocked right now
  def close
    @mutex.synchronize do
      @open = false
      @non_empty.broadcast
      @not_full.broadcast
    end
  end

  class Closed < StandardError
  end

end
