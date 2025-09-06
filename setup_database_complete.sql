-- The Authority - Complete Database Setup Script
-- Run this script to set up your MySQL database with all required tables

-- Create the database
CREATE DATABASE IF NOT EXISTS authority;

-- Create a dedicated user for FiveM
-- Replace 'Kifelife420$' with your actual password if different
CREATE USER IF NOT EXISTS 'fivem'@'localhost' IDENTIFIED BY 'Kifelife420$';

-- Grant all privileges on the authority database to the fivem user
GRANT ALL PRIVILEGES ON authority.* TO 'fivem'@'localhost';

-- Apply the changes
FLUSH PRIVILEGES;

-- Use the authority database
USE authority;

-- =============================================================================
-- CORE QBX TABLES
-- =============================================================================

-- Players table
CREATE TABLE IF NOT EXISTS `players` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `cid` int(11) DEFAULT NULL,
    `license` varchar(255) NOT NULL,
    `name` varchar(255) NOT NULL,
    `money` text,
    `charinfo` text,
    `job` text,
    `gang` text,
    `position` text,
    `metadata` text,
    `inventory` longtext,
    `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`citizenid`),
    KEY `id` (`id`),
    KEY `last_updated` (`last_updated`),
    KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- RENEWED BANKING TABLES
-- =============================================================================

-- Bank accounts (fixed version without default values for longtext)
CREATE TABLE IF NOT EXISTS `bank_accounts_new` (
    `id` varchar(50) NOT NULL,
    `amount` int(11) DEFAULT 0,
    `transactions` longtext,
    `auth` longtext,
    `isFrozen` int(11) DEFAULT 0,
    `creator` varchar(50) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Player transactions
CREATE TABLE IF NOT EXISTS `player_transactions` (
    `id` varchar(50) NOT NULL,
    `isFrozen` int(11) DEFAULT 0,
    `transactions` longtext,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bank accounts (alternative structure)
CREATE TABLE IF NOT EXISTS `bank_accounts` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `account_name` varchar(50) NOT NULL DEFAULT 'Checking',
    `account_balance` int(11) NOT NULL DEFAULT 500,
    `account_type` enum('current','savings','business') NOT NULL DEFAULT 'current',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `citizenid_account` (`citizenid`, `account_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bank statements
CREATE TABLE IF NOT EXISTS `bank_statements` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `account_name` varchar(50) NOT NULL DEFAULT 'Checking',
    `amount` int(11) NOT NULL,
    `reason` varchar(255) NOT NULL,
    `statement_type` enum('deposit','withdraw') NOT NULL DEFAULT 'deposit',
    `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- VEHICLE TABLES
-- =============================================================================

-- Player vehicles
CREATE TABLE IF NOT EXISTS `player_vehicles` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `license` varchar(50) DEFAULT NULL,
    `citizenid` varchar(50) DEFAULT NULL,
    `vehicle` varchar(50) DEFAULT NULL,
    `hash` varchar(50) DEFAULT NULL,
    `mods` longtext,
    `plate` varchar(15) NOT NULL,
    `fakeplate` varchar(50) DEFAULT NULL,
    `garage` varchar(50) DEFAULT NULL,
    `fuel` int(11) DEFAULT 100,
    `engine` float DEFAULT 1000,
    `body` float DEFAULT 1000,
    `state` int(11) DEFAULT 1,
    `depotprice` int(11) NOT NULL DEFAULT 0,
    `drivingdistance` int(50) DEFAULT NULL,
    `status` text,
    `balance` int(11) NOT NULL DEFAULT 0,
    `paymentamount` int(11) NOT NULL DEFAULT 0,
    `paymentsleft` int(11) NOT NULL DEFAULT 0,
    `financetime` int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `plate` (`plate`),
    KEY `citizenid` (`citizenid`),
    KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Owned vehicles (for ox_inventory compatibility)
CREATE TABLE IF NOT EXISTS `owned_vehicles` (
    `owner` varchar(46) DEFAULT NULL,
    `plate` varchar(12) NOT NULL,
    `vehicle` longtext DEFAULT NULL,
    `type` varchar(20) NOT NULL DEFAULT 'car',
    `job` varchar(20) DEFAULT NULL,
    `stored` tinyint(1) NOT NULL DEFAULT 0,
    `parking` varchar(60) DEFAULT NULL,
    `pound` varchar(60) DEFAULT NULL,
    PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vehicle categories
CREATE TABLE IF NOT EXISTS `vehicle_categories` (
    `name` varchar(60) NOT NULL,
    `label` varchar(60) NOT NULL,
    PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default vehicle categories
INSERT IGNORE INTO `vehicle_categories` (`name`, `label`) VALUES
('compacts', 'Compacts'),
('sedans', 'Sedans'),
('suvs', 'SUVs'),
('coupes', 'Coupes'),
('muscle', 'Muscle'),
('sportsclassics', 'Sports Classics'),
('sports', 'Sports'),
('super', 'Super'),
('motorcycles', 'Motorcycles'),
('offroad', 'Off-Road'),
('industrial', 'Industrial'),
('utility', 'Utility'),
('vans', 'Vans'),
('cycles', 'Cycles'),
('boats', 'Boats'),
('helicopters', 'Helicopters'),
('planes', 'Planes'),
('service', 'Service'),
('emergency', 'Emergency'),
('military', 'Military'),
('commercial', 'Commercial');

-- =============================================================================
-- APPEARANCE TABLES
-- =============================================================================

-- Player skins
CREATE TABLE IF NOT EXISTS `playerskins` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(255) NOT NULL,
    `model` varchar(255) NOT NULL,
    `skin` text,
    `active` tinyint(4) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`),
    KEY `active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Player outfits
CREATE TABLE IF NOT EXISTS `player_outfits` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(255) NOT NULL,
    `outfitname` varchar(50) NOT NULL,
    `model` varchar(50) NOT NULL,
    `props` text,
    `components` text,
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- INVENTORY TABLES
-- =============================================================================

-- Licenses table (for ox_inventory)
CREATE TABLE IF NOT EXISTS `licenses` (
    `type` varchar(60) NOT NULL,
    `label` varchar(60) NOT NULL,
    PRIMARY KEY (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default licenses
INSERT IGNORE INTO `licenses` (`type`, `label`) VALUES
('weapon', 'Weapon License'),
('driver', 'Driver License'),
('business', 'Business License');

-- =============================================================================
-- QA TOOLS TABLES
-- =============================================================================

-- QA test results
CREATE TABLE IF NOT EXISTS `qa_test_results` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `test_name` varchar(100) NOT NULL,
    `status` enum('pass','fail','warning') NOT NULL,
    `details` text,
    `executed_by` varchar(50) DEFAULT NULL,
    `executed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `test_name` (`test_name`),
    KEY `executed_at` (`executed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Server health log
CREATE TABLE IF NOT EXISTS `server_health_log` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `metric_name` varchar(50) NOT NULL,
    `metric_value` varchar(255) NOT NULL,
    `recorded_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `metric_name` (`metric_name`),
    KEY `recorded_at` (`recorded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- DATABASE MIGRATIONS TRACKING
-- =============================================================================

-- Migrations table
CREATE TABLE IF NOT EXISTS `db_migrations` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `filename` varchar(255) NOT NULL,
    `applied_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `filename` (`filename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- PLACEHOLDER TABLES (to prevent warnings)
-- =============================================================================

-- Properties (placeholder)
CREATE TABLE IF NOT EXISTS `properties` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `label` varchar(255) NOT NULL,
    `coords` text,
    `owner` varchar(50) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Apartments (placeholder)
CREATE TABLE IF NOT EXISTS `apartments` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `label` varchar(255) NOT NULL,
    `coords` text,
    `tenant` varchar(50) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Player houses (placeholder)
CREATE TABLE IF NOT EXISTS `player_houses` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `house` varchar(50) NOT NULL,
    `identifier` varchar(50) NOT NULL,
    `citizenid` varchar(50) NOT NULL,
    `keyholders` text,
    `decorations` text,
    `stash` text,
    `outfit` text,
    `logout` text,
    PRIMARY KEY (`id`),
    KEY `house` (`house`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Player mails (placeholder)
CREATE TABLE IF NOT EXISTS `player_mails` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `sender` varchar(50) NOT NULL,
    `subject` varchar(100) NOT NULL,
    `message` text NOT NULL,
    `read` tinyint(4) DEFAULT 0,
    `mailid` int(11) NOT NULL,
    `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `button` text,
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Player groups (placeholder)
CREATE TABLE IF NOT EXISTS `player_groups` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `group` varchar(50) NOT NULL,
    `grade` int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- NPWD placeholder tables
CREATE TABLE IF NOT EXISTS `npwd_darkchat_channel_members` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `channel_id` int(11) NOT NULL,
    `phone_number` varchar(20) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_marketplace_listings` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(48) DEFAULT NULL,
    `phone` varchar(15) DEFAULT NULL,
    `title` varchar(100) DEFAULT NULL,
    `url` varchar(255) DEFAULT NULL,
    `description` varchar(255) DEFAULT NULL,
    `price` int(11) DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_messages_participants` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `conversation_id` varchar(512) NOT NULL,
    `participant` varchar(255) NOT NULL,
    `unread_count` int(11) DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_notes` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(48) DEFAULT NULL,
    `title` varchar(100) NOT NULL,
    `content` varchar(255) NOT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_phone_gallery` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(48) DEFAULT NULL,
    `image` varchar(255) NOT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_twitter_profiles` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(48) DEFAULT NULL,
    `profile_name` varchar(90) NOT NULL,
    `avatar_url` varchar(255) DEFAULT 'https://i.file.glass/QrEvq.png',
    `bio` varchar(160) DEFAULT NULL,
    `location` varchar(30) DEFAULT NULL,
    `job` varchar(30) DEFAULT NULL,
    `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_match_profiles` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(48) DEFAULT NULL,
    `name` varchar(90) NOT NULL,
    `image` varchar(255) NOT NULL,
    `bio` varchar(512) DEFAULT NULL,
    `location` varchar(45) DEFAULT NULL,
    `job` varchar(45) DEFAULT NULL,
    `tags` varchar(255) NOT NULL DEFAULT '',
    `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Show that the database setup is complete
SELECT 'Database setup complete! All required tables have been created.' AS status;
