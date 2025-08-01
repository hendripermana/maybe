# frozen_string_literal: true

class ComprehensiveComponentTestCase < ComponentTestCase
  include ComponentTestingSuiteHelper

  # Class method to generate standard test suite for a component
  def self.generate_standard_tests_for(component_class, options = {})
    component_name = component_class.name.demodulize.underscore.sub(/_component$/, "")

    # Default options
    options = {
      props: {},
      content: nil,
      interactive: true,
      theme_aware: true,
      accessibility: true,
      visual_regression: true,
      interactions: [ :click, :hover, :focus, :keyboard ]
    }.merge(options)

    # Basic rendering test
    test "#{component_name} renders correctly with default props" do
      component = component_class.new(**options[:props])

      if options[:content]
        render_inline(component) { options[:content] }
      else
        render_inline(component)
      end

      assert_selector ".#{component_name.dasherize}", count: 1
    end

    # Theme switching test
    if options[:theme_aware]
      test "#{component_name} renders correctly in both themes" do
        component = component_class.new(**options[:props])
        test_theme_switching(component, options[:content])
      end

      test "#{component_name} uses theme-aware classes" do
        component = component_class.new(**options[:props])

        if options[:content]
          render_inline(component) { options[:content] }
        else
          render_inline(component)
        end

        assert_component_theme_aware(component, options[:content])
        assert_no_hardcoded_theme_classes
        assert_css_variables_used
      end
    end

    # Accessibility test
    if options[:accessibility]
      test "#{component_name} meets accessibility requirements" do
        component = component_class.new(**options[:props])
        test_component_accessibility(component, options[:content])
      end
    end

    # Interaction test
    if options[:interactive] && options[:interactions].any?
      test "#{component_name} handles interactions correctly" do
        component = component_class.new(**options[:props])
        test_component_interactions(component, options[:interactions])
      end
    end

    # Comprehensive test
    test "#{component_name} passes comprehensive component testing" do
      component = component_class.new(**options[:props])
      test_component_comprehensively(
        component,
        content: options[:content],
        interactions: options[:interactive] ? options[:interactions] : []
      )
    end
  end

  # Helper method to test all variants of a component
  def test_component_variants(component_class, variants_prop_name, variants, base_props = {})
    variants.each do |variant|
      variant_props = base_props.merge(variants_prop_name => variant)
      component = component_class.new(**variant_props)

      render_inline(component)

      # Check that variant class is applied
      variant_class = variant.to_s.dasherize
      assert_selector ".#{variant_class}", count: 1

      # Test theme switching for this variant
      test_theme_switching(component_class.new(**variant_props))
    end
  end

  # Helper method to test all sizes of a component
  def test_component_sizes(component_class, sizes_prop_name, sizes, base_props = {})
    sizes.each do |size|
      size_props = base_props.merge(sizes_prop_name => size)
      component = component_class.new(**size_props)

      render_inline(component)

      # Check that size class is applied
      size_class = size.to_s.dasherize
      assert_selector ".#{size_class}", count: 1

      # Test theme switching for this size
      test_theme_switching(component_class.new(**size_props))
    end
  end
end
