class Ui::ShadcnDialogComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_one :trigger
  renders_one :header
  renders_one :content
  renders_one :footer

  def initialize(open: false, class_name: nil, **options)
    @open = open
    @class_name = class_name
    @options = options
  end

  private

  attr_reader :open, :class_name, :options

  def dialog_classes
    "fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background p-6 shadow-lg duration-200 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%] data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%] sm:rounded-lg #{class_name}"
  end

  def overlay_classes
    "fixed inset-0 z-50 bg-background/80 backdrop-blur-sm data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0"
  end

  def header_classes
    "flex flex-col space-y-1.5 text-center sm:text-left"
  end

  def content_classes
    "relative flex-1"
  end

  def footer_classes
    "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2"
  end

  def html_attributes
    {
      class: dialog_classes,
      data: { controller: "shadcn-dialog" },
      **options
    }
  end
end 