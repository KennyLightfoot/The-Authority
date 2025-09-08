-- QA Bookkeeping Migration
-- Creates simple tables for tracking QA test results and server health

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

CREATE TABLE IF NOT EXISTS `server_health_log` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `metric_name` varchar(50) NOT NULL,
    `metric_value` varchar(255) NOT NULL,
    `recorded_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `metric_name` (`metric_name`),
    KEY `recorded_at` (`recorded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

