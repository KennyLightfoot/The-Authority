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

