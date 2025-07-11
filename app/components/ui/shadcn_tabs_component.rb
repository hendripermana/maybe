class Ui::ShadcnTabsComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_many :tabs, "TabComponent"

  def initialize(default_value: nil, class_name: nil, **options)
    @default_value = default_value
    @class_name = class_name
    @options = options
  end

  private

  attr_reader :default_value, :class_name, :options

  def tabs_classes
    "inline-flex h-10 items-center justify-center rounded-md bg-muted p-1 text-muted-foreground #{class_name}"
  end

  def html_attributes
    {
      class: tabs_classes,
      data: { controller: "shadcn-tabs", "shadcn-tabs-default-value": default_value },
      **options
    }
  end

  class TabComponent < ViewComponent::Base
    def initialize(value:, disabled: false, class_name: nil, **options)
      @value = value
      @disabled = disabled
      @class_name = class_name
      @options = options
    end

    private

    attr_reader :value, :disabled, :class_name, :options

    def tab_classes
      base_classes = "inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow-sm"
      "#{base_classes} #{class_name}"
    end

    def html_attributes
      {
        class: tab_classes,
        data: { 
          "shadcn-tabs-target": "trigger",
          "shadcn-tabs-value": value,
          action: "click->shadcn-tabs#select"
        },
        disabled: disabled,
        **options
      }
    end
  end
end 