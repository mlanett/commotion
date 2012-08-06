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
  include Commotion

  #
  # Configuration
  #

  def self.configuration
    # Inherit the value on demand
    @configuration ||= begin
      self == Job ? Configuration.new : self.superclass.configuration
    end
  end

  def self.configuration=(c)
    @configuration = c
  end

  #
  # Scheduling jobs
  #

  def self.schedule( vals = {} )
    # canonicalize arguments as strings
    # ensure we have a timestamp
    # build proper id
    # non-key values are also saved

    vals = stringify(vals)
    at   = vals["at"] or raise MissingAtTime
    id   = vals.slice(*key).merge( "at" => at, "kind" => kind )
    raise( MissingKeys, key ) if id.size != key.size + 2

    configuration.mongo.update( id, vals.merge(id), upsert: true )
  end

  # All options are standard mongo options, except for until_at,
  # which is shorthand for 'at <= ...'
  # @param until_at defaults to Time.now
  # @returns documents sorted by scheduled time, earliest first.
  def self.find( options = nil )
    # canonicalize arguments as strings
    # until_at defaults to Time.now

    options  = stringify(options)
    until_at = options["until_at"] || Time.now
    query    = { "at" => { "$lt" => until_at }, "kind" => kind }.merge options

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
    options  = stringify(options)
    until_at = options["until_at"] || Time.now

    find( options.merge( "locked" => { "$lt" => until_at } ) )
  end

  # Finds documents which are NOT ready, but will be in another minute.
  # @returns the first document only.
  def self.upcoming1( options = nil )
    options  = stringify(options)
    after_at = options["after_at"] || Time.now

    find( "after_at" => after_at, "until_at" => after_at + 60, "locked" => nil, "limit" => 1 ).first
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
    puts action.to_s
  end

  protected

  include Utilities
  extend Utilities

  def configuration
    self.class.configuration
  end

  class MissingAtTime < StandardError
  end

  class MissingKeys < StandardError
  end

end
