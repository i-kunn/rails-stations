class Admin::SchedulesController < ApplicationController
  # class Admin::SchedulesController < ApplicationController
  before_action :set_schedule, only: %i[edit update destroy]

  def index
    @schedules = Schedule.includes(:movie).all
  end

  def edit; end

  def update
    if @schedule.update(schedule_params)
      redirect_to admin_schedules_path, notice: 'スケジュールを更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @schedule.destroy
    redirect_to admin_schedules_path, notice: 'スケジュールを削除しました。'
  end

  private

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  def schedule_params
    params.require(:schedule).permit(:movie_id, :start_time, :end_time)
  end
end
