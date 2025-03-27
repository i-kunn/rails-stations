class ReservationsController < ApplicationController
    def create
      reservation = Reservation.new(reservation_params)
  
      if reservation.save
        head :ok
      else
        head :internal_server_error
      end
    end
  
    private
  
    def reservation_params
      params.require(:reservation).permit(:schedule_id, :sheet_id, :name, :email, :date)
    end
  end
  def new
    @movie = Movie.find(params[:movie_id])
    @schedule = Schedule.find(params[:schedule_id])
    @sheet = Sheet.find(params[:sheet_id])
    @date = params[:date]
  
    @reservation = Reservation.new(
      movie: @movie,
      schedule: @schedule,
      sheet: @sheet,
      date: @date
    )
  end
    

  def create
    @reservation = Reservation.new(reservation_params)

    if @reservation.save
      redirect_to movies_path, notice: "予約が完了しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(:schedule_id, :sheet_id, :name, :email, :date)
  end
end
  