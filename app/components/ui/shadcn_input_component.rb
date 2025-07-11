class Ui::ShadcnInputComponent < ViewComponent::Base
  def initialize(type: :text, disabled: false, class_name: nil, **options)
    @type = type
    @disabled = disabled
    @class_name = class_name
    @options = options
  end

  private

  attr_reader :type, :disabled, :class_name, :options

  def input_classes
    base_classes = "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
    "#{base_classes} #{class_name}"
  end

  def html_attributes
    {
      type: type,
      class: input_classes,
      disabled: disabled,
      **options
    }
  end
end 