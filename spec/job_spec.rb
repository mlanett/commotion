require "helper"

class A < Commotion::Job
end

class B < Commotion::Job
end

describe Commotion::Job do

  it "can be performed" do
    job = A.new(nil)
    expect { job.perform(:a) }.to_not raise_error
  end

  describe "when finding actions", mysql: true do

    it "can find ready actions" do
      Commotion::Action.create kind: "B", ref: 1, at: Time.now - 30
      Commotion::Action.create kind: "A", ref: 1, at: Time.now - 10
      Commotion::Action.create kind: "A", ref: 2, at: Time.now - 30
      Commotion::Action.create kind: "A", ref: 3, at: Time.now + 10
      A.ready.size.should eq(2)
    end

    it "can find stale actions"
    it "can find an upcoming actions"

  end

end
