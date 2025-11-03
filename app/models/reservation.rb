class Reservation < ApplicationRecord
  belongs_to :schedule
  belongs_to :sheet

  validates :schedule_id, :sheet_id, :name, :email, :date, presence: { message: 'を入力してください' }
  validate :sheet_belongs_to_schedule_screen

  validates :email, format: {
    with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/,
    message: 'は有効なメールアドレス形式で入力してください'
  }

  validates :sheet_id, uniqueness: {
    scope: %i[schedule_id date],
    message: 'はすでに予約されています'
  }

  def sheet_belongs_to_schedule_screen
    return if sheet.blank? || schedule.blank?

    return unless sheet.screen_id != schedule.screen_id

    errors.add(:sheet_id, 'の座席はこのスケジュールのスクリーンに属していません')
  end
end
