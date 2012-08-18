module DeadCode

  DELTA = 1000 # seconds

  #
  # Storage
  #

  def to_s
    # [ kind, id ].join("-")
    "#{kind}-#{id}"
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
    end
  end

  def reschedule( future )
  end

  def delete
  end

  def unexpire
    with_connection_lock do |locked_self|
      if locked_self.lock_expiration && locked_self.lock_expiration < Time.now then
        row.update_all lock_expiration: nil
      end
    end
  end

  protected

  def with_connection_lock # block(locked_self)
    transaction do
      yield(row.lock.first)
    end
  end

end # dead
