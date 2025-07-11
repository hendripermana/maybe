class Ui::ShadcnAlertComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_one :title
  renders_one :description

  def initialize(variant: :default, class_name: nil, **options)
    @variant = variant
    @class_name = class_name
    @options = options
  end

  private

  attr_reader :variant, :class_name, :options

  def alert_classes
    base_classes = "relative w-full rounded-lg border p-4 [&>svg~*]:pl-7 [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:text-foreground"
    
    variant_classes = case variant
    when :default
      "bg-background text-foreground"
    when :destructive
      "border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive"
    else
      "bg-background text-foreground"
    end

    "#{base_classes} #{variant_classes} #{class_name}"
  end

  def html_attributes
    {
      class: alert_classes,
      role: "alert",
      **options
    }
  end
end 