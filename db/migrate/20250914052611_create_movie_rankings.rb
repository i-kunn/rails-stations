class CreateMovieRankings < ActiveRecord::Migration[7.1]
  def change
    create_table :movie_rankings do |t|
      t.references :movie, null: false, foreign_key: true
      t.integer :total_reservations, null: false, default: 0
      t.date :date, null: false
      t.timestamps
    end
    add_index :movie_rankings, %i[date movie_id], unique: true
  end
end
