require 'rails_helper'

RSpec.describe Reservation, type: :model do
  it '同一上映×同一座席は二重予約できない' do
    schedule = create(:schedule)
    seat = Seat.find_by!(seat_code: 'B3') # ← spec/support/seat_master.rb で投入済み

    Reservation.create!(schedule:, seat:)      # 1回目OK
    dup = Reservation.new(schedule:, seat:)    # 2回目NG

    expect(dup.valid?).to be(false)
    expect { dup.save! }.to raise_error(ActiveRecord::RecordInvalid)
      .or raise_error(ActiveRecord::RecordNotUnique)
  end
end
