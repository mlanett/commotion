# table (commotion_actions) full of events which need to execute, and how to execute them
# ref         reference, used by the job. Probably an object id.
# kind        varchar. Which job to run.
# at          timestamp. When to run this job.
# lock_expiration    timestamp. If set, a job is running for this action right now.

class ModeratePage < Job
end

class SchedulePost < Job
end

schedule :moderation, ModeratePage
schedule :page_insights, PageInsights
schedule :publishing, SchedulePost

loop do
  next_wake = [ next_action, Time.now + 1.minute ].compact.min
  sleep_until next_wake
  next_actions = job.upcoming1
end

loop do
  clear expired actions
  get first ready action and lock it and run it
  check for next action time
  sleep until next action
end
