require "helper"

class A < Commotion::Job
  def perform( action )
  end
end

class B < Commotion::Job
  key "id", "area"
  def perform( action )
  end
end

describe Commotion::Job do

  let(:now) { Time.now }
  let(:b4) { now - 1 }

  describe "when it is not specifically configured" do
    it "has a default configuration" do
      A.configuration.should_not be_nil
    end
  end

  it "can have custom keys" do
    A.key.should == [ "id" ]
    B.key.should == [ "id", "area" ]
  end

  it "can be performed" do
    job = A.new(nil)
    expect { job.perform(:a) }.to_not raise_error
  end

  describe "when storing actions", storage: true do

    it "can be scheduled" do
      expect { A.schedule id: 123 }.to raise_exception

      A.schedule id: 123, at: b4
      A.configuration.mongo.find({ kind: "A" }).count.should == 1
      A.configuration.mongo.find({ kind: "A" }).first.should include( "id" => 123 )

      expect { B.schedule id: 42, at: b4 }.to raise_exception

      B.schedule area: 52, id: 42, at: b4
      B.configuration.mongo.find({ kind: "B" }).first.should include( "area" => 52, "id" => 42 )
    end

    it "can be rescheduled; it can not be scheduled twice" do
      B.schedule id: 123, at: b4, area: 12
      B.configuration.mongo.find({ kind: "B" }).count.should == 1

      B.schedule id: 123, at: b4, area: 12
      B.configuration.mongo.find({ kind: "B" }).count.should == 1
    end

    it "can have multiple entries" do
      B.schedule id: 123, at: b4, area: 12
      B.configuration.mongo.find({ kind: "B" }).count.should == 1

      B.schedule id: 123, at: b4, area: 11
      B.configuration.mongo.find({ kind: "B" }).count.should == 2
    end

    it "can have non-key data" do
      A.schedule id: 123, at: b4, plus: "stuff"
      A.configuration.mongo.find({ kind: "A" }).first.should include( "plus" => "stuff" )
    end

  end

  describe "when finding actions", storage: true do

    before do
      A.schedule id: 1, at: now - 10
      A.schedule id: 2, at: now - 30
      A.schedule id: 3, at: now - 20
      A.schedule id: 4, at: now + 10

      B.schedule id: 1, area: 27, at: now - 30
      B.schedule id: 1, area: 52, at: now - 30
      B.schedule id: 2, area: 52, at: now - 10
      B.schedule id: 3, area: 52, at: now + 10
    end

    it "can find ready actions" do
      A.ready.size.should eq 3
      B.ready.size.should eq 3
    end

    it "finds the oldest action which is ready to run" do
      A.ready.first.id.should eq 2
    end

    it "can find stale actions"
    it "can find an upcoming actions"

  end

end
