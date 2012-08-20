require "helper"

class A < Commotion::Job
  def process( action )
  end
end

class B < Commotion::Job
  def process( action )
  end
end

class C
  include Commotion::DefaultedAttributes
  accessor_with_default(:first) { Time.now }
  accessor_with_default(:second)
end

describe Commotion, storage: true do

  it "can define atts with defaults" do
    c = C.new
    c.first.should_not be_nil
    c.second.should be_nil
    c.second = 1
    c.second.should eq 1
  end

end
