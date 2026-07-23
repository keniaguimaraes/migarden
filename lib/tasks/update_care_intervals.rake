namespace :plants do
  desc "Atualiza intervalos de cuidado baseado em pesquisa por especie"
  task update_care_intervals: :environment do
    RECOMMENDED = {
      "Spathiphyllum wallisii"    => { watering: 7,  fertilization: 30, insecticide: 60 },
      "Chlorophytum comosum"      => { watering: 7,  fertilization: 30, insecticide: 60 },
      "Euphorbia pulcherrima"     => { watering: 7,  fertilization: 30, insecticide: 60 },
      "Bougainvillea spectabilis" => { watering: 10, fertilization: 30, insecticide: 60 },
      "Sansevieria trifasciata"   => { watering: 15, fertilization: 60, insecticide: 90 },
    }.freeze

    stats = { updated: 0, created: 0, skipped: 0 }

    Plant.includes(:care_parameters).find_each do |plant|
      intervals = RECOMMENDED[plant.species]
      next unless intervals

      intervals.each do |action, target_days|
        param = plant.care_parameters.find { |cp| cp.action_type == action.to_s }

        if param
          if param.interval_days == target_days
            stats[:skipped] += 1
            next
          end
          old = param.interval_days
          param.update!(interval_days: target_days)
          stats[:updated] += 1
          puts format("  UPDATE %s#%s: %s %d->%d", plant.name, plant.id, action, old, target_days)
        else
          plant.care_parameters.create!(action_type: action, interval_days: target_days)
          stats[:created] += 1
          puts format("  CREATE %s#%s: %s=%d", plant.name, plant.id, action, target_days)
        end
      end
    end

    puts "\n=== RESUMO ==="
    puts "  Atualizados: #{stats[:updated]}"
    puts "  Criados:     #{stats[:created]}"
    puts "  Inalterados: #{stats[:skipped]}"
  end
end
