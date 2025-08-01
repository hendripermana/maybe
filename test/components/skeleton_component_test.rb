require "test_helper"

class SkeletonComponentTest < ViewComponent::TestCase
  test "renders rectangle skeleton by default" do
    render_inline(SkeletonComponent.new)

    assert_selector ".animate-pulse.rounded-md"
  end

  test "renders circle skeleton" do
    render_inline(SkeletonComponent.new(variant: :circle))

    assert_selector ".animate-pulse.rounded-full"
  end

  test "renders text skeleton" do
    render_inline(SkeletonComponent.new(variant: :text))

    assert_selector ".animate-pulse.rounded-md.h-4"
  end

  test "renders with custom width and height" do
    render_inline(SkeletonComponent.new(width: "100px", height: "50px"))

    assert_selector "[style*='width: 100px']"
    assert_selector "[style*='height: 50px']"
  end

  test "renders with additional classes" do
    render_inline(SkeletonComponent.new(classes: "my-custom-class"))

    assert_selector ".my-custom-class"
  end
end
