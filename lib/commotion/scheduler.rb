require "commotion"

class Commotion::Scheduler

  class UnknownJob < Exception
  end

  include Commotion

  BATCH = 20
  SLEEP = 60

  attr :configuration

  def initialize( configuration )
    @configuration = configuration
    @running       = []
    @runnable      = true
    @map           = configuration.jobs.inject({}) { |a,kind| a[kind.to_s] = check_kind(kind); a }
  end

  def schedule( kind, options = {} )
    kind = kind.to_s
    job  = @map[kind] or raise( UnknownJob, kind )
    job.schedule( options )
  end

  # @param block must return a Time or nil
  # @returns when state == :stop
  def loop_with_sleep( &block )
    loop do
      wake = nil
      begin
        wake = block.call
      rescue => x
        logger.warn warning: "Loop iteration failed", error: x.inspect
      end
      wake = [ wake, Time.now + SLEEP ].compact.min
      break if ! @runnable
      sleep_until wake
    end
  end

  def run
    check
    clear_stale_actions
    return next_before( Time.now + SLEEP )
  end

  def check
    # scheduled
    jobs.each do |job|
      actions = job.ready
      actions.each do |action|
        perform( job, action )
      end
    end
  end

  # @returns when all jobs are complete and all workers are idle
  def wait
    # TODO spec me
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def perform( kind, action )
    # wait until we can get a process
    # fork
    # run it
    job = kind.new( action )
    job.with_lock { job.perform }
    # reset the action forward
  end

  def clear_stale_actions
    jobs.each do |job|
      job.stale.each do |a|
        a.unexpire
        logger.warn warning: "Cleared action with expired log", action: a.to_s
      end
    end
  end

  def next_before( by )
    # TODO try to do fewer queries; ideally just 1. However not easy with multiple collections.
    wake = jobs.map { |job| job.next_ready_time_by(by) }.min
  end

  # ----------------------------------------------------------------------------
  private
  # ----------------------------------------------------------------------------

  def check_kind(kind)
    raise( UnknownJob, kind.inspect ) unless kind.respond_to?(:schedule)
    kind
  end

  def sleep_until( future )
    logger.debug trace: "Sleeping until #{wake}"
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
