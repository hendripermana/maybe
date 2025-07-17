# frozen_string_literal: true

class Ui::DataTableComponent < ViewComponent::Base
  attr_reader :headers, :rows, :empty_message

  def initialize(headers:, rows:, empty_message: "No data available", **html_options)
    @headers = headers
    @rows = rows
    @empty_message = empty_message
    @html_options = html_options
  end

  private

  def css_classes
    classes = [
      "w-full bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm"
    ]
    
    classes << @html_options[:class] if @html_options[:class]
    classes.compact.join(" ")
  end

  def html_options
    @html_options.except(:class).merge(class: css_classes)
  end
end
