# frozen_string_literal: true

module Ui
  # Modern settings navigation component with responsive behavior
  # Provides consistent styling and theme support for settings navigation
  class SettingsNavComponent < BaseComponent
    attr_reader :current_path, :sections

    def initialize(current_path:, **options)
      super(**options)
      @current_path = current_path
      @sections = []
    end

    def before_render
      @sections = build_sections
    end

    private

    def build_sections
      [
        {
          header: I18n.t("settings._settings_nav.general_section_title"),
          items: [
            { label: I18n.t("settings._settings_nav.profile_label"), path: helpers.settings_profile_path, icon: "circle-user" },
            { label: I18n.t("settings._settings_nav.preferences_label"), path: helpers.settings_preferences_path, icon: "bolt" },
            { label: I18n.t("settings._settings_nav.security_label"), path: helpers.settings_security_path, icon: "shield-check" },
            { label: "API Key", path: helpers.settings_api_key_path, icon: "key" },
            { label: I18n.t("settings._settings_nav.self_hosting_label"), path: helpers.settings_hosting_path, icon: "database", if: helpers.self_hosted? },
            { label: I18n.t("settings._settings_nav.billing_label"), path: helpers.settings_billing_path, icon: "circle-dollar-sign", if: !helpers.self_hosted? },
            { label: I18n.t("settings._settings_nav.accounts_label"), path: helpers.accounts_path, icon: "layers" },
            { label: I18n.t("settings._settings_nav.imports_label"), path: helpers.imports_path, icon: "download" }
          ]
        },
        {
          header: I18n.t("settings._settings_nav.transactions_section_title"),
          items: [
            { label: I18n.t("settings._settings_nav.tags_label"), path: helpers.tags_path, icon: "tags" },
            { label: I18n.t("settings._settings_nav.categories_label"), path: helpers.categories_path, icon: "shapes" },
            { label: I18n.t("settings._settings_nav.rules_label"), path: helpers.rules_path, icon: "git-branch" },
            { label: I18n.t("settings._settings_nav.merchants_label"), path: helpers.family_merchants_path, icon: "store" }
          ]
        },
        {
          header: I18n.t("settings._settings_nav.other_section_title"),
          items: [
            { label: I18n.t("settings._settings_nav.whats_new_label"), path: helpers.changelog_path, icon: "box" },
            { label: I18n.t("settings._settings_nav.feedback_label"), path: helpers.feedback_path, icon: "megaphone" }
          ]
        }
      ]
    end

    def previous_path
      helpers.root_path
    end

    def active?(path)
      path == current_path
    end
  end
end