module ApplicationHelper
  def current_interval(plant, action_type)
    return nil unless plant.persisted?

    plant.parameter_for(action_type)&.interval_days
  end

  def status_badge_class(plant)
    plant.needs_any_care? ? 'badge badge--danger' : 'badge badge--success'
  end

  def status_label(plant)
    plant.needs_any_care? ? 'Precisa de cuidado' : 'Em dia'
  end

  def sun_exposure_icon(sun_exposure)
    case sun_exposure
    when 'sol' then '☀️'
    when 'meia_sombra' then '⛅'
    when 'sombra' then '🌑'
    else '🌱'
    end
  end

  def format_br_date(date)
    return '—' if date.blank?

    date.strftime('%d/%m/%Y')
  end
end
