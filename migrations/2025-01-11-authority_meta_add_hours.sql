-- Add playtime_hours to player_meta and backfill from playtime_minutes
ALTER TABLE player_meta
  ADD COLUMN IF NOT EXISTS playtime_hours FLOAT NOT NULL DEFAULT 0;

-- Backfill existing rows (minutes -> hours)
UPDATE player_meta SET playtime_hours = ROUND(playtime_minutes / 60, 2);

-- Ensure sane bounds
ALTER TABLE player_meta
  MODIFY authority_standing TINYINT NOT NULL DEFAULT 0,
  MODIFY heat_level TINYINT UNSIGNED NOT NULL DEFAULT 0;


