require 'test_helper'

class AlertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email: @user.email, password: 'password' }
  end

  test 'renders alerts page' do
    get alerts_path

    assert_response :success
    assert_select 'h1', 'Alertas'
  end

  test 'requires authentication' do
    delete session_path
    get alerts_path

    assert_redirected_to new_session_path
  end

  test 'shows empty state when nothing is pending' do
    @user.plants.each do |plant|
      %i[watering fertilization insecticide].each do |action|
        plant.care_logs.create!(action_type: action, performed_at: Date.current)
      end
    end
    get alerts_path

    assert_response :success
    assert_select '.empty-state__title', 'Tudo em dia!'
  end

  test 'lists plants needing care' do
    plant = plants(:one)
    plant.care_logs.create!(action_type: :watering, performed_at: 30.days.ago.to_date)
    get alerts_path

    assert_response :success
    assert_select 'h3.plant-card__name', /#{plant.name}/
  end
end
