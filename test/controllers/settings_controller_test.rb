require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email: @user.email, password: 'password' }
  end

  test 'redirects /settings to edit' do
    get settings_path

    assert_redirected_to edit_settings_path
  end

  test 'renders edit form' do
    get edit_settings_path

    assert_response :success
    assert_select 'form'
    assert_select "input[name='user[name]']"
    assert_select "input[name='user[email]']"
    assert_select "input[name='user[telegram_chat_id]']"
  end

  test 'updates name and email' do
    patch settings_path, params: { user: { name: 'Novo Nome', email: @user.email } }

    assert_redirected_to edit_settings_path
    @user.reload

    assert_equal 'Novo Nome', @user.name
  end

  test 'updates telegram chat id' do
    patch settings_path, params: { user: {
      name: @user.name,
      email: @user.email,
      telegram_chat_id: '987654321'
    } }

    assert_redirected_to edit_settings_path
    @user.reload

    assert_equal '987654321', @user.telegram_chat_id
  end

  test 'updates password when provided' do
    patch settings_path, params: { user: {
      name: @user.name,
      email: @user.email,
      password: 'newpass123',
      password_confirmation: 'newpass123'
    } }

    assert_redirected_to edit_settings_path
    assert @user.reload.authenticate('newpass123')
  end

  test 'ignores blank password' do
    patch settings_path, params: { user: {
      name: @user.name,
      email: @user.email,
      password: '',
      password_confirmation: ''
    } }

    assert_redirected_to edit_settings_path
    assert @user.reload.authenticate('password')
  end

  test 'rejects invalid data' do
    patch settings_path, params: { user: { name: '', email: 'bad' } }

    assert_response :unprocessable_entity
  end

  test 'requires authentication' do
    delete session_path
    get edit_settings_path

    assert_redirected_to new_session_path
  end

  test 'test_telegram rejects missing chat id' do
    @user.update!(telegram_chat_id: nil)
    with_stubbed_notifier(->(_u, _m) { success_response }) do
      post test_telegram_settings_path
    end

    assert_redirected_to edit_settings_path
    assert_match(/Conecte o Telegram/, flash[:alert])
  end

  test 'test_telegram succeeds with valid chat id' do
    with_stubbed_notifier(->(_u, _m) { success_response }) do
      post test_telegram_settings_path
    end

    assert_redirected_to edit_settings_path
    assert_match(/Mensagem de teste enviada/, flash[:notice])
  end

  test 'test_telegram reports failure on non-success response' do
    with_stubbed_notifier(->(_u, _m) { failure_response }) do
      post test_telegram_settings_path
    end

    assert_redirected_to edit_settings_path
    assert_match(/Falha ao enviar/, flash[:alert])
  end

  test 'connect_telegram saves detected chat id' do
    @user.update!(telegram_chat_id: nil)
    with_stubbed_chat_id('555000111') do
      post connect_telegram_settings_path
    end

    assert_redirected_to edit_settings_path
    assert_equal '555000111', @user.reload.telegram_chat_id
    assert_match(/Telegram conectado/, flash[:notice])
  end

  test 'connect_telegram alerts when no message found' do
    with_stubbed_chat_id(nil) do
      post connect_telegram_settings_path
    end

    assert_redirected_to edit_settings_path
    assert_match(/não encontrei/i, flash[:alert])
  end

  private

  def with_stubbed_notifier(behavior)
    original = TelegramNotifier.method(:send_message)
    TelegramNotifier.singleton_class.send(:define_method, :send_message) { |*args| behavior.call(*args) }
    yield
  ensure
    TelegramNotifier.singleton_class.send(:remove_method, :send_message)
    TelegramNotifier.singleton_class.send(:define_method, :send_message, original)
  end

  def with_stubbed_chat_id(value)
    original = TelegramNotifier.method(:fetch_chat_id)
    TelegramNotifier.singleton_class.send(:define_method, :fetch_chat_id) { value }
    yield
  ensure
    TelegramNotifier.singleton_class.send(:remove_method, :fetch_chat_id)
    TelegramNotifier.singleton_class.send(:define_method, :fetch_chat_id, original)
  end

  def success_response
    Class.new do
      def is_a?(klass) = klass == Net::HTTPSuccess
      def code = '200'
    end.new
  end

  def failure_response
    Class.new do
      def is_a?(klass) = klass == Net::HTTPServerError
      def code = '500'
    end.new
  end
end
