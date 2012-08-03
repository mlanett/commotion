require "helper"

class Foo < Commotion::Job
end

describe Commotion::Scheduler, storage: true do

  subject do
    c = Commotion::Configuration.new.tap do |my|
      my.workers 2
      my.schedule Foo
    end
    Commotion::Scheduler.new(c)
  end

  #it "finds expired jobs and clears them" do
  #  now = Time.now
  #  Commotion::Action.create kind: "Foo", ref: 1, at: now - 100, lock_expiration: now - 1
  #  Commotion::Action.create kind: "Foo", ref: 2, at: now - 100, lock_expiration: now + 1
  #  Commotion::Action.create kind: "Foo", ref: 3, at: now - 100, lock_expiration: now
  #  Commotion::Action.create kind: "Foo", ref: 4, at: now - 100, lock_expiration: now - 10
  #  subject.clear_stale_actions(now)
  #  Commotion::Action.ready(now).count.should eq 3
  #end

  it "should run multiple small tasks at once"

end
