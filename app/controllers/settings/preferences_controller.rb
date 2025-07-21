module Settings
  class PreferencesController < ApplicationController
    before_action :authenticate_user!
    
    def show
      @user = current_user
    end
    
    def update
      @user = current_user
      
      if @user.update(user_params)
        respond_to do |format|
          format.html { redirect_to settings_preferences_path, notice: t(".success") }
          format.json { render json: { success: true } }
        end
      else
        respond_to do |format|
          format.html { render :show }
          format.json { render json: { success: false, errors: @user.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end
    
    def update_theme
      @user = current_user
      
      if @user.update(theme_params)
        respond_to do |format|
          format.html { redirect_to settings_preferences_path, notice: t(".theme_updated") }
          format.json { render json: { success: true, theme: @user.theme } }
        end
      else
        respond_to do |format|
          format.html { render :show }
          format.json { render json: { success: false, errors: @user.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end
    
    private
    
    def user_params
      params.require(:user).permit(
        :email_notifications, 
        :notification_frequency, 
        :data_sharing, 
        :marketing_emails,
        :theme,
        :high_contrast_mode,
        :reduced_motion,
        :font_size,
        :redirect_to,
        family_attributes: [:id, :locale, :timezone, :date_format]
      )
    end
    
    def theme_params
      params.permit(:theme)
    end
  end
end