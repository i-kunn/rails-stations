# db/migrate/XXXXXXXXXXXXXX_enforce_integrity_and_uniqueness.rb
class EnforceIntegrityAndUniqueness < ActiveRecord::Migration[7.1]
  def up
    # ---- NOT NULL（足りない所だけ締める）----
    change_column_null :screens,   :theater_id, false if column_exists?(:screens, :theater_id)
    change_column_null :schedules, :screen_id,  false if column_exists?(:schedules, :screen_id)
    # （schedules.movie_id / reservations.* は既に null: false ならスキップでOK）

    # ---- 外部キー（なければ追加、削除は restrict）----
    add_foreign_key :screens,   :theaters,  on_delete: :restrict unless foreign_key_exists?(:screens,   :theaters)
    add_foreign_key :schedules, :movies,    on_delete: :restrict unless foreign_key_exists?(:schedules, :movies)
    add_foreign_key :schedules, :screens,   on_delete: :restrict unless foreign_key_exists?(:schedules, :screens)
    add_foreign_key :reservations, :schedules, on_delete: :restrict unless foreign_key_exists?(:reservations, :schedules)
    add_foreign_key :reservations, :sheets,    on_delete: :restrict unless foreign_key_exists?(:reservations, :sheets)

    # ---- 予約の一意制約（三つ組み）----
    add_index :reservations, [:schedule_id, :sheet_id, :date],
              unique: true, name: "idx_reservations_unique_triplet" unless
              index_exists?(:reservations, [:schedule_id, :sheet_id, :date], unique: true, name: "idx_reservations_unique_triplet")
  end

  def down
    remove_index :reservations, name: "idx_reservations_unique_triplet" rescue nil

    remove_foreign_key :reservations, :sheets    rescue nil
    remove_foreign_key :reservations, :schedules rescue nil
    remove_foreign_key :schedules,   :screens   rescue nil
    remove_foreign_key :schedules,   :movies    rescue nil
    remove_foreign_key :screens,     :theaters  rescue nil

    change_column_null :schedules, :screen_id,  true  rescue nil
    change_column_null :screens,   :theater_id, true  rescue nil
  end
end

