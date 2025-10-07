class Screen < ApplicationRecord
  belongs_to :theater 
  has_many :sheets
end
