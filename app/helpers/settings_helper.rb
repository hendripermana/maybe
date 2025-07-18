module SettingsHelper
  SETTINGS_ORDER = [
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

  def adjacent_setting(current_path, offset)
    visible_settings = SETTINGS_ORDER.select { |setting| setting[:condition].nil? || send(setting[:condition]) }
    current_index = visible_settings.index { |setting| send(setting[:path]) == current_path }
    return nil unless current_index

    adjacent_index = current_index + offset
    return nil if adjacent_index < 0 || adjacent_index >= visible_settings.size

    adjacent = visible_settings[adjacent_index]

    render partial: "settings/settings_nav_link_large", locals: {
      path: send(adjacent[:path]),
      direction: offset > 0 ? "next" : "previous",
      title: adjacent[:name]
    }
  end

  def settings_section(title:, subtitle: nil, &block)
    content = capture(&block)
    render Ui::SettingsSectionComponent.new(title: title, subtitle: subtitle) { content }
  end

  # These methods are no longer needed as we're using SettingsNavFooterComponent directly
  # Keeping the adjacent_setting method for backward compatibility

  private
    def not_self_hosted?
      !self_hosted?
    end
end
