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

  # Configuration

  def self.configuration
    # Inherit the value on demand
    @configuration ||= begin
      self == Commotion::Job ? Commotion::Configuration.new : self.superclass.configuration
    end
  end

  def self.configuration=(c)
    @configuration = c
  end

  # Storage

  def self.key( *key )
    if key && key.size > 0 then
      @key = key.map { |k| k.to_s }
    else
      @key ||= [ "id" ]
    end
  end

  # Scheduling jobs

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

  class << self

    def kind
      self.name
    end

    def ready( c, options = nil )
      at = options && options[:at] || Time.now
      Commotion::Action.kind(kind).ready
    end

    def stale( t = Time.now )
      Commotion::Action.kind(kind).stale
    end

    def upcoming1( t = Time.now )
      Commotion::Action.kind(kind).upcoming1.first
    end

  end

  # Processing jobs

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
