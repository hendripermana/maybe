class FeedbackFormComponent < ViewComponent::Base
  attr_reader :feedback_types

  def initialize(position: :bottom_right, current_page: nil, current_user: nil)
    @position = position
    @current_page = current_page
    @current_user = current_user
    @feedback_types = UserFeedback.feedback_types.keys.map do |type|
      [ type.humanize, type ]
    end
  end

  def current_theme
    helpers.respond_to?(:current_theme) ? helpers.current_theme : "default"
  end

  def browser_info
    request&.user_agent
  end

  def current_page
    @current_page || request&.url
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
