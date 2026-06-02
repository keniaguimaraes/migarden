class SettingsController < ApplicationController
  def show
    redirect_to edit_settings_path
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(settings_params)
      redirect_to edit_settings_path, notice: "Configurações atualizadas com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:user).permit(
      :name, :email,
      :callmebot_phone, :callmebot_api_key,
      :password, :password_confirmation
    ).delete_if { |k, v| k.in?([:password, :password_confirmation]) && v.blank? }
  end
end
