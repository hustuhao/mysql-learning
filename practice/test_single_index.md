
# 查询每 game_id 参加的游戏人数

## 有索引 idx_game_id

## SQL1
```SQL
select game_id, count(1) from scores group by game_id;
```

加入索引：上述SQL的查询时间为 314 ms
```SQL

# 向 2百万 数据表增加索引，花费了 7 s
alter table scores add index `idx_game_id`(`game_id`);
# 删除索引很快，只用了 46 ms
alter table scores drop index `idx_game_id`; 
```
查询计划：
```JSON
[
  {
    "id": 1,
    "select_type": "SIMPLE",
    "table": "scores",
    "partitions": null,
    "type": "index",
    "possible_keys": "idx_game_id",
    "key": "idx_game_id",
    "key_len": "4",
    "ref": null,
    "rows": 1744920,
    "filtered": 100,
    "Extra": "Using index"
  }
]
```

### SQL2
增加索引 idx_game_id 之后 ,400ms
```json
{
  "data":
  [
    {
      "id": 1,
      "select_type": "SIMPLE",
      "table": "scores",
      "partitions": null,
      "type": "index",
      "possible_keys": "idx_game_id",
      "key": "idx_game_id",
      "key_len": "4",
      "ref": null,
      "rows": 1744920,
      "filtered": 100,
      "Extra": "Using index"
    }
  ]
}
```

### SQL3 
```SQL
select game_id, count(1)
from scores
group by game_id;
```
122ms

```json
{
	"data":
	[
		{
			"id": 1,
			"select_type": "SIMPLE",
			"table": "scores",
			"partitions": null,
			"type": "range",
			"possible_keys": "idx_game_id",
			"key": "idx_game_id",
			"key_len": "4",
			"ref": null,
			"rows": 1130134,
			"filtered": 100,
			"Extra": "Using where; Using index"
		}
	]
}
```

## 没有索引

### SQL1
```SQL
select game_id, count(1) from scores group by game_id;
```
没有 idx_game_id 索引的情况下：查询耗时 900ms 左右（可能根据机器的情况有出入）

查询计划：
```SQL
explain select game_id, count(1) from scores group by game_id;
```
结果：
```JSON
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
```

### SQL2 增加排序
查询计划：
```SQL
explain select game_id, count(1) from scores group by game_id order by game_id;
```
1.15s

输出 using temporary;using filesort 说明使用文件排序和磁盘临时表，应该尽量避免这种情况
```JSON
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
    "Extra": "Using temporary; Using filesort"
  }
]
```
### SQL3

500ms
```json
{
	"data":
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
			"filtered": 30,
			"Extra": "Using where; Using temporary"
		}
	]
}
```

### SQL4

```SQL
explain 
    select * from users order by id desc limit 10
```

```json
[
  {
    "id": 1,
    "select_type": "SIMPLE",
    "table": "users",
    "partitions": null,
    "type": "index",
    "possible_keys": null,
    "key": "PRIMARY",
    "key_len": "4",
    "ref": null,
    "rows": 10,
    "filtered": 100,
    "Extra": "Backward index scan"
  }
]
```


# 参考
https://zhuanlan.zhihu.com/p/311933050

https://stackoverflow.com/questions/13633406/using-index-using-temporary-using-filesort-how-to-fix-this

https://dev.mysql.com/doc/refman/8.0/en/internal-temporary-tables.html

参考第八章优化 Optimization

https://dev.mysql.com/doc/refman/8.0/en/execution-plan-information.html
