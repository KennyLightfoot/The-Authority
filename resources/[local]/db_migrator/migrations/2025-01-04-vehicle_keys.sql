-- QBX Vehicle Keys Migration
-- Creates necessary tables for vehicle keys system

CREATE TABLE IF NOT EXISTS `vehicle_keys` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `plate` varchar(15) NOT NULL,
    `citizenid` varchar(50) NOT NULL,
    `key_type` enum('owner','temp','shared') NOT NULL DEFAULT 'owner',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `plate` (`plate`),
    KEY `citizenid` (`citizenid`),
    UNIQUE KEY `plate_citizenid` (`plate`, `citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

