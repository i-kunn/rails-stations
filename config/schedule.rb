# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
# config/schedule.rb
# env :TZ, 'Asia/Tokyo'
# set :environment, 'development'
# set :output, 'log/cron.log'
# every 1.minute do
#   rake 'reminder:send'
# end


# config/schedule.rb
# config/schedule.rb
env :TZ, 'Asia/Tokyo'
set :environment, 'development'

# cron でも必ず見つかるように絶対パス＆固定 PATH
env :PATH, '/usr/local/bundle/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
env :BUNDLE_GEMFILE, '/app/Gemfile'
env :GEM_HOME, '/usr/local/bundle'
env :BUNDLE_PATH, '/usr/local/bundle'

set :output, { standard: '/app/log/cron.log', error: '/app/log/cron.error.log' }

# << ここが肝: bundle の絶対パスを使う（cron は PATH を信用しない）
job_type :rake, "cd :path && :environment_variable=:environment /usr/local/bin/bundle exec rake :task :output"

every 1.minute do
  command "echo CRON_OK $(date) | tee -a /app/log/cron_test.log >> /app/log/cron.log 2>> /app/log/cron.error.log"

  rake 'reminder:send'
end
