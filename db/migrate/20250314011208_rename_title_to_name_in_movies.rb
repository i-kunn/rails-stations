class RenameTitleToNameInMovies < ActiveRecord::Migration[7.1]
  def change
    rename_column :movies, :title, :name  # ✅ `title` を `name` に変更
  end
end

