class Ui::ShadcnButtonComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_one :icon

  def initialize(variant: :default, size: :default, disabled: false, **options)
    @variant = variant
    @size = size
    @disabled = disabled
    @options = options
  end

  private

  attr_reader :variant, :size, :disabled, :options

  def classes
    base_classes = "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"
    
    variant_classes = case variant
    when :default
      "bg-primary text-primary-foreground hover:bg-primary/90"
    when :destructive
      "bg-destructive text-destructive-foreground hover:bg-destructive/90"
    when :outline
      "border border-input bg-background hover:bg-accent hover:text-accent-foreground"
    when :secondary
      "bg-secondary text-secondary-foreground hover:bg-secondary/80"
    when :ghost
      "hover:bg-accent hover:text-accent-foreground"
    when :link
      "text-primary underline-offset-4 hover:underline"
    else
      "bg-primary text-primary-foreground hover:bg-primary/90"
    end

    size_classes = case size
    when :default
      "h-10 px-4 py-2"
    when :sm
      "h-9 rounded-md px-3"
    when :lg
      "h-11 rounded-md px-8"
    when :icon
      "h-10 w-10"
    else
      "h-10 px-4 py-2"
    end

    "#{base_classes} #{variant_classes} #{size_classes}"
  end

  def html_attributes
    {
      class: classes,
      disabled: disabled,
      **options
    }
  end
end 