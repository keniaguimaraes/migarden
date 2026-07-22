class CalendarController < ApplicationController
  def index
    @month = parse_month_param
    @selected_date = parse_date_param

    plants = current_user.plants
                         .includes(:care_parameters, :care_logs, { photo_attachment: :blob })

    @from_date = Date.current
    @to_date = 30.days.from_now

    @calendar_data = build_calendar_data(plants, @from_date, @to_date)

    @counts = {
      watering: plants.count(&:needs_watering?),
      fertilization: plants.count(&:needs_fertilization?),
      pest_control: plants.count(&:needs_pest_control?)
    }

    @day_events = @selected_date ? (@calendar_data[@selected_date] || []) : []

    @weeks = build_month_weeks(@month)
  end

  private

  def parse_month_param
    return Date.current.beginning_of_month unless params[:month].present?

    Date.parse(params[:month]).beginning_of_month
  rescue ArgumentError
    Date.current.beginning_of_month
  end

  def parse_date_param
    return nil unless params[:date].present?

    Date.parse(params[:date])
  rescue ArgumentError
    nil
  end

  def build_calendar_data(plants, from, to)
    data = Hash.new { |h, k| h[k] = [] }
    plants.each do |plant|
      plant.upcoming_care_events(from: from, to: to).each do |event|
        data[event[:date]] << { plant: plant, action: event[:action] }
      end
    end
    data
  end

  def build_month_weeks(month)
    first = month.beginning_of_month
    last = month.end_of_month
    start_date = first.beginning_of_week(:sunday)
    end_date = last.end_of_week(:sunday)

    weeks = []
    current = start_date
    while current <= end_date
      week = []
      7.times do
        week << current
        current += 1.day
      end
      weeks << week
    end
    weeks
  end
end
