SET GLOBAL log_bin_trust_function_creators = TRUE;

--  随机日期函数
DELIMITER ;
DROP FUNCTION IF EXISTS test_database.rand_datetime;
DELIMITER $$
CREATE FUNCTION test_database.rand_datetime()
    RETURNS VARCHAR(255)
BEGIN
    DECLARE nDateTime CHAR(19) DEFAULT '';
    SET nDateTime = CONCAT(CONCAT(2010 + FLOOR((RAND() * 8)), '-', LPAD(FLOOR(1 + (RAND() * 12)), 2, 0), '-',
                                  LPAD(FLOOR(3 + (RAND() * 8)), 2, 0)),
                           ' ',
                           CONCAT(LPAD(FLOOR(0 + (RAND() * 23)), 2, 0), ':', LPAD(FLOOR(0 + (RAND() * 60)), 2, 0), ':',
                                  LPAD(FLOOR(0 + (RAND() * 60)), 2, 0))
    );
RETURN nDateTime;
END $$

DROP TABLE IF EXISTS `numbers`;

CREATE TABLE IF NOT EXISTS `numbers` (
  `no`               INT
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `create_time`       Datetime DEFAULT NULL,
  `update_time`       Datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- users
INSERT INTO users(
    `user_no`,
    `name`,
    `note`,
    `gender`,
    `create_time`,
    `update_time`
)
SELECT
    CONCAT('U-', LPAD(@rownum := @rownum + 1, 8, '0')),
    CASE WHEN @rownum = 3 THEN NULL ELSE CONCAT('NAME-', RPAD(@rownum, 5, '0')) END,
    CASE WHEN @rownum IN (10000, 20000, 30000) THEN CONCAT(REPEAT('a', 251), RPAD(@rownum, 5, '0')) ELSE CONCAT('NOTE', RPAD(@rownum, 5, '0')) END,
    MOD(@rownum, 2) + 1,
    rand_datetime(),
    rand_datetime()
FROM
    numbers AS s1,
    numbers AS s2,
    numbers AS s3,
    numbers AS s4,
    numbers AS s5,
    numbers AS s6,
    (
        SELECT
            @rownum := 0
    ) AS v
;

DROP TABLE IF EXISTS `scores`;

CREATE TABLE IF NOT EXISTS `scores` (
  `id`               INT AUTO_INCREMENT,
  `user_id`          INT NOT NULL,
  `game_id`          INT NOT NULL,
  `score`            INT NOT NULL,
  `create_time`       Datetime DEFAULT NULL,
  `update_time`       Datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- scores
INSERT INTO `scores`(
    `game_id`,
    `user_id`,
    `score`,
    `create_time`,
    `update_time`
)
SELECT#
    MOD(`id`, 10),
    `id`,
    MOD(`id`, 1000),
    rand_datetime(),
    rand_datetime()
FROM
    users
UNION ALL
SELECT
        MOD(`id`, 10) + 1,
        `id`,
        MOD(`id`, 1000),
        rand_datetime(),
        rand_datetime()
FROM
    users
WHERE
        id < 500000
UNION ALL
SELECT
        MOD(`id`, 10) + 3,
        `id`,
        MOD(`id`, 1000),
        rand_datetime(),
        rand_datetime()
FROM
    users
WHERE
        id >= 500000;