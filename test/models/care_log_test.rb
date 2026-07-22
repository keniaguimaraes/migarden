require 'test_helper'

class CareLogTest < ActiveSupport::TestCase
  setup do
    @plant = plants(:one)
    @log = care_logs(:watering_log_one)
  end

  test 'valid log' do
    assert_predicate @log, :valid?
  end

  test 'invalid without action_type' do
    @log.action_type = nil

    assert_not @log.valid?
  end

  test 'invalid without performed_at' do
    @log.performed_at = nil

    assert_not @log.valid?
  end

  test 'action_type enum exposes boolean predicates' do
    assert_predicate @log, :watering?
    assert_not @log.fertilization?
  end

  test 'destroying plant destroys its care logs' do
    plant = plants(:one)
    assert_difference -> { CareLog.count }, -plant.care_logs.count do
      plant.destroy
    end
  end
end
