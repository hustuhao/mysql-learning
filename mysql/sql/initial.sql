DROP TABLE IF EXISTS `numbers`;

CREATE TABLE IF NOT EXISTS `numbers` (
  `no`               INT
);

INSERT INTO numbers (`no`) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10);


DROP TABLE IF EXISTS `users`;

CREATE TABLE IF NOT EXISTS `users` (
  `id`               INT AUTO_INCREMENT,
  `user_no`          VARCHAR(10) NOT NULL,
  `name`             VARCHAR(20),
  `note`             TEXT,
  `gender`           TINYINT NOT NULL COMMENT '1:male, 2:female',
  `created_at`       Datetime DEFAULT NULL,
  `updated_at`       Datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


DROP TABLE IF EXISTS `scores`;

CREATE TABLE IF NOT EXISTS `scores` (
  `id`               INT AUTO_INCREMENT,
  `user_id`          INT NOT NULL,
  `game_id`          INT NOT NULL,
  `score`            INT NOT NULL,
  `created_at`       Datetime DEFAULT NULL,
  `updated_at`       Datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
