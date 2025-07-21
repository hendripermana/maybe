# frozen_string_literal: true

module Ui
  # Documentation index for the UI component library
  class DocumentationIndex < ViewComponent::Preview
    # @label Component Library Overview
    def index
      render_with_template
    end
    
    # @label Comprehensive Index
    def comprehensive_index
      render_with_template
    end
    
    # @label Theme System
    def theme_system
      render_with_template
    end
    
    # @label Accessibility Guidelines
    def accessibility_guidelines
      render_with_template
    end
    
    # @label Component Migration Guide
    def migration_guide
      render_with_template
    end
    
    # @label Best Practices
    def best_practices
      render_with_template
    end
    
    # @label CSS Variables Reference
    def css_variables
      render_with_template
    end
    
    # @label Component Testing Guide
    def component_testing
      render_with_template
    end
  end
end