
## DB Login

```
docker-compose exec mysql bash -c "mysql --defaults-extra-file=/root/mysql-dbaccess.cnf test_database"
```

## Init Database

```
docker-compose exec mysql bash -c "mysql --defaults-extra-file=/root/mysql-dbaccess.cnf test_database < /docker-entrypoint-initdb.d/initial.sql"
```

## Test Data Creating

```sql
-- users
INSERT INTO users(
    `user_no`,
    `name`,
    `note`,
    `gender`,
    `created_at`,
    `updated_at`
)
SELECT
    CONCAT('U-', LPAD(@rownum := @rownum + 1, 8, '0')),
    CASE WHEN @rownum = 3 THEN NULL ELSE CONCAT('NAME-', RPAD(@rownum, 5, '0')) END,
    CASE WHEN @rownum IN (10000, 20000, 30000) THEN CONCAT(REPEAT('a', 251), RPAD(@rownum, 5, '0')) ELSE CONCAT('NOTE', RPAD(@rownum, 5, '0')) END,
    MOD(@rownum, 2) + 1,
    now(),
    now()
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

-- scores
INSERT INTO scores(
    `game_id`,
    `user_id`,
    `score`,
    `created_at`,
    `updated_at`
)
SELECT
    MOD(`id`, 10),
    `id`,
    MOD(`id`, 1000),
    now(),
    now()
FROM
    users
UNION ALL
SELECT
    MOD(`id`, 10) + 1,
    `id`,
    MOD(`id`, 1000),
    now(),
    now()
FROM
    users
WHERE
    id < 500000
UNION ALL
SELECT
    MOD(`id`, 10) + 3,
    `id`,
    MOD(`id`, 1000),
    now(),
    now()
FROM
    users
WHERE
    id >= 500000
;
```
