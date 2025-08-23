class ReservationsController < ApplicationController
  def new
    # パラメータチェック（不足している場合はリダイレクト）
    if params[:date].blank? || params[:sheet_id].blank?
      redirect_to movies_path, alert: '日付と座席の指定が必要です'
      return
    end

    @movie = Movie.find(params[:movie_id])
    @schedule = Schedule.find(params[:schedule_id])
    @sheet = Sheet.find(params[:sheet_id])
    @date = params[:date]

    @reservation = Reservation.new(
      schedule: @schedule,
      sheet: @sheet,
      date: @date
    )
  end

  def create
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      redirect_to movies_path, notice: '予約が完了しました'
    else
      redirect_to "/movies/#{@reservation.schedule.movie_id}/reservation?schedule_id=
      #{@reservation.schedule_id}&date=#{@reservation.date}", alert: 'この座席はすでに予約されています'
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(:schedule_id, :sheet_id, :name, :email, :date)
  end
end
