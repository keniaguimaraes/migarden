require 'test_helper'

class PlantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email: @user.email, password: 'password' }
  end

  test 'redirects to login when not authenticated' do
    delete session_path
    get plants_path

    assert_redirected_to new_session_path
  end

  test "index renders the user's plants" do
    get plants_path

    assert_response :success
    assert_select 'h1', 'Minhas plantas'
  end

  test 'new renders form inside a turbo frame for the modal' do
    get new_plant_path

    assert_response :success
    assert_select 'turbo-frame#plant_modal'
    assert_select 'form'
    assert_select '.modal'
    assert_select '.modal__title', 'Nova planta'
  end

  test 'edit renders form inside a turbo frame for the modal' do
    plant = plants(:one)
    get edit_plant_path(plant)

    assert_response :success
    assert_select 'turbo-frame#plant_modal'
    assert_select 'form'
    assert_select '.modal__title', 'Editar planta'
  end

  test 'index has empty plant_modal frame available for turbo' do
    get plants_path

    assert_response :success
    assert_select 'turbo-frame#plant_modal'
  end

  test 'update responds with turbo_stream for turbo requests' do
    plant = plants(:one)
    patch plant_path(plant), params: {
      plant: { name: 'Jiboia Renomeada', plant_type: plant.plant_type, sun_exposure: plant.sun_exposure }
    }, as: :turbo_stream

    assert_response :success
  end

  test 'update persists changes' do
    plant = plants(:one)
    patch plant_path(plant), params: {
      plant: { name: 'Jiboia Renomeada', plant_type: plant.plant_type, sun_exposure: plant.sun_exposure }
    }

    assert_redirected_to plants_path
    assert_equal 'Jiboia Renomeada', plant.reload.name
  end

  test 'create persists plant and 3 care parameters' do
    assert_difference -> { Plant.count }, 1 do
      assert_difference -> { CareParameter.count }, 3 do
        post plants_path, params: {
          plant: {
            name: 'Manjericão',
            plant_type: 'Erva',
            sun_exposure: 'sol',
            species: 'Ocimum basilicum',
            nickname: 'Manjinho',
            watering_interval_days: 2,
            fertilization_interval_days: 21,
            pest_control_interval_days: 45
          }
        }
      end
    end
    assert_redirected_to plants_path
  end

  test 'create responds with turbo_stream for turbo requests' do
    post plants_path, params: {
      plant: {
        name: 'Hortelã',
        plant_type: 'Erva',
        sun_exposure: 'sol',
        watering_interval_days: 2,
        fertilization_interval_days: 30,
        pest_control_interval_days: 60
      }
    }, as: :turbo_stream

    assert_response :success
    assert_match(/turbo-stream/, response.media_type)
  end

  test 'create with invalid data re-renders new inside frame' do
    assert_no_difference 'Plant.count' do
      post plants_path, params: { plant: { name: '' } }
    end
    assert_response :unprocessable_entity
    assert_select 'turbo-frame#plant_modal'
    assert_select '.form__errors'
  end

  test 'show renders plant detail' do
    plant = plants(:one)
    get plant_path(plant)

    assert_response :success
    assert_select 'h1', plant.name
  end

  test 'mark_as_watered creates a care log' do
    plant = plants(:one)
    assert_difference -> { plant.care_logs.count }, 1 do
      patch mark_as_watered_plant_path(plant)
    end
    assert_redirected_to plant_path(plant)
    assert_equal 'watering', plant.care_logs.last.action_type
  end

  test 'mark_as_fertilized creates a care log' do
    plant = plants(:one)
    assert_difference -> { plant.care_logs.count }, 1 do
      patch mark_as_fertilized_plant_path(plant)
    end
    assert_equal 'fertilization', plant.care_logs.last.action_type
  end

  test 'mark_as_pest_controlled creates a care log' do
    plant = plants(:one)
    assert_difference -> { plant.care_logs.count }, 1 do
      patch mark_as_pest_controlled_plant_path(plant)
    end
    assert_equal 'insecticide', plant.care_logs.last.action_type
  end

  test 'user cannot see other users plants' do
    other = plants(:two)
    get plant_path(other)

    assert_response :not_found
  end

  test 'destroy removes the plant' do
    plant = plants(:one)
    assert_difference -> { Plant.count }, -1 do
      delete plant_path(plant)
    end
    assert_redirected_to plants_path
  end
end
