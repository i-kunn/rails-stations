# app/components/movies/table_component.rb
class Movies::TableComponent < ViewComponent::Base
  def initialize(movies:)
    @movies = movies
  end
end
