class Reservation < ApplicationRecord
  belongs_to :schedule
  belongs_to :sheet

  validates :schedule_id, :sheet_id, :name, :email, :date, presence: true

  validates :email, format: {
    with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/,
    message: 'は有効なメールアドレス形式で入力してください'
  }

  validates :sheet_id, uniqueness: {
    scope: %i[schedule_id date],
    message: 'はすでに予約されています'
  }
end
