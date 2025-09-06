-- Renewed Banking Migration
-- Creates necessary tables for the banking system

-- Fixed bank_accounts_new table (the one Renewed-Banking actually uses)
CREATE TABLE IF NOT EXISTS `bank_accounts_new` (
    `id` varchar(50) NOT NULL,
    `amount` int(11) DEFAULT 0,
    `transactions` longtext,
    `auth` longtext,
    `isFrozen` int(11) DEFAULT 0,
    `creator` varchar(50) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Player transactions table
CREATE TABLE IF NOT EXISTS `player_transactions` (
    `id` varchar(50) NOT NULL,
    `isFrozen` int(11) DEFAULT 0,
    `transactions` longtext,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Legacy bank_accounts table for compatibility
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

-- Insert default accounts for existing players (if any)
-- This will be handled by the banking resource on player join

