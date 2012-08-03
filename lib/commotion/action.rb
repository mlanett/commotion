require "commotion"

class Commotion::Action

  # ref             int not null
  # kind            varchar(255) not null
  # at              timestamp not null
  # lock_expiration timestamp

  DELTA = 1000 # seconds

  #
  # Storage
  #

  class << self

    def ready( kind, options = nil )
      at = options[:at] || Time.now
    end

  end

  #scope :kind,      ->( k ) { where( kind: k ) }

  #scope :ready,     ->( t = Time.now ) { where( [ "at <= ?", t ] ).where( "lock_expiration is null" ).order(:at) }
  #scope :stale,     ->( t = Time.now ) { where( [ "lock_expiration <= ?", t ] ) }
  #scope :upcoming1, ->( t = Time.now ) { where( [ "? < at and at <= ?", t, t + DELTA ] ).where( "lock_expiration is null" ).order(:at).limit(1) }

  def to_s
    # [ kind, ref ].join("-")
    "#{kind}-#{ref}"
  end

  # All these methods below are hacky because AR doesn't support compound keys.

  def with_app_lock( &block )
    # acquire lock_expiration
    ok = with_connection_lock do |locked_self|
      if locked_self.lock_expiration.nil? then
        row.update_all lock_expiration: Time.now + DELTA
        true
      end
    end
    # use and release lock_expiration outside of the connection_lock
    if ok then
      begin
        block.call
      ensure
        row.update_all lock_expiration: nil
      end
    end
  end

  def advance
    with_connection_lock do |locked_self|
      #
    end
  end

  def reschedule( future )
    row.update_all at: future
  end

  def delete
    row.delete_all
  end

  def unexpire
    with_connection_lock do |locked_self|
      if locked_self.lock_expiration && locked_self.lock_expiration < Time.now then
        row.update_all lock_expiration: nil
      end
    end
  end

  protected

  # ActiveRecord relation to find this row
  # hack required because we have a compound primary key - unsupported by ActiveRecord
  def row
    self.class.where( ref: ref, kind: kind )
  end

  def with_connection_lock # block(locked_self)
    transaction do
      yield(row.lock.first)
    end
  end

end
