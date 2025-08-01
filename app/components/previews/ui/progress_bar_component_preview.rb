class UI::ProgressBarComponentPreview < ViewComponent::Preview
  # @param value number
  # @param max number
  # @param variant select [default, success, warning, danger]
  # @param size select [sm, md, lg]
  # @param animated toggle
  # @param show_label toggle
  # @param label text
  def default(value: 50, max: 100, variant: :default, size: :md, animated: true, show_label: false, label: "Progress")
    render UI::ProgressBarComponent.new(
      value: value,
      max: max,
      variant: variant.to_sym,
      size: size.to_sym,
      animated: animated,
      show_label: show_label,
      label: label
    )
  end

  def variants
    render_with_template(locals: {})
  end

  def sizes
    render_with_template(locals: {})
  end

  def with_labels
    render_with_template(locals: {})
  end
end
