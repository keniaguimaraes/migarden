class Plant < ApplicationRecord
  SUN_EXPOSURES = %w[sombra meia_sombra sol].freeze

  belongs_to :user
  has_many :care_parameters, dependent: :destroy
  has_many :care_logs, dependent: :destroy
  has_one_attached :photo

  validates :name, presence: true
  validates :plant_type, presence: true
  validates :sun_exposure, presence: true, inclusion: { in: SUN_EXPOSURES }

  accepts_nested_attributes_for :care_parameters

  def sun_exposure_label
    case sun_exposure
    when 'sombra' then 'Sombra'
    when 'meia_sombra' then 'Meia Sombra'
    when 'sol' then 'Sol'
    else sun_exposure
    end
  end

  def last_care_for(action_type)
    care_logs.where(action_type: action_type).order(performed_at: :desc).first
  end

  def parameter_for(action_type)
    care_parameters.find_by(action_type: action_type)
  end

  def next_watering_date
    calculate_next_date(:watering)
  end

  def next_fertilization_date
    calculate_next_date(:fertilization)
  end

  def next_pest_control_date
    calculate_next_date(:insecticide)
  end

  CARE_ACTIONS = {
    watering: { icon: '💧', label: 'Rega' },
    fertilization: { icon: '🧪', label: 'Fertilização' },
    insecticide: { icon: '🐛', label: 'Controle de Pragas' }
  }.freeze

  def needs_watering?
    next_watering_date <= Date.current
  end

  def needs_fertilization?
    next_fertilization_date <= Date.current
  end

  def needs_pest_control?
    next_pest_control_date <= Date.current
  end

  def needs_any_care?
    needs_watering? || needs_fertilization? || needs_pest_control?
  end

  def care_status
    needs_any_care? ? 'atrasada' : 'em_dia'
  end

  def upcoming_care_events(from: Date.current, to: 30.days.from_now)
    events = []
    CARE_ACTIONS.each_key do |action_type|
      parameter = parameter_for(action_type)
      next unless parameter

      last_log = last_care_for(action_type)
      next_date = last_log ? last_log.performed_at.to_date + parameter.interval_days : Date.current

      while next_date <= to
        events << { date: next_date, action: action_type } if next_date >= from
        next_date += parameter.interval_days
      end
    end
    events.sort_by { |e| [e[:date], e[:action].to_s] }
  end

  private

  def calculate_next_date(action_type)
    parameter = parameter_for(action_type)
    return Date.current unless parameter

    last_log = last_care_for(action_type)
    return Date.current unless last_log

    last_log.performed_at + parameter.interval_days.days
  end
end
