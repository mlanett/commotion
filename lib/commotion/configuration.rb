require "commotion"
require "logger"
require "mongo"

=begin

Configuration dsl:

c = Commotion::Configuration.new.evaluate ...

  after_fork() { puts "Forked!" }
  workers 10
  schedule A
  schedule B

=end

class Commotion::Configuration

  DEFAULT_MONGO = {
    collection: "commotion",
    database:   "test",
    hosts:      [ "localhost:27017" ],
    safe:       true
  }

  attr :jobs
  # :after_forks
  # :logger
  # :mongo
  # :workers

  def initialize
    @after_forks = []
    @jobs        = []
    @logger      = Logger.new("/tmp/scheduler.log", 1, 65536)
    @workers     = 10
  end

  # Simple DSL

  def after_fork(&block)
    @after_forks << block
  end

  def logger(l=nil)
    l and @logger = l or @logger
  end

  def mongo(m=nil)
    if m then
      # normalize input type (strings; don't symbolize uncontrolled input)
      # create a db connection
      m      = Hash[ m.map { |k,v| [ k.to_s, v ] } ]
      h, p   = m["hosts"] ? m["hosts"].sample.split(":") : [ "localhost", 27017 ]
      d, s   = m["database"] || "test", !! m["safe"]
      c      = m["collection"] || "schedule"
      @mongo = Mongo::Connection.new( h, p, safe: s ).db( d ).collection( c )
    else
      @mongo ||= mongo( DEFAULT_MONGO )
    end
  end

  def schedule( job )
    @jobs << job
  end

  def workers(n=nil)
    n and @workers = n or @workers
  end

  def jobs
    @jobs.dup
  end

end
