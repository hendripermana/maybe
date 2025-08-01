require "test_helper"

class Ui::SkipToContentComponentTest < ViewComponent::TestCase
  test "renders skip to content link with default values" do
    render_inline(Ui::SkipToContentComponent.new)

    assert_selector "a.skip-to-content[href='#main']", text: "Skip to content"
  end

  test "renders skip to content link with custom target" do
    render_inline(Ui::SkipToContentComponent.new(target: "#dashboard"))

    assert_selector "a.skip-to-content[href='#dashboard']"
  end

  test "renders skip to content link with custom text" do
    render_inline(Ui::SkipToContentComponent.new(text: "Skip to main content"))

    assert_selector "a.skip-to-content", text: "Skip to main content"
  end
end
