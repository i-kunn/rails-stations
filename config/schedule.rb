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
env :TZ, 'Asia/Tokyo'
set :environment, 'development'

set :output, { standard: '/app/log/cron.log', error: '/app/log/cron.error.log' }

job_type :rake, '
  cd :path &&
  export BUNDLE_GEMFILE=/app/Gemfile &&
  export GEM_HOME=/usr/local/bundle &&
  export BUNDLE_PATH=/usr/local/bundle &&
  export PATH=/usr/local/bundle/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin &&
  :environment_variable=:environment /usr/local/bin/bundle exec rake :task :output
'
# # 19時に毎日実行
every 1.day, at: '19:00' do
  rake 'reminder:send'
end
# 本番用
every 1.day, at: '00:00' do
  rake 'ranking:update'
end
