require "helper"

require "commotion"
require "commotion/concurrent/stepper"

describe Commotion::Concurrent::Stepper do

  it "can advance line by line" do
    at = 0
    Commotion::Concurrent::Stepper.new do |s|
      s.add { at.should eq(0) ; at = 1 }
      s.add { at.should eq(1) ; at = 2 }
      s.add { at.should eq(2) ; at = 3 }
      s.add { at.should eq(3) ; at = 4 }
      s.add { at.should eq(4) ; at = 5 }
      s.add { at.should eq(5) ; at = 6 }
      s.add { at.should eq(6) ; at = 7 }
      s.add { at.should eq(7) ; at = 8 }
      s.add { at.should eq(8) ; at = 9 }
    end.run
    at.should eq(9)
  end

  it "can advance with more flexible dependencies"

end
