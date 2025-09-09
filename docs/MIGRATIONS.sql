-- Players: authority/onboarding (idempotent)
ALTER TABLE players
  ADD COLUMN IF NOT EXISTS authority_standing INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS heat_level INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS player_path ENUM('pioneer','rebel','undecided') DEFAULT 'undecided',
  ADD COLUMN IF NOT EXISTS onboarding_complete TINYINT(1) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS playtime_hours FLOAT DEFAULT 0;

-- Audit logs
CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  player_identifier VARCHAR(64) NOT NULL,
  action VARCHAR(48) NOT NULL,
  context JSON,
  ip_hash VARCHAR(64) NULL,
  idx_1 VARCHAR(64) NULL,
  idx_2 VARCHAR(64) NULL
) ENGINE=InnoDB;
CREATE INDEX IF NOT EXISTS idx_audit_ts ON audit_logs (ts);
CREATE INDEX IF NOT EXISTS idx_audit_player ON audit_logs (player_identifier);

-- Telemetry
CREATE TABLE IF NOT EXISTS telemetry_events (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  event_name VARCHAR(48) NOT NULL,
  player_identifier VARCHAR(64) NULL,
  payload JSON
) ENGINE=InnoDB;
CREATE INDEX IF NOT EXISTS idx_tel_evt ON telemetry_events (event_name, ts);

-- Court (lightweight placeholder)
CREATE TABLE IF NOT EXISTS court_cases (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  plaintiff VARCHAR(64) NOT NULL,
  defendant VARCHAR(64) NOT NULL,
  status ENUM('filed','hearing','decided','dismissed') DEFAULT 'filed',
  verdict JSON NULL
) ENGINE=InnoDB;


