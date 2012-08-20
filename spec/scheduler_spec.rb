require "helper"
require "timecop"

class ScheduledJob < Commotion::Job
  class << self
    attr_accessor :performances
  end
  def perform
    self.class.performances += 1
  end
end

describe Commotion::Scheduler, storage: true do

  let(:now) { Time.parse "2001-01-01 08:00:00 -0800" }
  before(:each) { Timecop.freeze(now) }

  let(:bad_configuration) do
    Commotion::Configuration.new.tap do |context|
      context.instance_eval do
        workers 2
        schedule ScheduledJob
        schedule "SomethingElse"
      end
    end
  end

  let(:configuration) do
    Commotion::Configuration.new.tap do |context|
      context.instance_eval do
        workers 2
        schedule ScheduledJob
      end
    end
  end

  let(:scheduler) { Commotion::Scheduler.new(configuration) }

  describe "configuration" do
    it "requires correctly-specified jobs" do
      expect { Commotion::Scheduler.new(bad_configuration) }.to raise_exception
      expect { Commotion::Scheduler.new(configuration) }.to_not raise_exception
      s = Commotion::Scheduler.new(configuration)
      expect { s.schedule ScheduledJob, id: 1, at: Time.now }.to_not raise_exception
      expect { s.schedule "ScheduledJob", id: 2, at: Time.now }.to_not raise_exception
    end
  end

  it "finds ready jobs and runs them" do
    ScheduledJob.performances = 0
    s = Commotion::Scheduler.new( configuration )
    s.schedule ScheduledJob, id: 1, at: Time.now
    s.schedule ScheduledJob, id: 2, at: Time.now
    s.run
    s.wait
    ScheduledJob.performances.should eq(2)
  end

  it "determines when the next job will run" do
    scheduler.schedule ScheduledJob, id: 1, at: now + 10
    scheduler.schedule ScheduledJob, id: 2, at: now + 11
    scheduler.__send__(:next_before,now+20).should eq(now + 10)
    Timecop.freeze(10)
    scheduler.__send__(:next_before,now+20).should eq(Time.now)
  end

  it "runs multiple small tasks at once" do
    ScheduledJob.performances = 0
    s = Commotion::Scheduler.new( configuration )
    s.schedule ScheduledJob, id: 1, at: Time.now
    s.schedule ScheduledJob, id: 2, at: Time.now
    s.run
    s.wait
    ScheduledJob.performances.should eq(2)
  end

  it "finds expired jobs and clears them" do
    scheduler.schedule ScheduledJob, id: 1, at: Time.now, locked: Time.now - 1
    scheduler.run
  end

  it "runs jobs with a lock"

end
