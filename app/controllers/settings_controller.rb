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

  def test_whatsapp
    @user = current_user

    if @user.callmebot_phone.blank? || @user.callmebot_api_key.blank?
      redirect_to edit_settings_path, alert: "Preencha telefone e API key antes de testar."
      return
    end

    message = "🌿 migarden teste\n\nSe você está lendo isto no WhatsApp, a integração com o CallMeBot está funcionando!"
    response = WhatsappNotifier.send_message(@user, message)

    if response.is_a?(Net::HTTPSuccess)
      redirect_to edit_settings_path, notice: "Mensagem de teste enviada para #{@user.callmebot_phone}."
    else
      status = response&.code || "?"
      redirect_to edit_settings_path, alert: "Falha ao enviar (HTTP #{status}). Confira a API key e o telefone."
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
