class ReservationsController < ApplicationController
  before_action :set_movie_and_schedule_for_new,    only: :new
  before_action :set_movie_and_schedule_for_create, only: :create

  def set_movie_and_schedule_for_new
    @movie = Movie.find_by(id: params[:movie_id])
    return redirect_to(movies_path, alert: '指定された映画がありません') unless @movie

    @schedule = @movie.schedules.find_by(id: params[:schedule_id])
    return redirect_to(movies_path, alert: '指定されたスケジュールがありません') unless @schedule

    @theater = @schedule.screen&.theater
    redirect_to(movies_path, alert: 'スケジュールに紐づく劇場情報が不正です') unless @theater
  end

  def set_movie_and_schedule_for_create
    schedule_id = params.dig(:reservation, :schedule_id)
    return redirect_to(movies_path, alert: 'スケジュールが指定されていません') if schedule_id.blank?

    @schedule = Schedule.includes(:movie, screen: :theater).find(schedule_id)
    @movie    = @schedule.movie
    @theater  = @schedule.screen&.theater
  rescue ActiveRecord::RecordNotFound
    redirect_to(movies_path, alert: '指定されたスケジュールがありません')
  end

  def reservation_params
    params.require(:reservation).permit(:sheet_id, :name, :email, :date)
      .merge(schedule_id: @schedule.id)
  end

  # GET /movies/:movie_id/schedules/:schedule_id/reservations/new
  def new
    return redirect_to(movies_path, alert: '日付と座席の指定が必要です') if params[:date].blank? || params[:sheet_id].blank?

    @date = begin
      Date.iso8601(params[:date])
    rescue StandardError
      nil
    end
    return redirect_to(movies_path, alert: '日付の形式が不正です') unless @date

    @sheet = Sheet.find_by(id: params[:sheet_id])
    return redirect_to(movies_path, alert: '座席が見つかりません') unless @sheet
    return redirect_to(movies_path, alert: '不正な座席が指定されました') unless @sheet.screen_id == @schedule.screen_id

    @reservation = Reservation.new(schedule: @schedule, sheet: @sheet, date: @date)
  end

  # POST /reservations
  def create
    @reservation = Reservation.new(reservation_params)
    return redirect_to back_to_seat_page(@reservation), alert: '不正な座席が指定されました' unless @reservation.sheet&.screen_id == @schedule.screen_id

    if @reservation.save
      # ✅ 自分の予約をセッションに記録（これが重要！）
      session[:my_reservation_ids] ||= []
      session[:my_reservation_ids] << @reservation.id

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

  def confirm_cancel
    @reservation = Reservation.find_by(id: params[:id])
    return redirect_back(fallback_location: movies_path, alert: '予約が見つかりません') unless @reservation

    # 本人判定（セッションに保存したIDを使う）
    unless Array(session[:my_reservation_ids]).map(&:to_i).include?(@reservation.id)
      return redirect_back(fallback_location: back_to_seat_page(@reservation),
                           alert: 'この予約は操作できません')
    end
    @limit_hours = ENV.fetch('CANCEL_LIMIT_HOURS', '2').to_i
    @cancellable = Time.zone.now < (@reservation.schedule.start_time - @limit_hours.hours)
  end

  def destroy
    @reservation = Reservation.find_by(id: params[:id])
    return redirect_back(fallback_location: movies_path, alert: '予約が見つかりません') unless @reservation

    # ✅ 本人判定（セッションに保存したIDを使う）
    unless Array(session[:my_reservation_ids]).map(&:to_i).include?(@reservation.id)
      return redirect_back(fallback_location: back_to_seat_page(@reservation),
                           alert: 'この予約は操作できません')
    end

    limit_hours = ENV.fetch('CANCEL_LIMIT_HOURS', '2').to_i
    if Time.zone.now < (@reservation.schedule.start_time - limit_hours.hours)
      info = {
        email: @reservation.email,
        movie_name: @reservation.schedule.movie.name,
        theater: @reservation.schedule.screen&.theater&.name,
        screen: @reservation.schedule.screen&.name,
        start_time: @reservation.schedule.start_time,
        end_time: @reservation.schedule.end_time,
        date: @reservation.date,
        seat_label: "#{@reservation.sheet.row}#{@reservation.sheet.column}",
        movie_id: @reservation.schedule.movie_id,
        schedule_id: @reservation.schedule_id
      }

      flash[:cancel_info] = info
      ReservationMailer.cancellation(info).deliver_later if info[:email].present?
      session[:my_reservation_ids] = Array(session[:my_reservation_ids]).map(&:to_i) - [@reservation.id]

      @reservation.destroy!
      redirect_to cancelled_reservations_path
    else
      redirect_back fallback_location: back_to_seat_page(@reservation),
                    alert: "キャンセル期限（#{limit_hours}時間前）を過ぎています。"
    end
  end

  def cancelled
    info = flash[:cancel_info]
    return redirect_to(root_path, alert: 'キャンセル情報が見つかりません') unless info

    @info = info.symbolize_keys
  end

  private

  def back_to_seat_page(reservation)
    reservation_movie_path(
      reservation.schedule.movie,
      schedule_id: reservation.schedule_id,
      date: reservation.date
    )
  end
end
