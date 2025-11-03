# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
# Sheet.create!([
#                 { id: 1, column: 1, row: 'a' },
#                 { id: 2, column: 2, row: 'a' },
#                 { id: 3, column: 3, row: 'a' },
#                 { id: 4, column: 4, row: 'a' },
#                 { id: 5, column: 5, row: 'a' },
#                 { id: 6, column: 1, row: 'b' },
#                 { id: 7, column: 2, row: 'b' },
#                 { id: 8, column: 3, row: 'b' },
#                 { id: 9, column: 4, row: 'b' },
#                 { id: 10, column: 5, row: 'b' },
#                 { id: 11, column: 1, row: 'c' },
#                 { id: 12, column: 2, row: 'c' },
#                 { id: 13, column: 3, row: 'c' },
#                 { id: 14, column: 4, row: 'c' },
#                 { id: 15, column: 5, row: 'c' }
#               ])
# 劇場
theater = Theater.find_or_create_by!(name: '名古屋シネマ')
theater2 = Theater.find_or_create_by!(name: '東京シネマ')
theater3 = Theater.find_or_create_by!(name: '大阪シネマ')

# スクリーン
screen1 = Screen.find_or_create_by!(theater: theater, name: 'スクリーン1')
screen2 = Screen.find_or_create_by!(theater: theater2, name: 'スクリーン2')
screen3 = Screen.find_or_create_by!(theater: theater3, name: 'スクリーン3')
# 座席（3x5）
('A'..'C').each do |row|
  (1..5).each do |col|
    Sheet.find_or_create_by!(screen: screen1, row:, column: col)
    Sheet.find_or_create_by!(screen: screen2, row:, column: col)
    Sheet.find_or_create_by!(screen: screen3, row:, column: col)
  end
end

# ========================
# 映画とスケジュール
# ========================

# ドラえもん（スケジュールあり）
dora = Movie.find_or_create_by!(name: 'ドラえもん') do |m|
  m.is_showing  = true
  m.year        = '2025'
  m.description = 'seedテスト用'
end

s1 = Schedule.find_or_create_by!(
  movie: dora, screen: screen1,
  start_time: Time.zone.parse('2025-08-15 18:00'),
  end_time: Time.zone.parse('2025-08-15 20:00')
)

Schedule.find_or_create_by!(
  movie: dora, screen: screen2,
  start_time: Time.zone.parse('2025-08-15 19:00'),
  end_time: Time.zone.parse('2025-08-15 21:00')
)

# 名探偵コナン
conan = Movie.find_or_create_by!(name: '名探偵コナン') do |m|
  m.is_showing  = true
  m.year        = '2025'
  m.description = 'seedテスト用'
end

s_conan = Schedule.find_or_create_by!(
  movie: conan, screen: screen1,
  start_time: Time.zone.parse('2025-09-20 18:00'),
  end_time: Time.zone.parse('2025-09-20 20:00')
)

# ワンピース
onep = Movie.find_or_create_by!(name: 'ワンピース') do |m|
  m.is_showing  = true
  m.year        = '2025'
  m.description = 'seedテスト用'
end

s_onep = Schedule.find_or_create_by!(
  movie: onep, screen: screen2,
  start_time: Time.zone.parse('2025-09-21 19:00'),
  end_time: Time.zone.parse('2025-09-21 21:00')
)

# 上映未定作品（スケジュールなし → 空メッセージ確認用）
Movie.find_or_create_by!(name: '上映未定作品') do |m|
  m.is_showing  = false
  m.year        = '2026'
  m.description = 'スケジュールがまだありません（空状態テスト用）'
end

# ========================
# サンプル予約データ
# ========================

# スクリーンごとの座席
seat1_s1 = Sheet.find_by!(screen: screen1, row: 'A', column: 1)
seat2_s1 = Sheet.find_by!(screen: screen1, row: 'A', column: 2)
seat1_s2 = Sheet.find_by!(screen: screen2, row: 'A', column: 1)
Sheet.find_by!(screen: screen2, row: 'A', column: 2)

# ドラえもん: B3を8/15で予約済みに
seat_b3 = Sheet.find_by!(screen: screen1, row: 'B', column: 3)
Reservation.find_or_create_by!(
  schedule: s1, sheet: seat_b3, date: Date.parse('2025-08-15')
) do |r|
  r.name  = 'テストユーザー'
  r.email = 'test@example.com'
end

# ドラえもん: 10件
10.times do |i|
  Reservation.find_or_create_by!(
    schedule: s1, sheet: seat1_s1, date: Date.current - i
  ) do |r|
    r.name  = "ドラえもんユーザー#{i}"
    r.email = "dora#{i}@example.com"
  end
end

# コナン: 5件
5.times do |i|
  Reservation.find_or_create_by!(
    schedule: s_conan, sheet: seat2_s1, date: Date.current - i
  ) do |r|
    r.name  = "コナンユーザー#{i}"
    r.email = "conan#{i}@example.com"
  end
end

# ワンピース: 20件
20.times do |i|
  Reservation.find_or_create_by!(
    schedule: s_onep, sheet: seat1_s2, date: Date.current - i
  ) do |r|
    r.name  = "ワンピースユーザー#{i}"
    r.email = "onep#{i}@example.com"
  end
end

# ========================
# 空状態テスト用（座席ゼロ / 指定時間に上映なし）
# ========================

# 座席を一切作らないスクリーン（座席ゼロ検証用）
screen3 = Screen.find_or_create_by!(theater: theater, name: 'スクリーン3（座席なし）')

# ワンピースを screen3 で上映（でも座席が無いので座席表は空状態になる）
Schedule.find_or_create_by!(
  movie: onep, screen: screen3,
  start_time: Time.zone.parse('2025-09-22 04:00'),
  end_time: Time.zone.parse('2025-09-22 06:00')
)
Schedule.find_or_create_by!(
  movie: onep, screen: screen3,
  start_time: Time.zone.parse('2025-09-22 09:00'),
  end_time: Time.zone.parse('2025-09-22 11:00')
)
# db/seeds.rb
# TZ を合わせたい場合は config/application.rb 側で config.time_zone を設定しておく
# ここでは Time.zone.parse を使います

puts '== Create Theaters =='
nagoya = Theater.find_or_create_by!(name: '名古屋シネマ')
osaka  = Theater.find_or_create_by!(name: '大阪シネマ')
tokyo  = Theater.find_or_create_by!(name: '東京シネマ')

# 3x5 の座席を作るユーティリティ
def ensure_seats(screen, rows: ('A'..'C'), cols: (1..5))
  rows.each do |row|
    cols.each do |col|
      Sheet.find_or_create_by!(screen:, row:, column: col)
    end
  end
end

# 劇場ごとにスクリーンを作る（スクリーン3は“座席なし”検証用）
def build_screens_for(theater)
  s1 = Screen.find_or_create_by!(theater:, name: 'スクリーン1')
  s2 = Screen.find_or_create_by!(theater:, name: 'スクリーン2')
  s3 = Screen.find_or_create_by!(theater:, name: 'スクリーン3（座席なし）')

  ensure_seats(s1)
  ensure_seats(s2)
  # s3 は座席を作らない（空状態テスト用）

  { s1:, s2:, s3: }
end

puts '== Create Screens & Seats =='
screens_by_theater = {
  nagoya => build_screens_for(nagoya),
  osaka => build_screens_for(osaka),
  tokyo => build_screens_for(tokyo)
}

puts '== Create Movies =='
dora  = Movie.find_or_create_by!(name: 'ドラえもん') do
  _1.is_showing = true
  _1.year = '2025'
  _1.description = 'seedテスト用'
end
conan = Movie.find_or_create_by!(name: '名探偵コナン') do
  _1.is_showing = true
  _1.year = '2025'
  _1.description = 'seedテスト用'
end
onep = Movie.find_or_create_by!(name: 'ワンピース') do
  _1.is_showing = true
  _1.year = '2025'
  _1.description = 'seedテスト用'
end

Movie.find_or_create_by!(name: '上映未定作品') do
  _1.is_showing = false
  _1.year = '2026'
  _1.description = 'スケジュールがまだありません（空テスト）'
end

# ===== 劇場ごとの“3パターン” =====
# P1(名古屋): ドラ18-20 / コナン19-21 / ワンピ20-22
# P2(大阪)  : ドラ17-19 / コナン20-22 / ワンピ08-10（座席なしスクリーンで空表示も確認）
# P3(東京)  : ドラ09-11 / コナン12-14 / ワンピ15-17
#
# ※ 日付は被っていてもOK。座席はスクリーンに紐づくので同名映画でも theater 単位で独立。

puts '== Create Schedules =='
# 名古屋（P1）
ng = screens_by_theater[nagoya]
s1_dora  = Schedule.find_or_create_by!(movie: dora,  screen: ng[:s1],
                                       start_time: Time.zone.parse('2025-09-20 13:00'), end_time: Time.zone.parse('2025-09-20 14:00'))
s1_conan = Schedule.find_or_create_by!(movie: conan, screen: ng[:s1],
                                       start_time: Time.zone.parse('2025-09-20 14:00'), end_time: Time.zone.parse('2025-09-20 15:00'))
s2_onep  = Schedule.find_or_create_by!(movie: onep,  screen: ng[:s2],
                                       start_time: Time.zone.parse('2025-09-20 20:00'), end_time: Time.zone.parse('2025-09-20 22:00'))
# 座席なしスクリーンでも一応1本入れて空表示確認用
Schedule.find_or_create_by!(movie: onep, screen: ng[:s3],
                            start_time: Time.zone.parse('2025-09-22 04:00'), end_time: Time.zone.parse('2025-09-22 06:00'))

# 大阪（P2）
os = screens_by_theater[osaka]
Schedule.find_or_create_by!(movie: dora,  screen: os[:s1],
                            start_time: Time.zone.parse('2025-09-21 17:00'), end_time: Time.zone.parse('2025-09-21 19:00'))
Schedule.find_or_create_by!(movie: conan, screen: os[:s2],
                            start_time: Time.zone.parse('2025-09-21 20:00'), end_time: Time.zone.parse('2025-09-21 22:00'))
Schedule.find_or_create_by!(movie: onep,  screen: os[:s3], # ← 座席なしで空表示
                            start_time: Time.zone.parse('2025-09-21 08:00'), end_time: Time.zone.parse('2025-09-21 10:00'))

# 東京（P3）
tk = screens_by_theater[tokyo]
Schedule.find_or_create_by!(movie: dora,  screen: tk[:s1],
                            start_time: Time.zone.parse('2025-09-22 09:00'), end_time: Time.zone.parse('2025-09-22 11:00'))
Schedule.find_or_create_by!(movie: conan, screen: tk[:s1],
                            start_time: Time.zone.parse('2025-09-22 12:00'), end_time: Time.zone.parse('2025-09-22 14:00'))
Schedule.find_or_create_by!(movie: onep,  screen: tk[:s2],
                            start_time: Time.zone.parse('2025-09-22 15:00'), end_time: Time.zone.parse('2025-09-22 17:00'))

puts '== Sample Reservations =='
# 名古屋のドラえもん: B3 を 9/20 で予約済みに
b3_ng = Sheet.find_by!(screen: ng[:s1], row: 'B', column: 3)
Reservation.find_or_create_by!(schedule: s1_dora, sheet: b3_ng, date: Date.parse('2025-09-20')) do |r|
  r.name = 'テストユーザー'
  r.email = 'test@example.com'
end

# 過去N日分ダミー（名古屋・ドラ）
seat_a1_ng = Sheet.find_by!(screen: ng[:s1], row: 'A', column: 1)
10.times do |i|
  Reservation.find_or_create_by!(schedule: s1_dora, sheet: seat_a1_ng, date: Date.current - i) do |r|
    r.name = "ドラえもんユーザー#{i}"
    r.email = "dora#{i}@example.com"
  end
end

# コナン（名古屋）
seat_a2_ng = Sheet.find_by!(screen: ng[:s1], row: 'A', column: 2)
5.times do |i|
  Reservation.find_or_create_by!(schedule: s1_conan, sheet: seat_a2_ng, date: Date.current - i) do |r|
    r.name = "コナンユーザー#{i}"
    r.email = "conan#{i}@example.com"
  end
end

# ワンピース（名古屋・スクリーン2）
seat_a1_ng2 = Sheet.find_by!(screen: ng[:s2], row: 'A', column: 1)
20.times do |i|
  Reservation.find_or_create_by!(schedule: s2_onep, sheet: seat_a1_ng2, date: Date.current - i) do |r|
    r.name = "ワンピースユーザー#{i}"
    r.email = "onep#{i}@example.com"
  end
end
# ========================
# 🎯 キャンセル機能テスト用データ（上映が未来）
# ========================
puts '== Create Future Schedule for Cancel Test =='

# 名古屋シネマのスクリーン1を使用
cancel_test_movie = Movie.find_or_create_by!(name: 'キャンセルテスト用映画') do |m|
  m.is_showing  = true
  m.year        = '2025'
  m.description = 'キャンセルボタン表示確認用'
end

future_schedule = Schedule.find_or_create_by!(
  movie: cancel_test_movie,
  screen: ng[:s1],
  start_time: Time.zone.now + 5.hours, # 現在から5時間後
  end_time: Time.zone.now + 7.hours # 上映時間2時間
)

# 任意の座席を1つ取得（A1）
test_sheet = Sheet.find_by!(screen: ng[:s1], row: 'A', column: 1)

# 今日の日付で予約を作成
Reservation.find_or_create_by!(
  schedule: future_schedule,
  sheet: test_sheet,
  date: Date.current
) do |r|
  r.name  = 'キャンセルテストユーザー'
  r.email = 'cancel@example.com'
end

puts '🎬 未来上映テスト用のスケジュールを作成しました！'
puts "上映開始時刻: #{future_schedule.start_time}"
