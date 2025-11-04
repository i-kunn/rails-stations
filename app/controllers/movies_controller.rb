class MoviesController < ApplicationController
  helper :reservations
  def index
    @movies = Movie.all
    params[:is_showing] = '' if params[:is_showing].blank?

    @movies = Movie.search_by_keyword(params[:keyword]) if params[:keyword].present?

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
    @target_date = latest
    @rankings = if latest

                  MovieRanking
                    .joins(:movie)
                    .includes(:movie)
                    .where(date: latest, movies: { is_showing: true })
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

  def reservation
    @movie = Movie.find(params[:id])

    # 必須パラメータ
    redirect_to movies_path, alert: 'スケジュールIDと日付が必要です' and return unless params[:schedule_id].present? && params[:date].present?

    # スケジュール
    @schedule = @movie.schedules.includes(screen: :theater).find(params[:schedule_id])

    # 日付
    @date = begin
      Date.parse(params[:date])
    rescue StandardError
      nil
    end
    redirect_to movies_path, alert: '日付の形式が不正です' and return if @date.nil?

    # スケジュール日付整合
    redirect_to movies_path, alert: 'スケジュールの日付と異なる日付です' and return if @date != @schedule.start_time.to_date

    # time パラメータ（任意）整合
    if params[:time].present?
      scheduled_time = @schedule.start_time.in_time_zone.strftime('%H:%M')
      if params[:time] != scheduled_time
        redirect_back fallback_location: movie_path(@movie),
                      alert: '指定された時間の上映はありません' and return
      end
    end

    # 画面表示用
    @theater = @schedule.screen&.theater
    @screen  = @schedule.screen

    # 座席一覧（スクリーン未設定でも落ちないように）
    @seats = @screen.present? ? @screen.sheets.order(:row, :column) : Sheet.none

    # 予約済みを seat_id => reservation にマッピング（空でも必ずハッシュ）
    if @seats.any?
      reserved = Reservation
        .where(schedule_id: @schedule.id, date: @date)
        .includes(:sheet)
      @reservation_by_seat_id = reserved.index_by(&:sheet_id) # 例: {3=>#<Reservation ...>, ...}
    else
      @reservation_by_seat_id = {}
    end

    # 互換の配列（既存ロジックで使っていれば）
    @reserved_seats = @reservation_by_seat_id.keys
  end
end
