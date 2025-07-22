# frozen_string_literal: true

module Ui
  # Modern settings navigation footer component
  # Provides consistent styling for previous/next navigation in settings
  class SettingsNavFooterComponent < BaseComponent
    attr_reader :current_path, :previous_setting, :next_setting

    def initialize(current_path:, **options)
      super(**options)
      @current_path = current_path
      @previous_setting = nil
      @next_setting = nil
    end

    def before_render
      @previous_setting = adjacent_setting(-1)
      @next_setting = adjacent_setting(1)
    end

    private

    def adjacent_setting(offset)
      visible_settings = settings_order.select { |setting| setting[:condition].nil? || helpers.send(setting[:condition]) }
      current_index = visible_settings.index { |setting| helpers.send(setting[:path]) == current_path }
      return nil unless current_index

      adjacent_index = current_index + offset
      return nil if adjacent_index < 0 || adjacent_index >= visible_settings.size

      visible_settings[adjacent_index]
    end

    def settings_order
      [
        { name: "Account", path: :settings_profile_path },
        { name: "Preferences", path: :settings_preferences_path },
        { name: "Security", path: :settings_security_path },
        { name: "Self hosting", path: :settings_hosting_path, condition: :self_hosted? },
        { name: "API Key", path: :settings_api_key_path },
        { name: "Billing", path: :settings_billing_path, condition: :not_self_hosted? },
        { name: "Accounts", path: :accounts_path },
        { name: "Imports", path: :imports_path },
        { name: "Tags", path: :tags_path },
        { name: "Categories", path: :categories_path },
        { name: "Rules", path: :rules_path },
        { name: "Merchants", path: :family_merchants_path },
        { name: "What's new", path: :changelog_path },
        { name: "Feedback", path: :feedback_path }
      ]
    end
  end
end