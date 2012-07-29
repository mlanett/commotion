require "commotion"
require "thread"

=begin
  A handoff queue is always empty.
  Attempting to push or pop it will block until a different thread pops or pushes it.
=end
class Commotion::Concurrent::HandoffQueue

  def initialize( options = nil )
    @name     = options && options[:name] || object_id.to_s
    @mutex    = Mutex.new
    @holding  = ConditionVariable.new.tap { |i| i.name = "#{self}/CV:holding" if i.respond_to? :name= }
    @empty    = ConditionVariable.new.tap { |i| i.name = "#{self}/CV:empty" if i.respond_to? :name= }
    @state    = :empty
    @it       = nil
    @closed   = false
  end

  def push( it )
    @mutex.synchronize do

      loop do
        raise Closed if @closed
        break if @state == :empty
        @empty.wait(@mutex)
      end
      

      @it = it
      @state = :holding
      @holding.signal
      #Commotion.logger.debug "Pushed #{it}"

      @empty.wait(@mutex) until @closed || @state == :empty
    end
  end

  def pop
    @mutex.synchronize do

      loop do
        raise Closed if @closed
        break if @state == :holding
        @holding.wait(@mutex)
      end

      it  = @it
      @it = nil
      @state = :empty
      @empty.signal

      #Commotion.logger.debug "Popped #{it}"
      it
    end
  end

  def close
    @mutex.synchronize do
      @closed = true
      @holding.broadcast
      @empty.broadcast
    end
  end

  class Closed < StandardError
  end

  def to_s
    @state == :holding ? "Q(#{name},#{@it})" : "Q(#{name})"
  end

  protected

  def name
    @name
  end

end
