require "mongo"

module Commotion
  module Test
    module MongoHelper

      def with_clean_mongo(&block)
        Commotion.configuration.mongo.drop
        Commotion.configuration.mongo.create_index( [ ["at",Mongo::DESCENDING], ["kind",Mongo::ASCENDING] ] )
        Commotion.configuration.mongo.create_index( [ ["lock_expiration",Mongo::DESCENDING] ] )
        begin
          yield
        ensure
          Commotion.configuration.mongo.drop
        end
      end

    end
  end
end
