class Reservation < ApplicationRecord
    belongs_to :schedule
    belongs_to :sheet
  
    validates :schedule_id, :sheet_id, :name, :email, :date, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  end
  