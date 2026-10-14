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
      redirect_to edit_settings_path, notice: t('flash.settings.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def trigger_reminders
    PlantReminderJob.perform_later
    redirect_to edit_settings_path,
                notice: t('flash.settings.reminders_triggered')
  end

  def test_telegram
    @user = current_user
    Rails.logger.info("[TEST_TELEGRAM] Action called for #{@user.email}")

    return redirect_to(edit_settings_path, alert: t('flash.settings.missing_credentials')) unless telegram_configured?

    message = "🌿 migarden teste\n\nSe você está lendo isto no Telegram, a integração está funcionando!"
    response = TelegramNotifier.send_message(@user, message)
    handle_test_response(response)
  end

  def connect_telegram
    @user = current_user
    chat_id = TelegramNotifier.fetch_chat_id

    if chat_id.present?
      @user.update(telegram_chat_id: chat_id)
      redirect_to edit_settings_path, notice: t('flash.settings.telegram_connected', chat_id: chat_id)
    else
      redirect_to edit_settings_path, alert: t('flash.settings.telegram_not_found')
    end
  end

  private

  def settings_params
    params.require(:user).permit(
      :name, :email, :telegram_chat_id,
      :password, :password_confirmation
    ).delete_if { |k, v| k.in?(%i[password password_confirmation]) && v.blank? }
  end

  def telegram_configured?
    @user.telegram_chat_id.present?
  end

  def handle_test_response(response)
    if response.is_a?(Net::HTTPSuccess)
      redirect_to edit_settings_path, notice: t('flash.settings.test_sent')
    else
      status = response&.code || '?'
      redirect_to edit_settings_path, alert: t('flash.settings.test_failed', status: status)
    end
  end
end
