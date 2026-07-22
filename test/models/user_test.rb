require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test 'valid user' do
    assert_predicate @user, :valid?
  end

  test 'invalid without name' do
    @user.name = nil

    assert_not @user.valid?
  end

  test 'invalid with duplicate email' do
    dup = User.new(name: 'Outro', email: @user.email, password: 'password', password_confirmation: 'password')

    assert_not dup.valid?
  end

  test 'invalid with bad email' do
    @user.email = 'not-an-email'

    assert_not @user.valid?
  end

  test 'has_secure_password' do
    assert @user.authenticate('password')
    assert_not @user.authenticate('wrong')
  end

  test 'destroys dependent plants' do
    user = users(:one)
    assert_difference -> { Plant.count }, -user.plants.count do
      user.destroy
    end
  end
end
