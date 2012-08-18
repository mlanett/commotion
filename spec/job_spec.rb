require "helper"
require "timecop"

class JobA < Commotion::Job
  def perform( action )
  end
end

class JobB < Commotion::Job
  key "id", "area"
  def perform( action )
  end
end

describe Commotion::Job do

  let(:now) { Time.now }
  let(:b4) { now - 1 }
  before(:each) { Timecop.freeze(now) }

  describe "when it is not specifically configured" do
    it "has a default configuration" do
      JobA.configuration.should_not be_nil
    end
  end

  it "can have custom keys" do
    JobA.key.should == [ "id" ]
    JobB.key.should == [ "id", "area" ]
  end

  it "can be performed" do
    job = JobA.new(nil)
    expect { job.perform(:a) }.to_not raise_error
  end

  describe "when storing actions", storage: true do

    it "can be scheduled" do
      expect { JobA.schedule id: 123 }.to raise_exception

      JobA.schedule id: 123, at: b4
      JobA.configuration.mongo.find({ kind: "JobA" }).count.should == 1
      JobA.configuration.mongo.find({ kind: "JobA" }).first.should include( "id" => 123 )

      expect { JobB.schedule id: 42, at: b4 }.to raise_exception

      JobB.schedule area: 52, id: 42, at: b4
      JobB.configuration.mongo.find({ kind: "JobB" }).first.should include( "area" => 52, "id" => 42 )
    end

    it "can be rescheduled; it can not be scheduled twice" do
      JobB.schedule id: 123, at: b4, area: 12
      JobB.configuration.mongo.find({ kind: "JobB" }).count.should == 1

      JobB.schedule id: 123, at: b4, area: 12
      JobB.configuration.mongo.find({ kind: "JobB" }).count.should == 1
    end

    it "can have multiple entries" do
      JobB.schedule id: 123, at: b4, area: 12
      JobB.configuration.mongo.find({ kind: "JobB" }).count.should == 1

      JobB.schedule id: 123, at: b4, area: 11
      JobB.configuration.mongo.find({ kind: "JobB" }).count.should == 2
    end

    it "can have non-key data" do
      JobA.schedule id: 123, at: b4, plus: "stuff"
      JobA.configuration.mongo.find({ kind: "JobA" }).first.should include( "plus" => "stuff" )
    end

  end

  describe "when finding actions", storage: true do

    before(:each) do
      JobA.schedule id: 1, at: now
      JobA.schedule id: 2, at: now - 30
      JobA.schedule id: 3, at: now - 20
      JobA.schedule id: 4, at: now + 10

      JobB.schedule id: 1, area: 27, at: now - 30
      JobB.schedule id: 1, area: 52, at: now - 30, locked: now + 4
      JobB.schedule id: 2, area: 52, at: now - 10
      JobB.schedule id: 3, area: 52, at: now + 10
      JobB.schedule id: 6, area: 27, at: now - 100, locked: now - 10
    end

    it "can find ready actions" do
      JobA.ready.size.should eq 3
      JobB.ready.size.should eq 2
    end

    it "finds the oldest action which is ready to run" do
      JobA.ready.first.id.should eq 2
    end

    it "does not find locked actions" do
      JobB.ready.size.should eq 2
    end

    it "can find stale actions" do
      JobB.stale.size.should eq 1
      JobB.stale.first.id.should eq 6
    end

    it "can find an upcoming action" do
      JobA.upcoming1.should_not be_nil
      JobA.upcoming1.id.should eq 4
    end

  end

end
