# frozen_string_literal: true

module Ui
  # Responsive transaction item skeleton component for loading states
  # Adapts to different screen sizes and maintains consistent layout with actual items
  class ResponsiveTransactionItemSkeletonComponent < ViewComponent::Base
    attr_reader :view_ctx

    def initialize(view_ctx: "global")
      @view_ctx = view_ctx
    end

    def container_classes
      "grid grid-cols-12 items-center p-4 rounded-lg bg-container"
    end

    def name_column_classes
      if view_ctx == "global"
        "col-span-8 md:col-span-6 lg:col-span-8"
      else
        "col-span-8 md:col-span-6 lg:col-span-6"
      end
    end
  end
end
