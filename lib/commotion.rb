require "commotion/version"
require "logger"

module Commotion

  autoload :Action,           "commotion/action"
  autoload :Configuration,    "commotion/configuration"
  autoload :Job,              "commotion/job"
  autoload :Scheduler,        "commotion/scheduler"

  class << self
    def logger=(l)
      @logger = l
    end
    def logger
      @logger ||= begin
        Logger.new("log/commotion.log", 1, 1024*1024).tap do |l|
          l.formatter = ->(severity, datetime, program, message) {
            Kernel.format "%10.8f [%-10s] %s\n", Time.now.to_f, Thread.current.to_s, message.to_s
          }
        end
      end
    end
  end

end # Commotion
