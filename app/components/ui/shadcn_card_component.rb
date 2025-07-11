class Ui::ShadcnCardComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_one :header
  renders_one :content
  renders_one :footer

  def initialize(class_name: nil)
    @class_name = class_name
  end

  private

  attr_reader :class_name

  def card_classes
    "rounded-lg border bg-card text-card-foreground shadow-sm #{class_name}"
  end

  def header_classes
    "flex flex-col space-y-1.5 p-6"
  end

  def content_classes
    "p-6 pt-0"
  end

  def footer_classes
    "flex items-center p-6 pt-0"
  end
end 