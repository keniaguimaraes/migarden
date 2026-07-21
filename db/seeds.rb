user = User.find_or_create_by!(email: "kenia@example.com") do |u|
  u.name = "Kenia"
  u.password = "123456"
end

plants_data = [
  {
    name: "Primavera",
    species: "Bougainvillea spectabilis",
    plant_type: "flor",
    sun_exposure: "sol",
    watering_days: 15,
    fertilization_days: 30,
    insecticide_days: 60
  },
  {
    name: "Lírio-da-paz",
    species: "Spathiphyllum wallisii",
    plant_type: "flor",
    sun_exposure: "meia_sombra",
    watering_days: 3,
    fertilization_days: 30,
    insecticide_days: 60
  },
  {
    name: "Clorofito",
    species: "Chlorophytum comosum",
    plant_type: "folhagem",
    sun_exposure: "meia_sombra",
    watering_days: 3,
    fertilization_days: 30,
    insecticide_days: 60
  },
  {
    name: "Ervas",
    species: "Mix de temperos",
    plant_type: "ervas",
    sun_exposure: "sol",
    watering_days: 3,
    fertilization_days: 15,
    insecticide_days: 60
  },
  {
    name: "Bico-de-papagaio",
    species: "Euphorbia pulcherrima",
    plant_type: "flor",
    sun_exposure: "meia_sombra",
    watering_days: 3,
    fertilization_days: 30,
    insecticide_days: 60
  },
  {
    name: "Jiboia",
    species: "Epipremnum aureum",
    plant_type: "folhagem",
    sun_exposure: "meia_sombra",
    watering_days: 7,
    fertilization_days: 30,
    insecticide_days: 60
  },
  {
    name: "Monstera",
    species: "Monstera deliciosa",
    plant_type: "folhagem",
    sun_exposure: "meia_sombra",
    watering_days: 7,
    fertilization_days: 45,
    insecticide_days: 60
  },
  {
    name: "Aglaonema",
    species: "Aglaonema commutatum",
    plant_type: "folhagem",
    sun_exposure: "sombra",
    watering_days: 7,
    fertilization_days: 30,
    insecticide_days: 60
  },
  {
    name: "Peperômia",
    species: "Peperomia spp.",
    plant_type: "folhagem",
    sun_exposure: "meia_sombra",
    watering_days: 7,
    fertilization_days: 45,
    insecticide_days: 60
  },
  {
    name: "Espada-de-São-Jorge",
    species: "Sansevieria trifasciata",
    plant_type: "folhagem",
    sun_exposure: "meia_sombra",
    watering_days: 15,
    fertilization_days: 60,
    insecticide_days: 90
  },
  {
    name: "Zamioculca",
    species: "Zamioculcas zamiifolia",
    plant_type: "folhagem",
    sun_exposure: "sombra",
    watering_days: 15,
    fertilization_days: 60,
    insecticide_days: 90
  },
  {
    name: "Babosa",
    species: "Aloe vera",
    plant_type: "suculenta",
    sun_exposure: "sol",
    watering_days: 15,
    fertilization_days: 60,
    insecticide_days: 90
  },
  {
    name: "Rosa-do-deserto",
    species: "Adenium obesum",
    plant_type: "suculenta",
    sun_exposure: "sol",
    watering_days: 15,
    fertilization_days: 30,
    insecticide_days: 60
  }
]

plants_data.each do |data|
  plant = Plant.find_or_create_by!(name: data[:name], user: user) do |p|
    p.species = data[:species]
    p.plant_type = data[:plant_type]
    p.sun_exposure = data[:sun_exposure]
  end

  { watering: data[:watering_days],
    fertilization: data[:fertilization_days],
    insecticide: data[:insecticide_days] }.each do |action, interval|
    CareParameter.find_or_create_by!(plant: plant, action_type: action) do |cp|
      cp.interval_days = interval
    end
  end

  puts "  #{plant.name} criada com parâmetros de cuidado"
end
