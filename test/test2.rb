#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require "bundler"               # set up gem paths
Bundler.setup(:default,:test)
require "commotion"             # load this gem
require "commotion/test/active_record_helper"
include Commotion::Test::ActiveRecordHelper

class A < Commotion::Job
  def process()
    puts "A"
  end
end

class B < Commotion::Job
  def process()
    puts "B"
  end
end

with_clean_mysql do

  c = Commotion::Configuration.new.tap do |myself|
    myself.instance_eval do
      after_fork() { puts "Forked!" }
      workers 10
      schedule A
      schedule B
    end
  end

  s = Commotion::Scheduler.new(c)
  10.times { |i| s.schedule "a", i=1, at: Time.now + rand(10) }
  s.run

end
