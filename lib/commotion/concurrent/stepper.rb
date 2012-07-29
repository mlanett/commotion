require "commotion"

class Commotion::Concurrent::Stepper

  def initialize( &block )
    @queue = []
    @mutex = Mutex.new
    @flags = {}
    @kick  = ConditionVariable.new.tap { |i| i.name = "Stepper/CV:kick" if i.respond_to? :name= }
    block.call(self)
  end

  def add( options = {}, &block )
    options[:after] = @queue.size if ! options[:after]
    options[:set] = @queue.size+1 if ! options[:set]
    @queue << [ block, options ]
  end

  def run
    line = 1
    threads = []
    loop do
      break if @queue.size == 0
      block, options = @queue.shift
      threads << Thread.new(line) do |line|
        Thread.current[:name] = "Line-#{line}"
        wait_flag options[:after]
        block.call
        set_flag options[:set]
      end
      line += 1
    end
    set_flag 0
    threads.each { |t| t.join }
  end

  def wait_flag( flag )
    if flag then
      @mutex.synchronize do
        loop do
          break if @flags[flag]
          @kick.wait(@mutex)
        end
      end
      #Commotion.logger.debug "Got #{flag} (after #{@kick})"
    end
  end

  def set_flag( flag )
    if flag then
      @mutex.synchronize do
        @flags[flag] = true
        @kick.broadcast
      end
      #Commotion.logger.debug "Set #{flag} (kicked #{@kick})"
    end
  end

end
