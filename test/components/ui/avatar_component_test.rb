# frozen_string_literal: true

require "test_helper"

class Ui::AvatarComponentTest < ViewComponent::TestCase
  include ComponentTestingSuiteHelper

  def test_renders_avatar_with_image
    render_inline(Ui::AvatarComponent.new(
      src: "https://example.com/avatar.jpg",
      alt: "User Avatar"
    ))

    assert_selector "img[src='https://example.com/avatar.jpg']"
    assert_selector "img[alt='User Avatar']"
  end

  def test_renders_avatar_with_initials_when_no_image
    render_inline(Ui::AvatarComponent.new(
      alt: "John Doe"
    ))

    assert_selector "span", text: "JD"
    assert_no_selector "img"
  end

  def test_renders_different_sizes
    render_inline(Ui::AvatarComponent.new(alt: "User", size: :xs))
    assert_selector ".w-6.h-6"

    render_inline(Ui::AvatarComponent.new(alt: "User", size: :sm))
    assert_selector ".w-8.h-8"

    render_inline(Ui::AvatarComponent.new(alt: "User", size: :md))
    assert_selector ".w-10.h-10"

    render_inline(Ui::AvatarComponent.new(alt: "User", size: :lg))
    assert_selector ".w-12.h-12"

    render_inline(Ui::AvatarComponent.new(alt: "User", size: :xl))
    assert_selector ".w-16.h-16"
  end

  def test_renders_different_variants
    render_inline(Ui::AvatarComponent.new(alt: "User", variant: :primary))
    assert_selector ".bg-primary"

    render_inline(Ui::AvatarComponent.new(alt: "User", variant: :success))
    assert_selector ".bg-success"

    render_inline(Ui::AvatarComponent.new(alt: "User", variant: :warning))
    assert_selector ".bg-warning"

    render_inline(Ui::AvatarComponent.new(alt: "User", variant: :destructive))
    assert_selector ".bg-destructive"
  end

  def test_generates_correct_initials
    render_inline(Ui::AvatarComponent.new(alt: "John Doe"))
    assert_selector "span", text: "JD"

    render_inline(Ui::AvatarComponent.new(alt: "Jane"))
    assert_selector "span", text: "J"

    render_inline(Ui::AvatarComponent.new(alt: "John Middle Doe"))
    assert_selector "span", text: "JD"
  end

  def test_theme_switching
    test_component_comprehensively(
      Ui::AvatarComponent.new(alt: "John Doe"),
      interactions: [ :hover, :focus ]
    )
  end

  def test_accessibility
    render_inline(Ui::AvatarComponent.new(
      src: "https://example.com/avatar.jpg",
      alt: "User Avatar"
    ))

    assert_selector "img[alt='User Avatar']"

    render_inline(Ui::AvatarComponent.new(alt: "John Doe"))
    assert_selector "[aria-label='Avatar for John Doe']"
  end
end
