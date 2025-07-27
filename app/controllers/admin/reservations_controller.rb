# ファイル: app/controllers/admin/reservations_controller.rb
class Admin::ReservationsController < ApplicationController
  def index
    @reservations = Reservation.joins(:schedule)
                               .where('schedules.end_time > ?', Time.current)
                               .includes(:schedule, :sheet)
                               .order(:date, 'schedules.start_time')
  end

  def new
    @reservation = Reservation.new
  end

  def show
    @reservation = Reservation.find(params[:id])
  end

  def create
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      redirect_to admin_reservations_path, notice: '予約が完了しました'
    else
      head :bad_request # ← ここがポイント！
    end
  end

  def edit
    @reservation = Reservation.find(params[:id])
  end

  def update
    @reservation = Reservation.find(params[:id])
    if @reservation.update(reservation_params)
      redirect_to admin_reservations_path, notice: '予約を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reservation = Reservation.find(params[:id])
    @reservation.destroy
    redirect_to admin_reservations_path, notice: '予約を削除しました'
  end

  private

  def reservation_params
    params.require(:reservation).permit(:schedule_id, :sheet_id, :name, :email, :date)
  end
end
