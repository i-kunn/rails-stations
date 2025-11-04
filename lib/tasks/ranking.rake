namespace :ranking do
  desc '過去30日間の予約数を作品ごとに集計して movie_rankings に保存（本日分）'
  task update: :environment do
    target     = Date.current
    start_date = target - 30 # 30日前
    end_date   = target - 1

    counts = Reservation
      .joins(schedule: :movie)
      .where(date: start_date..end_date)
      .where(movies: { is_showing: true })
      .group('schedules.movie_id')
      .count
    # 開発ログ
    puts "Aggregating from #{start_date} to #{end_date} ..."

    counts.each do |movie_id, total|
      ranking = MovieRanking.find_or_initialize_by(
        movie_id: movie_id,
        date: target
      )
      ranking.total_reservations = total
      ranking.save!
    end
    # 開発ログ
    puts "Saved #{counts.size} rows into movie_rankings for #{Date.current}"
  end
end
