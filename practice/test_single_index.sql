show tables;

# 只有主键索引的情况下，利用主键id排序，可以利用到主键索引,但是需要扫描全表
explain select *
from scores
where game_id = 8 order by id;

explain
select *
from scores
where game_id = 8
order by user_id;

# 查询每场游戏的人数 596
explain select game_id, count(1) from scores group by game_id;
select count(1) from scores;
# 580 ms 2000000 百万, 构建索引花费时间：completed in 5 s 498 ms
alter table scores add index `idx_game_id`(`game_id`);
alter table scores drop index `idx_game_id`;
[
{
  "id": 1,
  "select_type": "SIMPLE",
  "table": "scores",
  "partitions": null,
  "type": "ALL",
  "possible_keys": null,
  "key": null,
  "key_len": null,
  "ref": null,
  "rows": 1744920,
  "filtered": 100,
  "Extra": "Using temporary"
  }
]

select * from scores order by game_id;
select * from scores order by user_id;

select * from scores order by game_id;