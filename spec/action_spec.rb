require "helper"

describe Commotion::Action, mysql: true do

  it "finds the oldest one which needs to run" do
    Commotion::Action.create kind: "bar", ref: 1, at: Time.now - 30
    Commotion::Action.create kind: "foo", ref: 1, at: Time.now - 10
    Commotion::Action.create kind: "foo", ref: 2, at: Time.now - 30
    Commotion::Action.create kind: "foo", ref: 3, at: Time.now - 20
    Commotion::Action.kind("foo").ready.first.ref.should eq(2)
  end

  it "can be locked"

end
