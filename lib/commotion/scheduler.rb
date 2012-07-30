require "commotion"

class Commotion::Scheduler

  BATCH = 20

  attr :configuration

  def initialize( configuration )
    @configuration = configuration
    @running       = []
  end

  def perform( job, action )
    # wait until we can get a process
    # fork
    # run it
    job.new( self ).perform( action )
    # reset the action forward
  end

  def run( now = Time.now )
    clear_stale_actions( now )

    # scheduled
    configuration.jobs.each do |job|
      Commotion::Action.kind( job.kind ).ready( now ).each { |a| perform( job, a ) }
    end

    sleep_until_next_action( now )
  end

  def clear_stale_actions( now = Time.now )
    configuration.jobs.each do |job|
      job.stale( now ).each do |a|
        a.unexpire
        configuration.logger.warn "Cleared #{a}"
      end
    end
  end

  def schedule( kind, ref, at )
    Commotion::Action.kind(kind).where( ref: ref ).first_or_create
  end

  def sleep_until_next_action( now )
    kinds = configuration.jobs.map { |job| job.kind }
    next1 = Commotion::Action.where( kind: kinds ).upcoming1( now ).first
    wake  = [ next1 && next1.at, now + 1.minute ].compact.min
    configuration.logger.debug "Sleeping until #{wake}"
    sleep_until( wake )
  end

  def sleep_until( future )
    while (t = Time.now) < future
      sleep( ( future - t ) / 2 )
    end
  end

end
