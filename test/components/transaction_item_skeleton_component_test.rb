require "test_helper"

class TransactionItemSkeletonComponentTest < ViewComponent::TestCase
  test "renders skeleton with proper structure" do
    render_inline(TransactionItemSkeletonComponent.new)

    assert_selector ".grid.grid-cols-12"
    assert_selector ".animate-pulse", count: 4 # Icon, name, category, amount
  end

  test "renders with global view context" do
    render_inline(TransactionItemSkeletonComponent.new(view_ctx: "global"))

    assert_selector ".lg\\:col-span-8"
  end

  test "renders with account view context" do
    render_inline(TransactionItemSkeletonComponent.new(view_ctx: "account"))

    assert_selector ".lg\\:col-span-6"
    assert_selector ".col-span-2.justify-self-end.hidden.lg\\:block"
  end
end
