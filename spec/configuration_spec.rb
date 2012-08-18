require "helper"
require "logger"
require "stringio"

class NullJob < Commotion::Job
end

describe Commotion::Configuration do
  it "can be configured" do
    output = StringIO.new
    c = Commotion::Configuration.new.tap do |context|
      context.instance_eval do
        logger Logger.new(output)
        after_fork() { puts "Forked!" }
        workers 10
        schedule NullJob
      end
    end

    c.logger.info "Hello, world!"
    output.seek(0)
    output.read.should include("Hello, world!\n")

    c.workers.should eq(10)
    c.jobs.should eq([NullJob])
  end
end
