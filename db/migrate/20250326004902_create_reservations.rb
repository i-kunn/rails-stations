class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.date :date, null: false
      t.references :schedule, null: false, foreign_key: true
      t.references :sheet, null: false, foreign_key: true
      t.string :email, null: false, limit: 255, comment: '予約者メールアドレス'
      t.string :name, null: false, comment: '予約者名'
      t.timestamps null: false
    end

    # add_foreign_key は不要（↑でforeign_key: trueにしてるから）
    # add_foreign_key :reservations, :schedules ← 消す
    # add_foreign_key :reservations, :sheets ← 消す
  end
end


