require "test_helper"

class PlantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email: @user.email, password: "password" }
  end

  test "redirects to login when not authenticated" do
    delete session_path
    get plants_path
    assert_redirected_to new_session_path
  end

  test "index renders the user's plants" do
    get plants_path
    assert_response :success
    assert_select "h1", "Minhas plantas"
  end

  test "new renders form" do
    get new_plant_path
    assert_response :success
    assert_select "form"
  end

  test "create persists plant and 3 care parameters" do
    assert_difference -> { Plant.count }, 1 do
      assert_difference -> { CareParameter.count }, 3 do
        post plants_path, params: {
          plant: {
            name: "Manjericão",
            plant_type: "Erva",
            sun_exposure: "sol",
            species: "Ocimum basilicum",
            nickname: "Manjinho",
            watering_interval_days: 2,
            fertilization_interval_days: 21,
            pest_control_interval_days: 45
          }
        }
      end
    end
    assert_redirected_to plant_path(Plant.last)
  end

  test "create with invalid data re-renders new" do
    assert_no_difference "Plant.count" do
      post plants_path, params: { plant: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "show renders plant detail" do
    plant = plants(:one)
    get plant_path(plant)
    assert_response :success
    assert_select "h1", plant.name
  end

  test "mark_as_watered creates a care log" do
    plant = plants(:one)
    assert_difference -> { plant.care_logs.count }, 1 do
      patch mark_as_watered_plant_path(plant)
    end
    assert_redirected_to plant_path(plant)
    assert_equal "watering", plant.care_logs.last.action_type
  end

  test "mark_as_fertilized creates a care log" do
    plant = plants(:one)
    assert_difference -> { plant.care_logs.count }, 1 do
      patch mark_as_fertilized_plant_path(plant)
    end
    assert_equal "fertilization", plant.care_logs.last.action_type
  end

  test "mark_as_pest_controlled creates a care log" do
    plant = plants(:one)
    assert_difference -> { plant.care_logs.count }, 1 do
      patch mark_as_pest_controlled_plant_path(plant)
    end
    assert_equal "insecticide", plant.care_logs.last.action_type
  end

  test "user cannot see other users plants" do
    other = plants(:two)
    get plant_path(other)
    assert_response :not_found
  end

  test "destroy removes the plant" do
    plant = plants(:one)
    assert_difference -> { Plant.count }, -1 do
      delete plant_path(plant)
    end
    assert_redirected_to plants_path
  end
end
