class Movie < ApplicationRecord
  scope :search_by_keyword, ->(keyword) {
    return all if keyword.blank?
    where("name LIKE :q OR description LIKE :q", q: "%#{keyword}%")
  }

  has_many :schedules
end
