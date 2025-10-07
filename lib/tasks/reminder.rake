# # lib/tasks/reminder.rake
# namespace :reminder do
#   desc "Send reminder emails for tomorrow's reservations (JST)"
#   task send: :environment do
#     Time.zone = 'Asia/Tokyo'
#     target_date = Time.zone.tomorrow.to_date

#     Reservation.includes(:schedule, :sheet)
#                .where(date: target_date)
#                .limit(1)
#                .find_each do |r|
#       email = r.email.to_s.strip
#       next if email.blank?   # ← 宛先が無ければ送らない

#       ReminderMailer.with(reservation: r, email: email).notify.deliver_now
#     end
#   end
# end
# lib/tasks/reminder.rake
# namespace :reminder do
#   desc "Send reminder emails for tomorrow's reservations (JST)"
#   task send: :environment do
#     Time.zone = 'Asia/Tokyo'
#     target_date = Time.zone.tomorrow.to_date

#     reservations = Reservation.includes(:schedule, :sheet)
#                               .where(date: target_date)
#                               .limit(1)

#     puts "[reminder] start at=#{Time.zone.now}, target_date=#{target_date}, count=#{reservations.size}"

#     reservations.find_each do |r|
#       email = r.email.to_s.strip
#       next if email.blank?

#       ReminderMailer.with(reservation: r, email: email).notify.deliver_now
#       puts "[reminder] sent to=#{email}, movie=#{r.schedule.movie.name}, start_time=#{r.schedule.start_time.in_time_zone('Asia/Tokyo')}"
#     end

#     puts "[reminder] finished at=#{Time.zone.now}"
#   end
# end
namespace :reminder do
  desc "Send reminder emails for tomorrow's reservations (JST)"
  task send: :environment do
    Time.zone = 'Asia/Tokyo'
    target_date = Time.zone.tomorrow.to_date

    reservations = Reservation
                     .includes({ schedule: :movie }, :sheet) # ← これが正しい！
                     .where(date: target_date)
                     .limit(1) # 手動テスト用に1件だけ送信

    puts "[reminder] start at=#{Time.zone.now}, target_date=#{target_date}, count=#{reservations.size}"

    reservations.each do |r|
      email = r.email.to_s.strip
      next if email.blank?

      ReminderMailer.with(reservation: r, email: email).notify.deliver_now
      puts "[reminder] sent to=#{email}, movie=#{r.schedule.movie.name}, start_time=#{r.schedule.start_time.in_time_zone('Asia/Tokyo')}"
    end

    puts "[reminder] finished at=#{Time.zone.now}"
  end
end
