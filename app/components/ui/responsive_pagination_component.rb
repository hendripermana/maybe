# frozen_string_literal: true

module Ui
  # Responsive pagination component
  # Provides touch-friendly pagination controls that adapt to different screen sizes
  class ResponsivePaginationComponent < ViewComponent::Base
    attr_reader :pagy

    def initialize(pagy:)
      @pagy = pagy
    end

    def prev_page_url
      pagy_url_for(pagy, pagy.prev) if pagy.prev
    end

    def next_page_url
      pagy_url_for(pagy, pagy.next) if pagy.next
    end

    def page_url(page)
      pagy_url_for(pagy, page)
    end

    def visible_pages
      # Show fewer pages on mobile
      if pagy.pages <= 5
        1.upto(pagy.pages).to_a
      else
        # Complex logic for showing a subset of pages with ellipsis
        from = [pagy.page - 1, 1].max
        to = [from + 2, pagy.pages].min
        from = [to - 2, 1].max

        result = []
        result << 1 if from > 1
        result << '...' if from > 2
        result.concat(from.upto(to).to_a)
        result << '...' if to < pagy.pages - 1
        result << pagy.pages if to < pagy.pages
        result
      end
    end
  end
end