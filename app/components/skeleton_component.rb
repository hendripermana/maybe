class SkeletonComponent < ViewComponent::Base
  attr_reader :variant, :width, :height, :classes

  VARIANTS = {
    circle: "rounded-full",
    rectangle: "rounded-md",
    text: "rounded-md h-4"
  }.freeze

  def initialize(variant: :rectangle, width: nil, height: nil, classes: nil)
    @variant = variant.to_sym
    @width = width
    @height = height
    @classes = classes
  end

  def skeleton_classes
    class_names(
      "animate-pulse bg-gray-200 [data-theme=dark]:bg-gray-700",
      VARIANTS[variant],
      classes
    )
  end

  def style
    styles = []
    styles << "width: #{width};" if width
    styles << "height: #{height};" if height
    styles.join(" ")
  end
end
