class AddTheaterRefToScreens < ActiveRecord::Migration[7.1]
  def change
    add_reference :screens, :theater, null: false, foreign_key: true
  end
end
