
Multi-Range Read 优化（简称 MRR ）是 MySQL 5.6 之后才有的，通过 optimizer_switch （见参考文献[3]）中的两个参数来控制。

通过 mrr 和 mrr_cost_based 参数来控制。mrr 控制功能是否开启, mrr_cost_based 控制当 mrr=on 开启时，是否启用基于成本的 MRR

查看参数：
> show variables like 'optimizer_switch%'

设置参数：
> set optimizer_switch='mrr=on|off ,mrr_cost_based=on|off' 来进行设置

具体的例子：

强制使用 MRR
> set optimizer_switch='mrr=on ,mrr_cost_based=off'

基于成本使用 MRR
> set optimizer_switch='mrr=on ,mrr_cost_based=on'

在 EXPLAIN 输出的 EXTRA 信息中，你可能会看到 Using MRR 这一项。
如果基于成本使用 MRR，可能在EXTRA 中无法看到 Using MRR。

```sql
SHOW CREATE TABLE `scores`;

CREATE TABLE `scores` (
                          `id` int NOT NULL AUTO_INCREMENT,
                          `user_id` int NOT NULL,
                          `game_id` int NOT NULL,
                          `score` int NOT NULL,
                          `create_time` datetime DEFAULT NULL,
                          `update_time` datetime DEFAULT NULL,
                          PRIMARY KEY (`id`),
                          KEY `idx_user_id` (`user_id`),
                          KEY `idx_score` (`score`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
```


```sql
set optimizer_switch='mrr=on,mrr_cost_based=off'; # 强制使用 MRR

set optimizer_switch = 'index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=on,mrr=on,mrr_cost_based=on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on,use_invisible_indexes=off,skip_scan=on,hash_join=on';

EXPLAIN 
SELECT *
FROM scores
WHERE `user_id` BETWEEN 1 AND 500000 ORDER BY `user_id` ;

EXPLAIN
SELECT *
FROM scores
WHERE `user_id` BETWEEN 1 AND 2000
AND `score` BETWEEN 1 AND 2000;
```
| id | select\_type | table | partitions | type | possible\_keys | key | key\_len | ref | rows | filtered | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | SIMPLE | scores | NULL | range | idx\_user\_id | idx\_user\_id | 4 | NULL | 28760 | 100 | Using index condition; Using MRR |

```sql
EXPLAIN
SELECT score, id
FROM scores
WHERE `score` BETWEEN 1 AND 5000 LIMIT 500 ;
```


```sql
EXPLAIN
SELECT user_id
FROM scores
WHERE `user_id` BETWEEN 1 AND 50000
```
| id | select\_type | table | partitions | type | possible\_keys | key | key\_len | ref | rows | filtered | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | SIMPLE | scores | NULL | range | idx\_user\_id | idx\_user\_id | 4 | NULL | 28760 | 100 | Using where; Using index |



# 参考文献
- [1] 官方文档：[8.2.1.11 Multi-Range Read Optimization ](https://dev.mysql.com/doc/refman/8.0/en/mrr-optimization.html)
- [2] [MySQL 的 MRR 到底是什么？](https://zhuanlan.zhihu.com/p/110154066) 
- [3] 官方文档：[8.9.2 Switchable Optimizations](https://dev.mysql.com/doc/refman/8.0/en/switchable-optimizations.html)