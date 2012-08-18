require "helper"
include Commotion

describe Action, storage: true do

  it "can represent a collection of values" do
    a = Action.new :user => 4, "name" => "Mark"
    a.user.should eq 4
    a.name.should eq "Mark"
    expect { a.area = 52 }.to_not raise_exception
    a.area.should eq 52
  end

end
