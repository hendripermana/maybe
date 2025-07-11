class Ui::ShadcnBadgeComponent < ViewComponent::Base
  def initialize(variant: :default, class_name: nil, **options)
    @variant = variant
    @class_name = class_name
    @options = options
  end

  private

  attr_reader :variant, :class_name, :options

  def badge_classes
    base_classes = "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
    
    variant_classes = case variant
    when :default
      "border-transparent bg-primary text-primary-foreground hover:bg-primary/80"
    when :secondary
      "border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80"
    when :destructive
      "border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80"
    when :outline
      "text-foreground"
    else
      "border-transparent bg-primary text-primary-foreground hover:bg-primary/80"
    end

    "#{base_classes} #{variant_classes} #{class_name}"
  end

  def html_attributes
    {
      class: badge_classes,
      **options
    }
  end
end 