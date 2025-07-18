class UI::ProgressBarComponent < ViewComponent::Base
  VARIANTS = {
    default: "bg-primary",
    success: "bg-green-500",
    warning: "bg-yellow-500",
    danger: "bg-red-500"
  }.freeze

  SIZES = {
    sm: "h-1.5",
    md: "h-2",
    lg: "h-3"
  }.freeze

  def initialize(value: 0, max: 100, variant: :default, size: :md, animated: true, **options)
    @value = value.to_f
    @max = max.to_f
    @variant = variant
    @size = size
    @animated = animated
    @options = options
  end

  def percent
    return 0 if @max.zero?
    
    # Ensure percent is between 0 and 100
    [(@value / @max * 100).round, 100].min
  end

  def progress_classes
    [
      VARIANTS[@variant] || VARIANTS[:default],
      @animated ? "transition-all duration-300 ease-in-out" : "",
      @options[:progress_class]
    ].compact.join(" ")
  end

  def container_classes
    [
      "w-full bg-muted rounded-full overflow-hidden",
      SIZES[@size] || SIZES[:md],
      @options[:class]
    ].compact.join(" ")
  end
end