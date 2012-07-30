require "active_record"

module Commotion
  module Test
    module ActiveRecordHelper

      CONFIGURATION = {
        adapter:    "mysql2",
        database:   "test",
        host:       "localhost",
        socket:     "/tmp/mysql.sock",
        username:   "root"
      }

      def with_clean_mysql(&block)
        ActiveRecord::Base.establish_connection(CONFIGURATION)
        ActiveRecord::Base.connection.tap do |c|
          c.execute %Q{ drop table commotion_actions } rescue nil
          c.execute %Q{ create table commotion_actions ( ref int not null, kind varchar(255) not null, at timestamp not null, lock_expiration timestamp null default null, primary key (ref, kind), key index_kind_by_at (kind, at) ) engine=InnoDB }
        end
        begin
          yield
        ensure
          ActiveRecord::Base.connection.tap do |c|
            c.execute %Q{ drop table commotion_actions }
          end
        end
      end

    end
  end
end
