require 'test_helper'

class CalendarControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @plant = plants(:one)
    post session_path, params: { email: @user.email, password: 'password' }
  end

  test 'renders calendar page' do
    get calendar_path

    assert_response :success
    assert_select 'h1', 'Calendário'
  end

  test 'renders summary cards' do
    get calendar_path

    assert_select '.summary-card', count: 3
    assert_select '.summary-card__label', text: 'Precisam de rega hoje'
  end

  test 'renders calendar grid' do
    get calendar_path

    assert_select '.calendar-grid'
    assert_select '.calendar-grid__header', count: 7
  end

  test 'requires authentication' do
    delete session_path
    get calendar_path

    assert_redirected_to new_session_path
  end

  test 'shows zeros in summary when all cares done today' do
    @user.plants.each do |plant|
      %i[watering fertilization insecticide].each do |action|
        plant.care_logs.create!(action_type: action, performed_at: Date.current)
      end
    end
    get calendar_path

    assert_response :success
    assert_select '.summary-card__value', text: '0', count: 3
  end

  test 'shows day with events when care is due' do
    @plant.care_logs.create!(action_type: :watering, performed_at: 7.days.ago.to_date)
    get calendar_path

    assert_response :success
    assert_select '.calendar-day--has-events'
  end

  test 'day detail shows plant info when date param present' do
    @plant.care_logs.create!(action_type: :watering, performed_at: 7.days.ago.to_date)
    today_str = Date.current.strftime('%Y-%m-%d')
    get calendar_path, params: { date: today_str }

    assert_response :success
    assert_select '.day-detail'
    assert_select '.day-detail__plant-name', /#{@plant.name}/
  end

  test 'old alertas path redirects to calendar' do
    get '/alertas'

    assert_redirected_to '/calendar'
  end

  test 'month param changes displayed month' do
    next_month = (Date.current + 1.month).strftime('%Y-%m')
    get calendar_path, params: { month: next_month }

    assert_response :success
    assert_select '.calendar-nav__title'
  end
end
