module Ui
  # Modern theme switcher component with visual previews
  # Provides a user-friendly way to switch between light, dark, and system themes
  class ThemeSwitcherComponent < ViewComponent::Base
    attr_reader :form, :user

    def initialize(form:, user:)
      @form = form
      @user = user
    end

    private

    def theme_option_class
      "text-center transition-all duration-200 p-4 rounded-lg border border-transparent hover:bg-surface-hover cursor-pointer [&:has(input:checked)]:bg-surface-hover [&:has(input:checked)]:border-primary [&:has(input:checked)]:shadow-md"
    end

    def theme_options
      [
        { value: "light", image: "light-mode-preview.png", label: I18n.t("settings.preferences.show.theme_light") },
        { value: "dark", image: "dark-mode-preview.png", label: I18n.t("settings.preferences.show.theme_dark") },
        { value: "system", image: "system-mode-preview.png", label: I18n.t("settings.preferences.show.theme_system") }
      ]
    end
  end
end