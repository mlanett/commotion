require "helper"

class A < Commotion::Job
  def process( action )
  end
end

class B < Commotion::Job
  def process( action )
  end
end

describe Commotion, storage: true do

end
