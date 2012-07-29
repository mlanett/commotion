require "helper"

describe Commotion::Concurrent::BlockingQueue do

  subject { Commotion::Concurrent::BlockingQueue.new }

  it "can push and pop" do
    Commotion::Concurrent::Stepper.new do |s|
      s.add { subject.push :a }
      s.add { subject.push :b }
      s.add { subject.pop.should eq :a }
      s.add { subject.pop.should eq :b }
      s.add { subject.push :c }
      s.add { subject.pop.should eq :c }
    end.run
  end

  it "can pop and push" do
    Commotion::Concurrent::Stepper.new do |s|
      s.add( after: 0 ) { subject.pop.should eq :d }
      s.add( after: 1 ) { subject.pop.should eq :e }
      s.add( after: 0 ) { subject.push :d }
      s.add( after: 3 ) { subject.push :e }
    end.run
  end

  it "can push and pop a lot" do
    total = 0
    Commotion::Concurrent::Stepper.new do |s|
      s.add( after: 0 ) { (1..10).each { |i| subject.push i; sleep rand } }
      s.add( after: 0 ) { total = (1..10).inject(0) { |a,i| sleep rand; a + subject.pop } }
    end.run
    total.should eq 55
  end

  it "raises when closed to push" do
    Commotion::Concurrent::Stepper.new do |s|
      s.add { subject.close }
      s.add { expect { subject.push :a }.to raise_exception }
    end.run
  end

  it "raises when closed to pop" do
    Commotion::Concurrent::Stepper.new do |s|
      s.add( after: 0 ) { expect { subject.pop }.to raise_exception }
      s.add( after: 0 ) { subject.close }
      s.add( after: 2 ) { expect { subject.pop }.to raise_exception }
    end.run
  end

end
