class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.date :date, null: false
      t.integer :schedule_id, null: false
      t.integer :sheet_id, null: false
      t.string :email, null: false, limit: 255, comment: '予約者メールアドレス'
      t.string :name, null: false, comment: '予約者名'
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :reservations, :schedule_id, name: 'reservation_schedule_id_idx'
    add_index :reservations, :sheet_id, name: 'reservation_sheet_id_idx'
    add_index :reservations, [:date, :schedule_id, :sheet_id], unique: true, name: 'reservation_schedule_sheet_unique'

    add_foreign_key :reservations, :schedules, column: :schedule_id
    add_foreign_key :reservations, :sheets, column: :sheet_id
  end
end

