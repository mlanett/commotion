require "commotion"

class Commotion::Job

  # Classes are used when scheduling jobs

  class << self

    def kind
      self.name
    end

    def ready( t = Time.now )
      Commotion::Action.kind(kind).ready
    end

    def stale( t = Time.now )
      Commotion::Action.kind(kind).stale
    end

    def upcoming1( t = Time.now )
      Commotion::Action.kind(kind).upcoming1.first
    end

  end # class

  # Instances are used when processing jobs

  attr :scheduler

  def initialize( scheduler )
    @scheduler = scheduler
  end

  def perform( action )
    puts action.to_s
  end

end
