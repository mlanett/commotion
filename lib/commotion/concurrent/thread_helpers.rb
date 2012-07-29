require "commotion/test/names"
require "thread"

class Thread
  def to_s
    name
  end
  include Commotion::Test::Names
  def name
    Thread.current[:name] ||= (( Thread.current == Thread.main ) ? "main" : get_name )
  end
end

class ConditionVariable
  alias_method :original_signal, :signal
  def signal
    original_signal
    #Commotion.logger.debug "Signaled #{self}"
  end
  alias_method :original_wait, :wait
  def wait( mutex )
    #Commotion.logger.debug "Waiting for #{self}"
    original_wait(mutex)
    #Commotion.logger.debug "Reached #{self}"
  end
  def to_s
    name
  end
  include Commotion::Test::Names
  def name
    @name ||= "CV:#{get_name}"
  end
  def name=(n)
    @name = n
  end
end

module Kernel
  alias_method :original_puts, :puts
  def puts(m)
    STDERR.printf "%10.8f [%-10s] %s\n", Time.now.to_f, Thread.current.to_s, m.to_s
  end
end
