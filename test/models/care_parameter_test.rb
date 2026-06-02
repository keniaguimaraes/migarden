require "test_helper"

class CareParameterTest < ActiveSupport::TestCase
  setup do
    @plant = plants(:one)
    @parameter = care_parameters(:watering_one)
  end

  test "valid parameter" do
    assert @parameter.valid?
  end

  test "invalid without action_type" do
    @parameter.action_type = nil
    refute @parameter.valid?
  end

  test "invalid without interval_days" do
    @parameter.interval_days = nil
    refute @parameter.valid?
  end

  test "interval_days must be greater than 0" do
    @parameter.interval_days = 0
    refute @parameter.valid?
  end

  test "uniqueness scoped to plant" do
    duplicate = @plant.care_parameters.build(action_type: :watering, interval_days: 10)
    refute duplicate.valid?
    assert_includes duplicate.errors[:action_type], "has already been taken"
  end

  test "action_type enum exposes boolean predicates" do
    assert @parameter.watering?
    refute @parameter.fertilization?
    refute @parameter.insecticide?
  end
end
