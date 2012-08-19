require "commotion"

class Commotion::Scheduler

  class UnknownJob < Exception
  end

  include Commotion

  BATCH = 20

  attr :configuration

  def initialize( configuration )
    @configuration = configuration
    @running       = []
    @map           = configuration.jobs.inject({}) do |a,i|
      raise( UnknownJob, i.inspect ) unless i.respond_to? :schedule
      a[i.to_s] = i
      a
    end
  end

  def schedule( kind, options = {} )
    kind = kind.to_s
    job  = @map[kind] or raise( UnknownJob, kind )
    job.schedule( options )
  end

  def run
    check
    clear_stale_actions
    next_run
  end

  def check
    # scheduled
    @map.values.each do |job|
      actions = job.ready
      actions.each do |action|
        perform( job, action )
      end
    end
  end

  # @returns when all jobs are complete and all workers are idle
  def wait
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def perform( job, action )
    # wait until we can get a process
    # fork
    # run it
    job.new( self ).perform( action )
    # reset the action forward
  end

  def clear_stale_actions
    @map.values.each do |job|
      job.stale.each do |a|
        a.unexpire
        logger.warn "Cleared #{a}"
      end
    end
  end

  def next_run( now = Time.now )
    # TODO try to do fewer queries; ideally just 1. However not easy with multiple collections.
    idle = true
    wake = now + 60
    jobs.each do |job|
      njob = job.upcoming1(at: now)
      if njob && njob.at < wake then
        idle = false
        wake = njob.at
      end
    end

    wake
  end

  # ----------------------------------------------------------------------------
  private
  # ----------------------------------------------------------------------------

  def sleep_until( future )
    logger.debug "Sleeping until #{wake}"
    # don't overshoot the target time
    while (t = future - Time.now) > 0
      sleep t/2
    end
  end

  def jobs
    @jobs ||= @configuration.jobs
  end

  def logger
    @logger ||= @configuration.logger
  end

end
