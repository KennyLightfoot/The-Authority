-- Authority system sidecar tables

-- player_meta (sidecar for custom stats)
CREATE TABLE IF NOT EXISTS player_meta (
  id INT AUTO_INCREMENT PRIMARY KEY,
  citizenid VARCHAR(64) NOT NULL UNIQUE,
  authority_standing TINYINT NOT NULL DEFAULT 0,
  heat_level TINYINT UNSIGNED NOT NULL DEFAULT 0,
  player_path VARCHAR(16) NOT NULL DEFAULT 'undecided',
  onboarding_complete BOOLEAN NOT NULL DEFAULT FALSE,
  playtime_minutes INT UNSIGNED NOT NULL DEFAULT 0,
  resistance_pass_level SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  resistance_pass_xp INT UNSIGNED NOT NULL DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_citizenid (citizenid),
  INDEX idx_path (player_path),
  INDEX idx_updated (last_updated)
);

-- authority_events (auditable changes)
CREATE TABLE IF NOT EXISTS authority_events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  citizenid VARCHAR(64) NOT NULL,
  event_type VARCHAR(50) NOT NULL,
  standing_change TINYINT NOT NULL,
  note VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_citizenid (citizenid),
  INDEX idx_created (created_at)
);

-- heat_zones (flexible geometry)
CREATE TABLE IF NOT EXISTS heat_zones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  zone_name VARCHAR(100) NOT NULL,
  zone_type ENUM('circle','poly') NOT NULL DEFAULT 'circle',
  geometry JSON NOT NULL,
  heat_level TINYINT UNSIGNED NOT NULL DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_zone_name (zone_name),
  INDEX idx_updated (last_updated)
);
