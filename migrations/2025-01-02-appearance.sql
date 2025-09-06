-- Illenium Appearance Migration
-- Creates necessary tables for character appearance system

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

