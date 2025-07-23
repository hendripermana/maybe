class FeedbackFormComponent < ViewComponent::Base
  def initialize(position: :bottom_right, theme: nil)
    @position = position
    @theme = theme
  end
  
  private
  
  def position_classes
    case @position
    when :bottom_right
      "bottom-4 right-4"
    when :bottom_left
      "bottom-4 left-4"
    when :top_right
      "top-4 right-4"
    when :top_left
      "top-4 left-4"
    else
      "bottom-4 right-4"
    end
  end
end