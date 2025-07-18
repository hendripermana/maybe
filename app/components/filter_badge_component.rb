class FilterBadgeComponent < ViewComponent::Base
  attr_reader :label, :param_key, :param_value, :clear_url

  def initialize(label:, param_key:, param_value:, clear_url:)
    @label = label
    @param_key = param_key
    @param_value = param_value
    @clear_url = clear_url
  end

  def badge_classes
    "inline-flex items-center gap-1 px-2 py-1 rounded-md bg-gray-100 [data-theme=dark]:bg-gray-700 text-xs font-medium text-primary"
  end

  def button_classes
    "ml-1 text-gray-500 hover:text-gray-700 [data-theme=dark]:hover:text-gray-300 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-1 rounded-full"
  end
end