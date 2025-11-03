# class AddScreenAndTimeRangeToSchedules < ActiveRecord::Migration[7.1]
#   def up
#     # まずは NULL 許可で追加（既存データがあっても落とさない）
#     add_reference :schedules, :screen, foreign_key: true, null: true unless column_exists?(:schedules, :screen_id)
#     add_column :schedules, :time_range, :tstzrange unless column_exists?(:schedules, :time_range)

#     # start_time / end_time から time_range を埋める（[開始, 終了)）
#     execute <<~SQL
#       UPDATE schedules
#       SET time_range = tstzrange(start_time, end_time, '[)')
#       WHERE time_range IS NULL AND start_time IS NOT NULL AND end_time IS NOT NULL;
#     SQL

#     # すべて埋まっているときだけ NOT NULL にする（安全策）
#     null_cnt = ActiveRecord::Base.connection.select_value('SELECT COUNT(*) FROM schedules WHERE time_range IS NULL').to_i
#     # change_column_null :schedules, :time_range, false if null_cnt == 0
#     change_column_null :schedules, :time_range, false if null_cnt.zero?
#     null_cnt = ActiveRecord::Base.connection.select_value('SELECT COUNT(*) FROM schedules WHERE screen_id IS NULL').to_i
#     # change_column_null :schedules, :screen_id, false if null_cnt == 0
#     change_column_null :schedules, :screen_id, false if null_cnt.zero?

#     # GiST index と EXCLUDE 制約（同一スクリーンの時間帯重複禁止）
#     add_index :schedules, :time_range, using: :gist unless index_exists?(:schedules, :time_range, using: :gist)
#     execute <<~SQL
#       DO $$
#       BEGIN
#         IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'schedules_no_overlap') THEN
#           ALTER TABLE schedules
#           ADD CONSTRAINT schedules_no_overlap
#           EXCLUDE USING gist (
#             screen_id  WITH =,
#             time_range WITH &&
#           );
#         END IF;
#       END
#       $$;
#     SQL
#   end

#   def down
#     execute 'ALTER TABLE schedules DROP CONSTRAINT IF EXISTS schedules_no_overlap;'
#     remove_index :schedules, :time_range if index_exists?(:schedules, :time_range)
#     remove_column :schedules, :time_range if column_exists?(:schedules, :time_range)
#     remove_reference :schedules, :screen, foreign_key: true if column_exists?(:schedules, :screen_id)
#   end
# end
# db/migrate/タイムスタンプ_add_screen_and_time_range_to_schedules.rb
# class AddScreenAndTimeRangeToSchedules < ActiveRecord::Migration[7.1]
#   def up
#     # screen_id 追加（既にあれば何もしない）
#     add_reference :schedules, :screen, foreign_key: true, null: true \
#       unless column_exists?(:schedules, :screen_id)

#     # time_range は MySQL には無いので作らない

#     # 既存データが NULL でなければ NOT NULL に変更
#     null_cnt = select_value('SELECT COUNT(*) FROM schedules WHERE screen_id IS NULL').to_i
#     change_column_null :schedules, :screen_id, false if null_cnt.zero?

#     # 同一 screen で時間帯が重なる予約を禁止するトリガー
#     execute 'DROP TRIGGER IF EXISTS schedules_no_overlap_insert;'
#     execute <<~SQL
#       CREATE TRIGGER schedules_no_overlap_insert
#       BEFORE INSERT ON schedules
#       FOR EACH ROW
#       BEGIN
#         IF NEW.screen_id IS NOT NULL AND NEW.start_time IS NOT NULL AND NEW.end_time IS NOT NULL THEN
#           IF EXISTS (
#             SELECT 1 FROM schedules
#             WHERE screen_id = NEW.screen_id
#               AND NEW.start_time < end_time
#               AND NEW.end_time   > start_time
#           ) THEN
#             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Overlapping schedule for this screen';
#           END IF;
#         END IF;
#       END;
#     SQL

#     execute 'DROP TRIGGER IF EXISTS schedules_no_overlap_update;'
#     execute <<~SQL
#       CREATE TRIGGER schedules_no_overlap_update
#       BEFORE UPDATE ON schedules
#       FOR EACH ROW
#       BEGIN
#         IF NEW.screen_id IS NOT NULL AND NEW.start_time IS NOT NULL AND NEW.end_time IS NOT NULL THEN
#           IF EXISTS (
#             SELECT 1 FROM schedules
#             WHERE screen_id = NEW.screen_id
#               AND id <> NEW.id
#               AND NEW.start_time < end_time
#               AND NEW.end_time   > start_time
#           ) THEN
#             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Overlapping schedule for this screen';
#           END IF;
#         END IF;
#       END;
#     SQL
#   end

#   def down
#     execute 'DROP TRIGGER IF EXISTS schedules_no_overlap_insert;'
#     execute 'DROP TRIGGER IF EXISTS schedules_no_overlap_update;'
#     remove_reference :schedules, :screen, foreign_key: true if column_exists?(:schedules, :screen_id)
#   end
# end
class AddScreenAndTimeRangeToSchedules < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # screen_id 追加（既にあればスキップ）
    add_reference :schedules, :screen, foreign_key: true, null: true \
      unless column_exists?(:schedules, :screen_id)

    # 時間の索引用インデックス
    add_index :schedules, %i[screen_id start_time end_time], name: 'idx_schedules_screen_time' \
      unless index_exists?(:schedules, %i[screen_id start_time end_time], name: 'idx_schedules_screen_time')

    # start_time < end_time の保護（MySQL 8.0+）
    begin
      execute <<~SQL
        ALTER TABLE schedules
        ADD CONSTRAINT chk_schedule_time CHECK (start_time < end_time)
      SQL
    rescue StandardError
      # 既にある / MySQLバージョンでCHECK無効 などは無視
    end

    # 既存データが全て埋まっていれば NOT NULL 化
    if column_exists?(:schedules, :screen_id)
      null_cnt = select_value('SELECT COUNT(*) FROM schedules WHERE screen_id IS NULL').to_i
      change_column_null :schedules, :screen_id, false if null_cnt.zero?
    end

    # 重複禁止（INSERT）
    execute 'DROP TRIGGER IF EXISTS schedules_no_overlap_insert;'
    execute <<~SQL
      CREATE TRIGGER schedules_no_overlap_insert
      BEFORE INSERT ON schedules
      FOR EACH ROW
      BEGIN
        IF NEW.screen_id IS NOT NULL AND NEW.start_time IS NOT NULL AND NEW.end_time IS NOT NULL THEN
          IF EXISTS (
            SELECT 1 FROM schedules
            WHERE screen_id = NEW.screen_id
              AND NEW.start_time < end_time
              AND NEW.end_time   > start_time
            LIMIT 1
          ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Overlapping schedule for this screen';
          END IF;
        END IF;
      END;
    SQL

    # 重複禁止（UPDATE）
    execute 'DROP TRIGGER IF EXISTS schedules_no_overlap_update;'
    execute <<~SQL
      CREATE TRIGGER schedules_no_overlap_update
      BEFORE UPDATE ON schedules
      FOR EACH ROW
      BEGIN
        IF NEW.screen_id IS NOT NULL AND NEW.start_time IS NOT NULL AND NEW.end_time IS NOT NULL THEN
          IF EXISTS (
            SELECT 1 FROM schedules
            WHERE screen_id = NEW.screen_id
              AND id <> NEW.id
              AND NEW.start_time < end_time
              AND NEW.end_time   > start_time
            LIMIT 1
          ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Overlapping schedule for this screen';
          END IF;
        END IF;
      END;
    SQL
  end

  def down
    execute 'DROP TRIGGER IF EXISTS schedules_no_overlap_insert;'
    execute 'DROP TRIGGER IF EXISTS schedules_no_overlap_update;'
    remove_index :schedules, name: 'idx_schedules_screen_time' if index_exists?(:schedules, name: 'idx_schedules_screen_time')
    begin
      execute 'ALTER TABLE schedules DROP CONSTRAINT chk_schedule_time'
    rescue StandardError
      # 無視
    end
    remove_reference :schedules, :screen, foreign_key: true if column_exists?(:schedules, :screen_id)
  end
end
