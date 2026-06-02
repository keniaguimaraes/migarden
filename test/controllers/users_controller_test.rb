require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "renders new" do
    get new_user_path
    assert_response :success
  end

  test "creates user" do
    assert_difference -> { User.count }, 1 do
      post users_path, params: {
        user: { name: "Novo", email: "novo@example.com", password: "password", password_confirmation: "password" }
      }
    end
    assert_redirected_to root_path
  end

  test "rejects invalid signup" do
    assert_no_difference "User.count" do
      post users_path, params: { user: { email: "bad", password: "x" } }
    end
    assert_response :unprocessable_entity
  end
end
