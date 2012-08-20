require "commotion/version"
require "logger"

module Commotion

  autoload :Action,           "commotion/action"
  autoload :Configuration,    "commotion/configuration"
  autoload :Job,              "commotion/job"
  autoload :Scheduler,        "commotion/scheduler"

  module Concurrent
    autoload :BlockingQueue,  "commotion/concurrent/blocking_queue"
    autoload :HandoffQueue,   "commotion/concurrent/handoff_queue"
    autoload :Stepper,        "commotion/concurrent/stepper"
    autoload :ThreadPool,     "commotion/concurrent/thread_pool"
  end

  module Configurable
    def configuration=(c)
      @configuration = c
    end
    def configuration
      @configuration ||= Configuration.new
    end
  end

  module Loggable
    def logger=(l)
      @logger = l
    end
    def logger
      @logger ||= begin
        ::Logger.new("log/commotion.log", 1, 1024*1024).tap do |l|
          l.formatter = ->(severity, datetime, program, message) {
            Kernel.format "%10.8f [%-10s] %s\n", Time.now.to_f, Thread.current.to_s, message.to_s
          }
        end
      end
    end
  end

  module Utilities
    def stringify(h)
      Hash[ h.map { |k,v| [ k.to_s, v ] } ]
    end
    def symbolize(h)
      Hash[ h.map { |k,v| [ k.to_sym, v ] } ]
    end
  end

  module DefaultedAttributes
    def self.included(base)
      self.class.send(:define_method,"accessor_with_default") do |name,&default|
        ivar = "@#{name}".to_sym
        # getter or setter
        base.send(:define_method,"#{name}".to_sym) do
          instance_variable_set(ivar,default.call) if ! instance_variable_defined?(ivar) && default
          instance_variable_get(ivar)
        end
        # setter
        base.send(:define_method,"#{name}=".to_sym) do |value|
          instance_variable_set(ivar,value)
        end
      end
    end
  end

  extend Configurable
  extend Loggable

end # Commotion
