
MySQL 选择索引错误的情况

## MySQL 选择索引的依据


```sql
# 增加索引： in 8 s 460 ms
ALTER TABLE users 
    ADD INDEX `idx_user_no`(`user_no`),
    ADD INDEX `idx_name`(`name`);
# 删除索引
ALTER TABLE users
    DROP INDEX `idx_user_no`,
    DROP INDEX `idx_name`;
```

```sql
SELECT *
FROM users
WHERE `user_no` >= 'U-00001000' and `user_no` <= 'U-00002000'
AND `name` >= 'NAME-10000' AND `name` <= 'NAME-20000' order by `name` desc limit 1
```

### scores 表
```sql
# 增加索引： in 8 s 460 ms
ALTER TABLE scores 
    ADD INDEX `idx_user_id`(`user_id`),
    ADD INDEX `idx_score`(`score`);
# 删除索引
ALTER TABLE scores
    DROP INDEX `idx_user_id`,
    DROP INDEX `idx_score`;
```

下面这条SQL使用了
```sql
EXPLAIN 
SELECT *
FROM scores
WHERE `user_id` >= 1000 and  `user_id` <= 2000
AND `score` >= 100000 AND `score` <= 200000 order by `score` desc limit 1
```

```json
[
  {
    "id": 1,
    "select_type": "SIMPLE",
    "table": "scores",
    "partitions": null,
    "type": "range",
    "possible_keys": "idx_user_id,idx_score",
    "key": "idx_score",
    "key_len": "4",
    "ref": null,
    "rows": 1,
    "filtered": 5,
    "Extra": "Using index condition; Using where; Backward index scan"
  }
]
```

```sql
SHOW INDEX FROM scores;
```
| Table | Non\_unique | Key\_name | Seq\_in\_index | Column\_name | Collation | Cardinality | Sub\_part | Packed | Null | Index\_type | Comment | Index\_comment | Visible | Expression |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| scores | 0 | PRIMARY | 1 | id | A | 1994337 | NULL | NULL |  | BTREE |  |  | YES | NULL |
| scores | 1 | idx\_user\_id | 1 | user\_id | A | 999463 | NULL | NULL |  | BTREE |  |  | YES | NULL |
| scores | 1 | idx\_score | 1 | score | A | 1001 | NULL | NULL |  | BTREE |  |  | YES | NULL |

可以看到基数的技术还是挺准确的。
主键大致有200万不同的值，user_id大致有10万，score 大致有1000。


https://dev.mysql.com/doc/refman/8.0/en/show-index.html

> 官方文档：An estimate of the number of unique values in the index. To update this number, run ANALYZE TABLE or (for MyISAM tables) myisamchk -a.
Cardinality is counted based on statistics stored as integers, so the value is not necessarily exact even for small tables. The higher the cardinality, the greater the chance that MySQL uses the index when doing joins.

索引区分度，索引上不同值的数目的估计值，使用 ANALYZE TABLE 更新这个值。
基数是基于存储的统计值计算的，所以这个值就算是对于小表也没必要准确。
基数 Cardinality 越大，MySQL 在join操作的时候使用改索引的概率越大。

A 执行事务
B 先删除所有的数据，后面再插入，SHOW INDEX FROM SCORES 可以看到：

```sql
START TRANSACTION;
                        -- scores
                        INSERT INTO scores(
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
                            id > 500000 AND id < 1000000
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
                            id >= 500000
                        ;
                        SHOW INDEX FROM scores;
select count(*) from scores;
COMMIT
```


```sql
ANALYZE TABLE scores;
SHOW INDEX from scores;

SELECT t.*
FROM test_database.scores t order by id desc
LIMIT 500;

EXPLAIN 
SELECT `user_id`
FROM scores FORCE INDEX(`idx_user_id`)
WHERE `user_id` >= 1000 and  `user_id` <= 2000
AND `score` >= 100000 AND `score` <= 200000 order by `score` desc limit 1
```


## 选错索引的一个解决方法

See Section 13.7.3.1, “ANALYZE TABLE Statement”. 

https://dev.mysql.com/doc/refman/8.0/en/analyze-table.html

> If you have a problem with indexes not being used when you believe that they should be, run ANALYZE TABLE to update table statistics, such as cardinality of keys, that can affect the choices the optimizer makes. See Section 13.7.3.1, “ANALYZE TABLE Statement”.
Optimizing Queries with EXPLAIN : https://dev.mysql.com/doc/refman/8.0/en/using-explain.html

如果你觉得查询语句的索引没有选择正确，可以使用 ANALYZE TABLE 命令，更新表的统计数据（比如索引基数），这些统计数据会影响优化器做决策。