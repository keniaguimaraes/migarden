require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'renders new' do
    get new_session_path

    assert_response :success
  end

  test 'logs in valid user' do
    user = users(:one)
    post session_path, params: { email: user.email, password: 'password' }

    assert_redirected_to root_path
  end

  test 'rejects invalid credentials' do
    post session_path, params: { email: users(:one).email, password: 'wrong' }

    assert_response :unprocessable_entity
  end

  test 'logs out' do
    post session_path, params: { email: users(:one).email, password: 'password' }
    delete session_path

    assert_redirected_to new_session_path
  end
end
