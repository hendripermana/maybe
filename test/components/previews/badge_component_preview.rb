class BadgeComponentPreview < ViewComponent::Preview
  # Basic badge with all variants
  # @param variant select {{ DS::Badge::VARIANTS.keys }}
  # @param size select {{ DS::Badge::SIZES.keys }}
  # @param icon select ["", "check", "x", "alert-circle", "info"]
  def default(variant: "default", size: "md", icon: "")
    icon_value = icon.present? ? icon : nil
    render DS::Badge.new(variant: variant, size: size, text: "Badge", icon: icon_value)
  end

  # Status badges
  def status_badges
    content_tag(:div, class: "flex flex-wrap gap-2") do
      safe_join([
        render(DS::Badge.new(variant: "success", text: "Active", icon: "check")),
        render(DS::Badge.new(variant: "warning", text: "Pending", icon: "clock")),
        render(DS::Badge.new(variant: "destructive", text: "Error", icon: "x")),
        render(DS::Badge.new(variant: "secondary", text: "Draft"))
      ])
    end
  end

  # Different sizes
  def sizes
    content_tag(:div, class: "flex items-center gap-2") do
      safe_join([
        render(DS::Badge.new(size: "sm", text: "Small")),
        render(DS::Badge.new(size: "md", text: "Medium")),
        render(DS::Badge.new(size: "lg", text: "Large"))
      ])
    end
  end

  # Outline variants
  def outline_variants
    content_tag(:div, class: "flex flex-wrap gap-2") do
      safe_join([
        render(DS::Badge.new(variant: "outline", text: "Outline")),
        render(DS::Badge.new(variant: "outline", text: "With Icon", icon: "star"))
      ])
    end
  end

  # Custom content
  def custom_content
    render DS::Badge.new(variant: "secondary") do
      safe_join([
        helpers.icon("users", size: :xs),
        " ",
        "3 members"
      ])
    end
  end

  # Number badges
  def number_badges
    content_tag(:div, class: "flex gap-2") do
      safe_join([
        render(DS::Badge.new(variant: "destructive", text: "99+", size: "sm")),
        render(DS::Badge.new(variant: "default", text: "12")),
        render(DS::Badge.new(variant: "success", text: "New"))
      ])
    end
  end
end