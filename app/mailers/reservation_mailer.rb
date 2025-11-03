class ReservationMailer < ApplicationMailer
  default from: ENV.fetch('MAIL_FROM', 'no-reply@example.com')

  # ← deliver_later を想定して ID 受け取りに
  def confirmation(reservation_id)
    @reservation = Reservation
      .includes(schedule: [:movie, { screen: :theater }]) # N+1回避
      .find(reservation_id)

    # もしビューで使うなら補助変数を揃えてもOK（経路は一本化）
    @schedule = @reservation.schedule
    @movie    = @schedule.movie
    @theater  = @schedule.screen.theater # ← ここを固定！

    mail(
      to: @reservation.email,
      subject: '予約が完了しました'
    )
  end

  def cancellation(info)
    @info = info
    subject = "【キャンセル完了】#{@info[:movie_name]} (#{@info[:start_time].in_time_zone.strftime('%Y/%m/%d %H:%M')})"
    mail(
      to: @info[:email], subject:
    )
  end
end
