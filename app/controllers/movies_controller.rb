class MoviesController < ApplicationController
  def index
    @movies = Movie.all
    params[:is_showing] = '' if params[:is_showing].blank?

    if params[:keyword].present?
      @movies = Movie.search_by_keyword(params[:keyword])
    end

    if params[:is_showing].present?
      is_showing_value = params[:is_showing].to_i
      if is_showing_value.nonzero?
        @movies = @movies.where(is_showing: true)
      elsif is_showing_value.zero?
        @movies = @movies.where(is_showing: false)
      end
    end

    # station5のコード
    latest = MovieRanking.maximum(:date)
    @rankings = if latest
      MovieRanking.includes(:movie)
                  .where(date: latest)
                  .order(total_reservations: :desc)
                  .limit(10)
    else
      []
    end

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @movies }
    end
  end

  def show
    @movie = Movie.find(params[:id])
    # 劇場・スクリーンを同時に読む & 時刻順
    @schedules = @movie.schedules
                       .includes(screen: :theater)
                       .order(:start_time)
  end

  # def reservation
  #   @movie = Movie.find(params[:id])

  #   # 必須パラメータ確認
  #   unless params[:schedule_id].present? && params[:date].present?
  #     redirect_to movies_path, alert: 'スケジュールIDと日付が必要です' and return
  #   end

  #   # スケジュールと日付
  #   @schedule = @movie.schedules
  #                     .includes(screen: :theater)
  #                     .find(params[:schedule_id])

  #   @date = begin
  #     Date.parse(params[:date])
  #   rescue ArgumentError
  #     nil
  #   end
  #   redirect_to movies_path, alert: '日付の形式が不正です' and return if @date.nil?

  
  #   if @date != @schedule.start_time.to_date
  #     redirect_to movies_path, alert: 'スケジュールの日付と異なる日付です' and return
  #   end

  #   if params[:time].present?
  #     scheduled_time = @schedule.start_time.in_time_zone.strftime('%H:%M')
  #     if params[:time] != scheduled_time
  #       redirect_back fallback_location: movie_path(@movie),
  #       alert: '指定された時間の上映はありません' and return
  #     end
  #   end

  #   # 画面表示用（ビューで使う）
  #   @theater = @schedule.screen&.theater
  #   @screen  = @schedule.screen

  #   # 座席と予約済み座席
  #   @seats = Sheet.where(screen_id: @screen.id).order(:row, :column)
  #   @reserved_seats = Reservation.where(
  #     schedule_id: @schedule.id, date: @date
  #   ).pluck(:sheet_id)
  # end
  def reservation
  @movie = Movie.find(params[:id])
  return redirect_to(movies_path, alert: 'スケジュールIDと日付が必要です') \
    unless params[:schedule_id].present? && params[:date].present?

  @schedule = @movie.schedules
                    .includes(screen: :theater)
                    .find(params[:schedule_id])

  @date = (Date.iso8601(params[:date]) rescue nil)
  return redirect_to(movies_path, alert: '日付の形式が不正です') unless @date
  return redirect_to(movies_path, alert: 'スケジュールの日付と異なる日付です') \
    unless @date == @schedule.start_time.to_date

  # ← ここで“あり得ないケース”のUI用フラグを立てる（リダイレクトしない）
  @scheduled_time = @schedule.start_time.in_time_zone.strftime('%H:%M')
  requested_time  = params[:time].presence
  @time_problem =
    if requested_time.blank?
      :missing
    elsif requested_time != @scheduled_time
      :mismatch
    else
      nil
    end

  # 画面表示用
  @screen  = @schedule.screen
  @theater = @screen&.theater

  # 座席 & 予約済
  @seats = @screen.sheets.order(:row, :column)
  @reserved_seats = Reservation.where(schedule_id: @schedule.id, date: @date).pluck(:sheet_id)
  end
end
