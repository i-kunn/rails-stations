class Schedule < ApplicationRecord
  belongs_to :movie
  belongs_to :screen # ← 追加！

  has_many :reservations, dependent: :destroy
end
