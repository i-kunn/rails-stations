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



# env :TZ, 'Asia/Tokyo'
# set :environment, 'development'

# # 出力先は絶対パス、標準出力と標準エラーを分ける
# set :output, {
#   standard: "#{path}/log/cron.log",
#   error:    "#{path}/log/cron.error.log"
# }

# # --silent を外す rake 実行定義
# job_type :rake, "cd :path && :environment_variable=:environment bundle exec rake :task :output"

# every 1.minute do
#   command "echo CRON_OK $(date) >> #{path}/log/cron_test.log"
#   rake 'reminder:send'
# end
# config/schedule.rb
env :TZ, 'Asia/Tokyo'
set :environment, 'development'   # 本番環境なら 'production'

set :output, {
  standard: "#{path}/log/cron.log",
  error:    "#{path}/log/cron.error.log"
}

job_type :rake, "cd :path && :environment_variable=:environment bundle exec rake :task :output"

# ← 前日19:00に1回実行
every 1.day, at: '7:00 pm' do
  rake 'reminder:send'
end


