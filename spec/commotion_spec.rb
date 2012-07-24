require "helper"

class A < Commotion::Job
  def process( action )
    puts "A"
  end
end

class B < Commotion::Job
  def process( action )
    puts "B"
  end
end

describe Commotion, mysql: true do

  let(:configuration) do
    Commotion::Configuration.new.tap do |dsl_context|
      dsl_context.instance_eval do
        after_fork() { puts "Forked!" }
        workers 10
        schedule A
        schedule B
      end
    end
  end

  it "should run multiple small tasks at once"
  #  s = Commotion::Scheduler.new( configuration )
  #  10.times { |i| s.schedule "a", i+1, at: Time.now + rand(10) }
  #  s.run

end
