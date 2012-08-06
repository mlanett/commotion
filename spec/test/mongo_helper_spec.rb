require "helper"

describe Commotion::Test::MongoHelper do

  it "cleans mongo" do
    with_clean_mongo do
      Commotion.configuration.mongo.find.count.should eq 0
      Commotion.configuration.mongo.insert( "a" => 1 )
      Commotion.configuration.mongo.find.count.should eq 1
    end
    Commotion.configuration.mongo.find.count.should eq 0
  end

end
