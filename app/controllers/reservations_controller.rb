class ReservationsController < ApplicationController
  before_action :set_movie_and_schedule_for_new,    only: :new
  before_action :set_movie_and_schedule_for_create, only: :create

    def set_movie_and_schedule_for_new
    @movie    = Movie.find_by(id: params[:movie_id])
    return redirect_to(movies_path, alert: '指定された映画がありません') unless @movie

    @schedule = @movie.schedules.find_by(id: params[:schedule_id])
    return redirect_to(movies_path, alert: '指定されたスケジュールがありません') unless @schedule

    @theater  = @schedule.screen&.theater
    return redirect_to(movies_path, alert: 'スケジュールに紐づく劇場情報が不正です') unless @theater
  end

  def set_movie_and_schedule_for_create
    schedule_id = params.dig(:reservation, :schedule_id)
    return redirect_to(movies_path, alert: 'スケジュールが指定されていません') if schedule_id.blank?
    @schedule = Schedule.includes(:movie, screen: :theater).find(schedule_id)
    @movie    = @schedule.movie
    @theater  = @schedule.screen&.theater
  rescue ActiveRecord::RecordNotFound
    return redirect_to(movies_path, alert: '指定されたスケジュールがありません')
  end

  def reservation_params
    params.require(:reservation).permit(:sheet_id, :name, :email, :date)
          .merge(schedule_id: @schedule.id)
  end



  # GET /movies/:movie_id/schedules/:schedule_id/reservations/new
  def new
    return redirect_to(movies_path, alert: '日付と座席の指定が必要です') if params[:date].blank? || params[:sheet_id].blank?

    @date = (Date.iso8601(params[:date]) rescue nil)
    return redirect_to(movies_path, alert: '日付の形式が不正です') unless @date

    @sheet = Sheet.find_by(id: params[:sheet_id])
    return redirect_to(movies_path, alert: '座席が見つかりません') unless @sheet
    return redirect_to(movies_path, alert: '不正な座席が指定されました') unless @sheet.screen_id == @schedule.screen_id

    @reservation = Reservation.new(schedule: @schedule, sheet: @sheet, date: @date)
  end

  # POST /reservations
  def create
    @reservation = Reservation.new(reservation_params)   
    unless @reservation.sheet&.screen_id == @schedule.screen_id
      return redirect_to back_to_seat_page(@reservation), alert: '不正な座席が指定されました'
    end

    if @reservation.save
      ReservationMailer.confirmation(@reservation.id).deliver_later
      redirect_to back_to_seat_page(@reservation), notice: '予約しました'
    else
      @sheet   = @reservation.sheet
      @date    = @reservation.date
      @movie   = @schedule&.movie
      @theater = @schedule&.screen&.theater
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to back_to_seat_page(@reservation),
                alert: 'この座席はすでに予約されています'
  end

  private  

  def back_to_seat_page(reservation)
    reservation_movie_path(
      reservation.schedule.movie,
      schedule_id: reservation.schedule_id,
      date:        reservation.date
    )
  end
end
