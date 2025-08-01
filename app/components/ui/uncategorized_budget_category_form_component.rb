# frozen_string_literal: true

module Ui
  # Modern uncategorized budget category form component with theme-aware styling
  # Provides consistent form styling across light and dark themes
  class UncategorizedBudgetCategoryFormComponent < BaseComponent
    attr_reader :budget

    def initialize(
      budget:,
      **options
    )
      super(**options)
      @budget = budget
    end

    private

      def dom_id(record, prefix = nil)
        if record.respond_to?(:to_key) && record.to_key
          id = record.to_key.join("_")
          prefix ? "#{prefix}_#{id}" : id
        else
          id = record.id.to_s
          prefix ? "#{prefix}_#{id}" : id
        end
      end
  end
end
