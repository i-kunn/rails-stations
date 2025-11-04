# app/components/movies/rankings_component.rb
class Movies::RankingsComponent < ViewComponent::Base
  def initialize(rankings:, target_date:)
    @rankings    = rankings
    @target_date = target_date
  end
end
