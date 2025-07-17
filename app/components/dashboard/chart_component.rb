# frozen_string_literal: true

# Modern chart container component with ShadCN styling
class Dashboard::ChartComponent < ViewComponent::Base
  attr_reader :title, :subtitle, :chart_type, :data, :height, :actions, :partial, :locals

  def initialize(
    title:,
    subtitle: nil,
    chart_type: :line,
    data: {},
    height: "400px",
    actions: nil,
    partial: nil,
    locals: {},
    **html_options
  )
    @title = title
    @subtitle = subtitle
    @chart_type = chart_type
    @data = data
    @height = height
    @actions = actions
    @partial = partial
    @locals = locals
    @html_options = html_options
  end

  private

    def css_classes
      classes = [
        "bg-card text-card-foreground border rounded-xl shadow-sm overflow-hidden"
      ]

      classes << @html_options[:class] if @html_options[:class]
      classes.compact.join(" ")
    end

    def html_options
      @html_options.except(:class).merge(class: css_classes)
    end

    def chart_container_style
      "height: #{height};"
    end

    def header_icon
      case chart_type
      when :line, :area
        "trending-up"
      when :bar
        "bar-chart-3"
      when :pie, :donut
        "pie-chart"
      when :sankey
        "activity"
      else
        "chart-line"
      end
    end

    def render_chart_content
      if partial
        helpers.render(partial: partial, locals: locals)
      elsif content?
        content
      else
        nil
      end
    end
end
