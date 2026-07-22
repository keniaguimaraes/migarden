require 'test_helper'

class CareParameterTest < ActiveSupport::TestCase
  setup do
    @plant = plants(:one)
    @parameter = care_parameters(:watering_one)
  end

  test 'valid parameter' do
    assert_predicate @parameter, :valid?
  end

  test 'invalid without action_type' do
    @parameter.action_type = nil

    assert_not @parameter.valid?
  end

  test 'invalid without interval_days' do
    @parameter.interval_days = nil

    assert_not @parameter.valid?
  end

  test 'interval_days must be greater than 0' do
    @parameter.interval_days = 0

    assert_not @parameter.valid?
  end

  test 'uniqueness scoped to plant' do
    duplicate = @plant.care_parameters.build(action_type: :watering, interval_days: 10)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:action_type], 'has already been taken'
  end

  test 'action_type enum exposes boolean predicates' do
    assert_predicate @parameter, :watering?
    assert_not @parameter.fertilization?
    assert_not @parameter.insecticide?
  end
end
