# frozen_string_literal: true

module Ui
  # Modern breadcrumbs component with consistent styling
  class BreadcrumbsComponent < ViewComponent::Base
    attr_reader :breadcrumbs

    def initialize(breadcrumbs:, **options)
      super(**options)
      @breadcrumbs = breadcrumbs || []
    end
  end
end