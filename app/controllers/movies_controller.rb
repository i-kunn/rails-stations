class MoviesController < ApplicationController
  def index
    @movies = Movie.all
    params[:is_showing] = '' if params[:is_showing].blank?

    if params[:keyword].present?
      @movies = Movie
                .search_by_keyword(params[:keyword])
    end
    if params[:is_showing].present?
      is_showing_value = params[:is_showing].to_i
      if is_showing_value == 1
        @movies = @movies.where(is_showing: true)
      elsif is_showing_value == 0
        @movies = @movies.where(is_showing: false)
      end
    end
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @movies }
    end
  end

  def show
    @movie = Movie.find(params[:id])
    @schedules = @movie.schedules
  end

  def reservation
    # 1. 映画の取得（:id が Movie.id という想定）
    @movie = Movie.find(params[:id])
    @seats = Sheet.all

    # 2. パラメータ schedule_id と date が無い場合はリダイレクト
    if params[:schedule_id].blank? || params[:date].blank?
      redirect_to movies_path, alert: 'スケジュールIDと日付が必要です'
      return
    end

    # 3. スケジュールが見つからなければエラーまたはリダイレクト
    @schedule = Schedule.find_by(id: params[:schedule_id])
    if @schedule.nil?
      redirect_to movies_path, alert: '指定されたスケジュールがありません'
      return
    end

    # 4. 座席テーブル (sheets) の取得
    @sheets = Sheet.all

    # 5. 予約済み座席の情報取得
    #    たとえば reservationsテーブルから sheet_id を配列で抜き出す
    @reserved_seats = Reservation.where(
      schedule_id: params[:schedule_id],
      date: params[:date]
    ).pluck(:sheet_id)

    # 6. reservation.html.erb を表示
    render :reservation
  end
end
