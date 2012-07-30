require "bundler/setup"
require "commotion"

p = Commotion::Concurrent::ThreadPool.new

class Concur < Struct.new :start_time, :work, :jobs, :working

  def initialize
    super( Time.now, 0, 0, 0 )
    @mutex = Mutex.new
  end

  def concur
    @mutex.synchronize { self.working += 1 }
    yield
  ensure
    @mutex.synchronize { self.working -= 1 }
  end

  def worked( time = 1.0 )
    n = 0
    @mutex.synchronize do
      self.work += time
      self.jobs += 1
      n = self.jobs
    end
    puts "Done with #{n}"
  end

  def track
    self.start_time = Time.now
    yield(self)
    elapsed = Time.now - self.start_time
    
    { elapsed: elapsed, work: self.work, jobs: self.jobs, concurrency: (self.jobs / elapsed) }
  end

end

t = Concur.new.track do |m|
  200.times.each do
    p.enqueue ->() { raise if rand < 0.1 ; m.concur { sleep(1+rand) } ; m.worked }
  end
  p.close 2
end
puts t.inspect
