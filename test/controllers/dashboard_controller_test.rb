require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email: @user.email, password: 'password' }
  end

  test 'renders dashboard' do
    get root_path

    assert_response :success
    assert_select 'h1', /Olá, Maria/
    assert_select '.summary-card', 4
  end

  test 'redirects when not logged in' do
    delete session_path
    get root_path

    assert_redirected_to new_session_path
  end
end
