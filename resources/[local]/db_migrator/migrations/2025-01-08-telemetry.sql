-- telemetry tables
CREATE TABLE IF NOT EXISTS telemetry_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  event_name VARCHAR(64) NOT NULL,
  player_id INT NOT NULL,
  citizenid VARCHAR(64) NOT NULL,
  payload JSON NOT NULL,
  created_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_event_time (event_name, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  action VARCHAR(64) NOT NULL,
  actor_id INT NOT NULL,
  citizenid VARCHAR(64) NOT NULL,
  target_id INT NOT NULL,
  target_citizenid VARCHAR(64) NOT NULL,
  details JSON NOT NULL,
  created_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_action_time (action, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


