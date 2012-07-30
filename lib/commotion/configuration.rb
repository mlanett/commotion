require "commotion"
require "logger"

=begin

Configuration dsl:

c = Commotion::Configuration.new.evaluate ...

  after_fork() { puts "Forked!" }
  workers 10
  schedule A
  schedule B

=end

class Commotion::Configuration

  attr :jobs
  # :after_forks
  # :logger
  # :workers

  def initialize
    @after_forks = []
    @jobs        = []
    @logger      = Logger.new(STDERR)
    @workers     = 10
  end

  # Simple DSL

  def after_fork(&block)
    @after_forks << block
  end

  def logger(l=nil)
    if l then
      @logger = l
    else
      @logger
    end
  end

  def schedule( job )
    @jobs << job
  end

  def workers(n=nil)
    if n then
      @workers = n
    else
      @workers
    end
  end

end
