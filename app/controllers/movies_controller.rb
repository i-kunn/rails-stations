class MoviesController < ApplicationController
  def index
    @movies = Movie.all
    params[:is_showing] = "" if params[:is_showing].blank?
    

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
    @movie = Movie.find(params[:id])
    @sheets = Sheet.all
    @date = params[:date]
  
    # date, schedule_id がない場合は redirect
    if @date.blank? || params[:schedule_id].blank?
      redirect_to movies_path, alert: "不正なアクセスです"
      return
    end
  
    @schedule = Schedule.find_by(id: params[:schedule_id])
  end  
end

