-- Insere plantas e parâmetros de cuidado
-- Baseado na lista "Minhas Plantas" fornecida
-- Uso: psql -d migarden_production -f db/insert_plants.sql

-- Ajuste o email se necessário
WITH user_cte AS (
  SELECT id FROM users WHERE email = 'kenia@example.com'
),
plant_data (name, species, plant_type, sun_exposure, watering_interval, fertilization_interval, insecticide_interval) AS (
  VALUES
    ('Primavera',        'Bougainvillea spectabilis',  'flor',     'sol',         15, 30, 60),
    ('Lírio-da-paz',     'Spathiphyllum wallisii',     'flor',     'meia_sombra',  3, 30, 60),
    ('Clorofito',        'Chlorophytum comosum',       'folhagem', 'meia_sombra',  3, 30, 60),
    ('Ervas',            'Mix de temperos',             'ervas',    'sol',          3, 15, 60),
    ('Jiboia',           'Epipremnum aureum',           'folhagem', 'meia_sombra',  7, 30, 60),
    ('Monstera',         'Monstera deliciosa',          'folhagem', 'meia_sombra',  7, 45, 60),
    ('Aglaonema',        'Aglaonema commutatum',        'folhagem', 'sombra',       7, 30, 60),
    ('Peperômia',        'Peperomia spp.',              'folhagem', 'meia_sombra',  7, 45, 60),
    ('Espadas',          'Sansevieria trifasciata',     'folhagem', 'meia_sombra', 15, 60, 90),
    ('Zamioculca',       'Zamioculcas zamiifolia',      'folhagem', 'sombra',      15, 60, 90),
    ('Babosas',          'Aloe vera',                   'suculenta','sol',         15, 60, 90),
    ('Rosas-do-deserto', 'Adenium obesum',              'suculenta','sol',         15, 30, 60)
),
ins AS (
  INSERT INTO plants (name, species, plant_type, sun_exposure, user_id, created_at, updated_at)
  SELECT pd.name, pd.species, pd.plant_type, pd.sun_exposure, u.id, NOW(), NOW()
  FROM plant_data pd, user_cte u
  WHERE NOT EXISTS (
    SELECT 1 FROM plants p WHERE p.name = pd.name AND p.user_id = u.id
  )
  RETURNING id, name
)
INSERT INTO care_parameters (plant_id, action_type, interval_days, created_at, updated_at)
SELECT
  ins.id,
  a.action_type,
  CASE a.action_type
    WHEN 0 THEN pd.watering_interval
    WHEN 1 THEN pd.fertilization_interval
    WHEN 2 THEN pd.insecticide_interval
  END,
  NOW(),
  NOW()
FROM ins
JOIN plant_data pd ON pd.name = ins.name
CROSS JOIN (VALUES (0), (1), (2)) AS a(action_type)
WHERE NOT EXISTS (
  SELECT 1 FROM care_parameters cp
  WHERE cp.plant_id = ins.id AND cp.action_type = a.action_type
);
