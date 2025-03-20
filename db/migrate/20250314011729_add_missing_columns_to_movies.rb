class AddMissingColumnsToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :year, :integer  # 公開年
    add_column :movies, :is_showing, :boolean, default: false  # 上映状況（デフォルト: false）
  end
end
