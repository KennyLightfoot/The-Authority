-- NPWD Phone Migration (Optional - for future use)
-- Creates necessary tables for phone system

CREATE TABLE IF NOT EXISTS `npwd_calls` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(46) DEFAULT NULL,
    `transmitter` varchar(255) NOT NULL,
    `receiver` varchar(255) NOT NULL,
    `is_accepted` tinyint(4) DEFAULT 0,
    `start` varchar(255) DEFAULT NULL,
    `end` varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_messages` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `message` varchar(512) NOT NULL,
    `user_identifier` varchar(48) NOT NULL,
    `conversation_id` varchar(512) NOT NULL,
    `participant` varchar(225) NOT NULL,
    `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `visible` tinyint(4) NOT NULL DEFAULT 1,
    `author` varchar(255) NOT NULL,
    `is_embed` tinyint(4) NOT NULL DEFAULT 0,
    `embed` varchar(512) DEFAULT '{}',
    PRIMARY KEY (`id`),
    KEY `user_identifier` (`user_identifier`),
    KEY `conversation_id` (`conversation_id`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_phone_contacts` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(46) DEFAULT NULL,
    `avatar` varchar(255) DEFAULT NULL,
    `number` varchar(20) DEFAULT NULL,
    `display` varchar(255) NOT NULL DEFAULT '',
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

