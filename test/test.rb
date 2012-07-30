#!/usr/bin/env ruby
require File.expand_path('../../config/environment',  __FILE__)

Commotion::Action.create ref: 1, kind: 'hi', at: Time.now
c = Commotion::Action.first
c.with_app_lock { c.reschedule( Time.now+1) }

exit


theJob = Job.new "competitor_page_fan_count", CompetitorPage.enabled
Scheduler.new(theJob).run
