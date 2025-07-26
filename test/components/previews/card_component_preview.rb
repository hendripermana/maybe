class CardComponentPreview < ViewComponent::Preview
  # Basic card with all slots
  # @param variant select {{ DS::Card::VARIANTS.keys }}
  # @param size select {{ DS::Card::SIZES.keys }}
  def default(variant: "default", size: "md")
    render DS::Card.new(variant: variant, size: size) do |card|
      card.with_header(title: "Card Title", subtitle: "Optional subtitle")
      card.with_body do
        "This is the main content of the card. It can contain any HTML content."
      end
      card.with_footer do
        content_tag(:div, class: "flex gap-2") do
          safe_join([
            render(DS::Button.new(variant: "primary", size: "sm", text: "Primary")),
            render(DS::Button.new(variant: "outline", size: "sm", text: "Cancel"))
          ])
        end
      end
    end
  end

  # Simple card with just content
  def simple
    render DS::Card.new(variant: "outline") do
      "Simple card content without header or footer."
    end
  end

  # Card with custom header content
  def custom_header
    render DS::Card.new do |card|
      card.with_header do
        content_tag(:div, class: "flex items-center justify-between") do
          safe_join([
            content_tag(:h3, "Custom Header", class: "text-lg font-semibold"),
            render(DS::Button.new(variant: "icon", icon: "x", size: "sm"))
          ])
        end
      end
      card.with_body do
        "Card with custom header layout."
      end
    end
  end

  # Ghost variant for subtle containers
  def ghost_variant
    render DS::Card.new(variant: "ghost", size: "lg") do |card|
      card.with_body do
        "Ghost variant card with no background or border."
      end
    end
  end

  # Filled variant with background
  def filled_variant
    render DS::Card.new(variant: "filled") do |card|
      card.with_header(title: "Filled Card")
      card.with_body do
        "This card has a subtle background color."
      end
    end
  end
end