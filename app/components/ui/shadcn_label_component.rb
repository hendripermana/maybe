class Ui::ShadcnLabelComponent < ViewComponent::Base
  def initialize(for_attribute: nil, class_name: nil, **options)
    @for_attribute = for_attribute
    @class_name = class_name
    @options = options
  end

  private

  attr_reader :for_attribute, :class_name, :options

  def label_classes
    base_classes = "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
    "#{base_classes} #{class_name}"
  end

  def html_attributes
    {
      class: label_classes,
      for: for_attribute,
      **options
    }
  end
end 