-- QBX Vehicles Migration
-- Creates necessary tables for vehicle system

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

