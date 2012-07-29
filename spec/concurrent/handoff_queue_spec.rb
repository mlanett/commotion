require "helper"

describe Commotion::Concurrent::HandoffQueue do

  it "can push and pop, but only at the same time" do
    Commotion::Concurrent::Stepper.new do |s|
      s.add( after: 0 ) { subject.push :a }
      s.add( after: 0 ) { subject.pop.should eq :a }
      s.add( after: 2 ) { subject.close }
    end.run
  end

  it "can pop and push, but only at the same time" do
    Commotion::Concurrent::Stepper.new do |s|
      s.add( after: 0 ) { subject.pop.should eq :b }
      s.add( after: 0 ) { subject.push :b }
      s.add( after: 2 ) { subject.close }
    end.run
  end

  it "can push and pop twice" do
    Commotion::Concurrent::Stepper.new do |s|
      s.add( after: 0 ) { subject.push :a }
      s.add( after: 0 ) { subject.pop.should eq :a }
      s.add( after: 2 ) { subject.push :b }
      s.add( after: 2 ) { subject.pop.should eq :b }
      s.add( after: 4 ) { subject.close }
    end.run
  end

  it "can pop and push, twice" do
    Commotion::Concurrent::Stepper.new do |s|
      s.add( after: 0 ) { subject.pop.should eq :a }
      s.add( after: 0 ) { subject.push :a }
      s.add( after: 1 ) { subject.pop.should eq :b }
      s.add( after: 2 ) { subject.push :b }
      s.add( after: 4 ) { subject.close }
    end.run
  end

  it "can pop and push in order" do
    Commotion::Concurrent::Stepper.new do |s|
      s.add( after: 0 ) { subject.pop.should eq :e }
      s.add( after: 1 ) { subject.pop.should eq :f }
      s.add( after: 0 ) { subject.push :e }
      s.add( after: 1 ) { subject.push :f }
      s.add( after: 4 ) { subject.close }
    end.run
  end

end
