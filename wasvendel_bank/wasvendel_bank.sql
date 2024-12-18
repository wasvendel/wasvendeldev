CREATE TABLE IF NOT EXISTS `wasvendel_bank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `charid` int(11) NOT NULL,
  `valentine` JSON DEFAULT (JSON_OBJECT('money', 0.00, 'storage', false, 'slot', 0)),
  `rhodes` JSON DEFAULT (JSON_OBJECT('money', 0.00, 'storage', false, 'slot', 0)),
  `blackwater` JSON DEFAULT (JSON_OBJECT('money', 0.00, 'storage', false, 'slot', 0)),
  `saintdenis` JSON DEFAULT (JSON_OBJECT('money', 0.00, 'storage', false, 'slot', 0)),
  `tumbleweed` JSON DEFAULT (JSON_OBJECT('money', 0.00, 'storage', false, 'slot', 0)),
  `armadillo` JSON DEFAULT (JSON_OBJECT('money', 0.00, 'storage', false, 'slot', 0)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier_charid` (`identifier`, `charid`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;
