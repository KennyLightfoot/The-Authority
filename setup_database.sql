-- The Authority - Database Setup Script
-- Run this script to set up your MySQL database

-- Create the database
CREATE DATABASE IF NOT EXISTS authority;

-- Create a dedicated user for FiveM
-- Replace 'your_secure_password' with a strong password
CREATE USER IF NOT EXISTS 'fivem'@'localhost' IDENTIFIED BY 'your_secure_password';

-- Grant all privileges on the authority database to the fivem user
GRANT ALL PRIVILEGES ON authority.* TO 'fivem'@'localhost';

-- Apply the changes
FLUSH PRIVILEGES;

-- Use the authority database
USE authority;

-- Create bans table for qbx_core
CREATE TABLE IF NOT EXISTS `bans` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `license` varchar(50) NOT NULL,
    `expire` bigint(20) DEFAULT NULL,
    `reason` varchar(255) DEFAULT NULL,
    `bannedby` varchar(50) DEFAULT NULL,
    `bantime` bigint(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create or update players table with all required columns
CREATE TABLE IF NOT EXISTS `players` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `cid` int(11) NOT NULL,
    `userId` INT UNSIGNED DEFAULT NULL,
    `citizenid` varchar(50) NOT NULL,
    `license` varchar(255) DEFAULT NULL,
    `name` varchar(255) NOT NULL,
    `money` longtext DEFAULT NULL,
    `charinfo` longtext DEFAULT NULL,
    `job` longtext DEFAULT NULL,
    `gang` longtext DEFAULT NULL,
    `position` longtext DEFAULT NULL,
    `metadata` longtext DEFAULT NULL,
    `inventory` longtext DEFAULT NULL,
    `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    `last_logged_out` timestamp NULL DEFAULT NULL,
    PRIMARY KEY (`citizenid`),
    KEY `id` (`id`),
    KEY `cid` (`cid`),
    KEY `last_updated` (`last_updated`),
    KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create player_groups table for QBX groups system
CREATE TABLE IF NOT EXISTS `player_groups` (
    `citizenid` varchar(50) NOT NULL,
    `group` varchar(50) NOT NULL,
    `type` varchar(50) DEFAULT 'job',
    `grade` int(11) DEFAULT 0,
    PRIMARY KEY (`citizenid`, `group`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Show that the database is ready
SELECT 'Database setup complete! You can now start your FiveM server.' AS status;


