require 'test_helper'

class PlantTest < ActiveSupport::TestCase
  setup do
    @plant = plants(:one)
  end

  test 'valid plant' do
    assert_predicate @plant, :valid?
  end

  test 'invalid without name' do
    @plant.name = nil

    assert_not @plant.valid?
    assert_includes @plant.errors[:name], 'não pode ficar em branco'
  end

  test 'invalid without plant_type' do
    @plant.plant_type = nil

    assert_not @plant.valid?
    assert_includes @plant.errors[:plant_type], 'não pode ficar em branco'
  end

  test 'invalid without sun_exposure' do
    @plant.sun_exposure = nil

    assert_not @plant.valid?
  end

  test 'rejects sun_exposure outside allowed values' do
    @plant.sun_exposure = 'galatic'

    assert_not @plant.valid?
    assert_includes @plant.errors[:sun_exposure], 'não está incluído na lista'
  end

  test 'accepts known sun_exposure values' do
    %w[sombra meia_sombra sol].each do |exposure|
      @plant.sun_exposure = exposure

      assert_predicate @plant, :valid?, "#{exposure} should be valid"
    end
  end

  test 'sun_exposure_label translates' do
    assert_equal 'Meia Sombra', Plant.new(sun_exposure: 'meia_sombra').sun_exposure_label
    assert_equal 'Sol',        Plant.new(sun_exposure: 'sol').sun_exposure_label
    assert_equal 'Sombra',     Plant.new(sun_exposure: 'sombra').sun_exposure_label
  end

  test 'parameter_for returns the matching CareParameter' do
    assert_equal care_parameters(:watering_one), @plant.parameter_for(:watering)
  end

  test 'parameter_for returns nil when no parameter exists' do
    assert_nil @plant.parameter_for(:insecticide) if @plant.care_parameters.where(action_type: :insecticide).none?
  end

  test 'last_care_for returns the most recent CareLog' do
    assert_equal care_logs(:watering_log_one), @plant.last_care_for(:watering)
  end

  test 'next_watering_date is last watering plus interval' do
    expected = care_logs(:watering_log_one).performed_at + 7.days

    assert_equal expected, @plant.next_watering_date
  end

  test 'needs_watering? is true when next date is today or earlier' do
    @plant.care_logs.create!(action_type: :watering, performed_at: 30.days.ago.to_date)

    assert_predicate @plant, :needs_watering?
  end

  test 'needs_watering? is false when last watering is recent' do
    @plant.care_logs.create!(action_type: :watering, performed_at: Date.current)

    assert_not @plant.needs_watering?
  end

  test 'needs_any_care? is true when any care is pending' do
    @plant.care_logs.create!(action_type: :watering, performed_at: 30.days.ago.to_date)

    assert_predicate @plant, :needs_any_care?
  end

  test 'care_status returns em_dia when nothing is pending' do
    @plant.care_logs.create!(action_type: :watering, performed_at: Date.current)
    @plant.care_logs.create!(action_type: :fertilization, performed_at: Date.current)
    @plant.care_logs.create!(action_type: :insecticide, performed_at: Date.current)

    assert_equal 'em_dia', @plant.care_status
  end

  test 'care_status returns atrasada when something is pending' do
    @plant.care_logs.create!(action_type: :watering, performed_at: 30.days.ago.to_date)

    assert_equal 'atrasada', @plant.care_status
  end

  test 'destroys dependent care_parameters and care_logs' do
    plant = plants(:one)
    assert_difference -> { CareParameter.count }, -plant.care_parameters.count do
      assert_difference -> { CareLog.count }, -plant.care_logs.count do
        plant.destroy
      end
    end
  end
end
