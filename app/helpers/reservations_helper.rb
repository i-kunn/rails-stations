# app/helpers/reservations_helper.rb
module ReservationsHelper
  # 自分の予約かどうか
  def my_reservation?(reservation)
    Array(session[:my_reservation_ids]).map(&:to_i).include?(reservation.id)
  end

  # キャンセル可能かどうか
  def cancellable?(reservation)
    limit_hours = ENV.fetch('CANCEL_LIMIT_HOURS', '2').to_i
    Time.zone.now < (reservation.schedule.start_time - limit_hours.hours)
  end
end
