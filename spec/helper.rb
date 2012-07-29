# -*- encoding: utf-8 -*-
require "bundler/setup"         # set up gem paths
#require "ruby-debug"
require "simplecov"             # code coverage
SimpleCov.start                 # must be loaded before our own code
require "commotion"             # load this gem
require "active_record"
require "commotion/test/active_record_helper"
require "commotion/concurrent/thread_helpers" if ENV["TRACE"]

RSpec.configure do |spec|
  include Commotion::Test::ActiveRecordHelper
  spec.around( :each, mysql: true ) do |example|
    with_clean_mysql do
      example.run
    end
  end
end
