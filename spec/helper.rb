# -*- encoding: utf-8 -*-

require "bundler/setup"         # set up gem paths
#require "ruby-debug"
require "simplecov"             # code coverage
SimpleCov.start                 # must be loaded before our own code
require "commotion"             # load this gem
require "commotion/test/mongo_helper"
require "commotion/concurrent/thread_helpers" if ENV["TRACE"]

RSpec.configure do |spec|
  include Commotion::Test::MongoHelper
  spec.around( :each, storage: true ) do |example|
    with_clean_mongo do
      example.run
    end
  end
end
