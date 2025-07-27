module Admin
  class MoviesController < ApplicationController
    def index
      @movies = Movie.all
    end

    def new
      @movie = Movie.new
    end

    def edit # ✅ 追加
      @movie = Movie.find(params[:id])
    end

    def create
      @movie = Movie.new(movie_params) # ✅ 修正: params[:movie] を使わず、movie_params を利用
      if @movie.save
        redirect_to admin_movies_path, notice: '映画が登録されました'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @movie = Movie.find(params[:id])
      if @movie.update(movie_params)
        redirect_to admin_movies_path, notice: '映画が更新されました'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      redirect_to admin_movies_path, notice: '映画が削除されました'
    end

    private # ✅ Strong Parameters を追加

    def movie_params
      params.require(:movie).permit(:name, :year, :description, :image_url, :is_showing)
    end
  end
end
