require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:theater)  { create(:theater) }
  let(:screen)   { create(:screen, theater:) }
  let(:movie)    { create(:movie) }
  let(:sheet)    { create(:sheet, screen:, row: 'B', column: 3) } # B3
  let(:schedule) { create(:schedule, movie:, screen:, start_time: Time.zone.parse('2025-08-15 18:00'), end_time: Time.zone.parse('2025-08-15 20:00')) }
  let(:date)     { Date.parse('2025-08-15') }

  it '同じ schedule×sheet×date は二重予約できない（モデル）' do
    create(:reservation, schedule:, sheet:, date:, name: 'A', email: 'a@example.com')

    dup = build(:reservation, schedule:, sheet:, date:, name: 'B', email: 'b@example.com')
    expect(dup).to be_invalid
    expect(dup.errors[:sheet_id]).to include('はこの上映日に既に予約されています')
  end

  it 'DB一意制約でもブロックされる（競合対策）' do
    create(:reservation, schedule:, sheet:, date:, name: 'A', email: 'a@example.com')

    expect do
      Reservation.insert_all!([{
                                schedule_id: schedule.id, sheet_id: sheet.id, date: date,
                                name: 'B', email: 'b@example.com',
                                created_at: Time.current, updated_at: Time.current
                              }])
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
  it 'date が違えば予約できる' do
    create(:reservation, schedule:, sheet:, date:, name: 'A', email: 'a@example.com')
    ok = build(:reservation, schedule:, sheet:, date: date + 1, name: 'B', email: 'b@example.com')
    expect(ok).to be_valid
  end
  it 'schedule が違えば予約できる' do
    other = create(:schedule, movie:, screen:,
                              start_time: Time.zone.parse('2025-08-15 21:00'),
                              end_time: Time.zone.parse('2025-08-15 23:00'))
    create(:reservation, schedule:, sheet:, date:, name: 'A', email: 'a@example.com')
    ok = build(:reservation, schedule: other, sheet:, date:, name: 'B', email: 'b@example.com')
    expect(ok).to be_valid
  end
end
