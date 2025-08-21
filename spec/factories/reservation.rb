# FactoryBot.define do
#   factory :reservation do
#     association :schedule, factory: :schedule
#     association :sheet, factory: :sheet
#     sequence(:name) { |n| "TEST_USER#{n}" }
#     sequence(:email) { |n| "test_email#{n}@test.com" }
#     sequence(:date) { |n| "2019-04-1#{n}" }

#   end
# end
# spec/factories/reservations.rb  （←ファイル名は複数形が一般的）
FactoryBot.define do
  factory :reservation do
    association :schedule, factory: :schedule
    seat   { Seat.find_by!(seat_code: 'B3') } # 共通3x5マスタから取得
    status { 'reserved' }
  end
end
