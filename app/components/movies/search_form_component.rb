class Movies::SearchFormComponent < ViewComponent::Base
  def initialize(keyword:, is_showing:)
    @keyword    = keyword
    @is_showing = is_showing
  end

  def all_selected? = @is_showing.blank?
  def showing?      = @is_showing == "1"
  def upcoming?     = @is_showing == "0"
end
