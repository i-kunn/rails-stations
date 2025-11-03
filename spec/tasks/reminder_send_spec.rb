# spec/tasks/reminder_send_spec.rb
require 'rails_helper'
require 'rake'

RSpec.describe 'reminder:send' do
  before do
    Rails.application.load_tasks unless Rake::Task.task_defined?('reminder:send')
    ActionMailer::Base.deliveries.clear
  end

  it '当日分は送らず、前日分（=明日上映分）だけ送る' do
    # 予約のセットアップ（あなたのFactoryに合わせて調整）
    create(:reservation, date: Date.current)       # 当日
    tomorrow = create(:reservation, date: Date.tomorrow) # 前日分対象

    expect {
      Rake::Task['reminder:send'].invoke
    }.to change { ActionMailer::Base.deliveries.count }.by(1)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.body.encoded).to include(tomorrow.schedule.movie.name)
  ensure
    # 同じプロセスでの再実行用にリセット
    Rake::Task['reminder:send'].reenable
  end
end
