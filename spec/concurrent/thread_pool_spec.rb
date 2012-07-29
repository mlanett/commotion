require "helper"
require "commotion/thread_pool"

describe Commotion::HandoffQueue do

  subject { Commotion::HandoffQueue.new }

  #it "can accept one push and pop" do
  #  t = Thread.new { subject.push(:a) }
  #  subject.pop.should eq(:a)
  #  t.join
  #  subject.close
  #end

end

describe Commotion::ThreadPool do

  subject { Commotion::ThreadPool.new }

  #it "can start and stop" do
  #  subject.close
  #end

  it "can do simple things" do
    begin
      a = [0,0]
      subject.enqueue( ->() { a[0] = 1 } )
      subject.enqueue( ->() { a[1] = 1 } )
      subject.close(1)
      a.should eq([1,1])
    rescue => x
      STDERR.puts "Uh Oh #{x.inspect}"
      puts x.backtrace
    end
  end

end
