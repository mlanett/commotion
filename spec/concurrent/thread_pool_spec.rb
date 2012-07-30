require "helper"

describe Commotion::Concurrent::ThreadPool do

  subject { Commotion::Concurrent::ThreadPool.new( max: 2 ) }

  it "can start and stop" do
    subject.close
  end

  it "can do simple things" do
    a = [0,0]
    subject.enqueue( ->() { a[0] = 1 } )
    subject.enqueue( ->() { a[1] = 1 } )
    subject.close(1)
    a.should eq([1,1])
  end

  it "rejects enqueue after close" do
    subject.close
    expect { subject.enqueue( "foo" ) }.to raise_exception
  end

  it "can do slow things" do
    a = [0,0]
    subject.enqueue( ->() { sleep 0.1; a[0] = 1 } )
    subject.enqueue( ->() { sleep 0.1; a[1] = 1 } )
    subject.close(1)
    a.should eq([1,1])
  end

  it "forks after threads die" do
    a = [0,0]
    subject.enqueue( ->() { raise } )
    subject.enqueue( ->() { sleep 0.1; a[0] = 1 } )
    subject.enqueue( ->() { sleep 0.1; a[1] = 1 } )
    subject.close(1)
    a.should eq([1,1])
  end

end
