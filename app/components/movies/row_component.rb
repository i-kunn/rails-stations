# app/components/movies/row_component.rb
class Movies::RowComponent < ViewComponent::Base
  def initialize(movie:)
    @movie = movie
  end

  def status_label
    @movie.is_showing ? '上映中' : '公開予定'
  end
end
