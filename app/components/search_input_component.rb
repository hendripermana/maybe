class SearchInputComponent < ViewComponent::Base
  attr_reader :form, :name, :placeholder, :value, :auto_submit

  def initialize(form:, name:, placeholder: nil, value: nil, auto_submit: true)
    @form = form
    @name = name
    @placeholder = placeholder || "Search..."
    @value = value
    @auto_submit = auto_submit
  end

  def input_classes
    "w-full bg-transparent border-0 focus:ring-0 focus:outline-none placeholder:text-sm placeholder:text-secondary text-primary"
  end

  def container_classes
    "flex items-center px-3 py-2 gap-2 border border-secondary rounded-lg focus-within:ring-2 focus-within:ring-primary-500 focus-within:border-primary-500 bg-container transition-all"
  end
end