namespace :ranking do
  desc "過去30日間の予約数を作品ごとに集計して movie_rankings に保存（本日分）"
  task update: :environment do
    start_date = 30.days.ago.to_date
    end_date   = Date.current

    counts = Reservation
               .joins(schedule: :movie)
               .where(date: start_date..end_date)
               .group('schedules.movie_id')
               .count

    puts "Aggregating from #{start_date} to #{end_date} ..."

    counts.each do |movie_id, total|
      ranking = MovieRanking.find_or_initialize_by(
        movie_id: movie_id,
        date: Date.current
      )
      ranking.total_reservations = total
      ranking.save!
    end

    puts "Saved #{counts.size} rows into movie_rankings for #{Date.current}"
  end
end
