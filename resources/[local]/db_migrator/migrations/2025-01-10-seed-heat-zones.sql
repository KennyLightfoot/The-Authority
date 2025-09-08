-- Seed initial heat zones
INSERT INTO heat_zones (zone_name, zone_type, geometry, heat_level)
VALUES
  ('legion_square', 'circle', JSON_OBJECT('center', JSON_ARRAY(200.0, -1000.0, 30.0), 'radius', 100.0), 0),
  ('paleto_bay', 'circle', JSON_OBJECT('center', JSON_ARRAY(-100.0, 6500.0, 32.0), 'radius', 80.0), 0);
