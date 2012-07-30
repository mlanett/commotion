require "helper"
require "logger"
require "stringio"

describe Commotion::Configuration do
  it "can be configured" do
    output = StringIO.new
    c = Commotion::Configuration.new.tap { |cc| cc.logger Logger.new(output) }
    c.logger.info "Hello, world!"
    output.seek(0)
    output.read.should include("Hello, world!\n")
  end
end
