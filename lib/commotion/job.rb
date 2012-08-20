require "commotion"
require "active_support"
require "active_support/core_ext/hash/slice"

=begin

  A job has a configuration (at the class level).
  This allows it to access storage.

  A job has a key or set of keys which creates a unique id.
  Additional values are stored but do not change the id of the job.
  For many jobs this is just "id".
  e.g. Job id=1 and id=2 are different. Job id=1 foo=2 will match the first job.
  Some jobs may have more than this.
  e.g. Job id=1 company=2 user=3 is different from Job id=1 company=1 user=3.

=end
class Commotion::Job

  class MissingAtTime < StandardError
  end

  class MissingKeys < StandardError
  end

  include Commotion
  include Utilities
  extend Utilities

  # ----------------------------------------------------------------------------
  # Configuration, Scheduling, Finding
  # ----------------------------------------------------------------------------

  #
  # Configuration
  #

  def self.configuration
    # Inherit the value on demand
    @configuration ||= begin
      self == Job ? Commotion.configuration : self.superclass.configuration
    end
  end

  def self.configuration=(c)
    @configuration = c
  end

  def configuration
    @configuration ||= self.class.configuration
  end

  #
  # Scheduling jobs
  #

  def self.schedule( options = {} )
    # canonicalize arguments as strings
    # ensure we have a timestamp
    # build proper id (e.g. [ kind, at, id, account ])
    # non-key values are also saved

    options = stringify(options)
    at      = options["at"] or raise MissingAtTime
    id      = options.slice(*key).merge( "at" => at, "kind" => kind )
    raise( MissingKeys, key.join(",") ) if id.size != key.size + 2

    configuration.mongo.update( id, options.merge(id), upsert: true )
  end

  # All options are standard mongo options, except for "at",
  # which if given, and if simple, is shorthand for 'at <= ...'
  # @param at defaults to Time.now
  # @returns documents sorted by scheduled time, earliest first.
  def self.find( options = {} )
    # canonicalize arguments as strings
    # at defaults to Time.now

    options = stringify(options)
    case at = options.delete("at")
    when nil
      at = { "$lte" => Time.now }
    when Hash
      # Ok
    else # (simple)
      at = { "$lte" => at }
    end

    query = { "at" => at, "kind" => kind }.merge( options )
    result = configuration.mongo.find({ "$query" => query, "$orderby" => { "at" => 1 } })
    result = result.limit(1) if false
    result.map do |d|
      Action.new(d)
    end
  end

  # Finds documents of this kind, not locked, with timestamp <= now.
  # Additional constraints are accepted.
  # @see find()
  def self.ready( options = {} )
    find( options.merge locked: nil )
  end

  # Finds documents of this kind, locked, with timestamp <= now.
  # @see find()
  def self.stale( options = {} )
    options = stringify(options)
    at      = options["at"] || Time.now

    find( options.merge( "at" => at, "locked" => { "$lt" => at } ) )
  end

  # Finds documents which are NOT ready, but will be in another minute.
  # @param at is the *ending* point for the time interval.
  # @returns the first document’s at time only.
  def self.next_ready_at( at = Time.now + 60, options = {} )
    doc = find( options.merge at: { "$lte" => at }, locked: nil ).first
    doc && doc.at
  end

  #
  # Storage
  #

  def self.key( *key )
    if key && key.size > 0 then
      @key = key.map { |k| k.to_s }
    else
      @key ||= [ "id" ]
    end
  end

  def self.kind
    self.name
  end

  #
  # Processing jobs
  #

  def perform( action )
    # no-op
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------


  end

  end

end
