require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email: @user.email, password: "password" }
  end

  test "redirects /settings to edit" do
    get settings_path
    assert_redirected_to edit_settings_path
  end

  test "renders edit form" do
    get edit_settings_path
    assert_response :success
    assert_select "form"
    assert_select "input[name='user[name]']"
    assert_select "input[name='user[email]']"
    assert_select "input[name='user[callmebot_phone]']"
    assert_select "input[name='user[callmebot_api_key]']"
  end

  test "updates name and email" do
    patch settings_path, params: { user: { name: "Novo Nome", email: @user.email } }
    assert_redirected_to edit_settings_path
    @user.reload
    assert_equal "Novo Nome", @user.name
  end

  test "updates callmebot credentials" do
    patch settings_path, params: { user: {
      name: @user.name,
      email: @user.email,
      callmebot_phone: "+5511988887777",
      callmebot_api_key: "newkey"
    } }
    assert_redirected_to edit_settings_path
    @user.reload
    assert_equal "+5511988887777", @user.callmebot_phone
    assert_equal "newkey", @user.callmebot_api_key
  end

  test "updates password when provided" do
    patch settings_path, params: { user: {
      name: @user.name,
      email: @user.email,
      password: "newpass123",
      password_confirmation: "newpass123"
    } }
    assert_redirected_to edit_settings_path
    assert @user.reload.authenticate("newpass123")
  end

  test "ignores blank password" do
    patch settings_path, params: { user: {
      name: @user.name,
      email: @user.email,
      password: "",
      password_confirmation: ""
    } }
    assert_redirected_to edit_settings_path
    assert @user.reload.authenticate("password")
  end

  test "rejects invalid data" do
    patch settings_path, params: { user: { name: "", email: "bad" } }
    assert_response :unprocessable_entity
  end

  test "requires authentication" do
    delete session_path
    get edit_settings_path
    assert_redirected_to new_session_path
  end
end
