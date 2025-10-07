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
    @theater  = @schedule.screen.theater  # ← ここを固定！

    mail(
      to:      @reservation.email,
      subject: '予約が完了しました'
    )
  end
end
