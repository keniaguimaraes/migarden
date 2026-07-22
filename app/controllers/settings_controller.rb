class SettingsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:test_whatsapp]

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

  def test_queue_reminder
    @user = current_user
    run_at = 1.minute.from_now
    PlantReminderJob.set(wait_until: run_at).perform_later
    Rails.logger.info("[TEST_QUEUE] PlantReminderJob enfileirado para #{run_at.iso8601} por #{@user.email}")
    redirect_to edit_settings_path,
                notice: t('flash.settings.test_queued', time: run_at.strftime('%H:%M:%S'))
  end

  def test_whatsapp
    @user = current_user
    Rails.logger.info("[TEST_WHATSAPP] Action called for #{@user.email}")

    return redirect_to(edit_settings_path, alert: t('flash.settings.missing_credentials')) unless credentials_present?

    message = "🌿 migarden teste\n\nSe você está lendo isto no WhatsApp, a integração com o CallMeBot está funcionando!"
    response = WhatsappNotifier.send_message(@user, message)
    handle_test_response(response)
  end

  private

  def settings_params
    params.require(:user).permit(
      :name, :email,
      :callmebot_phone, :callmebot_api_key,
      :password, :password_confirmation
    ).delete_if { |k, v| k.in?(%i[password password_confirmation]) && v.blank? }
  end

  def credentials_present?
    @user.callmebot_phone.present? && @user.callmebot_api_key.present?
  end

  def handle_test_response(response)
    if response.is_a?(Net::HTTPSuccess)
      redirect_to edit_settings_path, notice: t('flash.settings.test_sent', phone: @user.callmebot_phone)
    else
      status = response&.code || '?'
      redirect_to edit_settings_path, alert: t('flash.settings.test_failed', status: status)
    end
  end
end
