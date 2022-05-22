

建立索引时候需要关注的问题：索引对于数据的分区度，区分度越高，重复的键值越少，有利于加速查询。

# 全部索引和前序索引的比较

## 前序索引用不到覆盖索引


```sql
ALTER TABLE users ADD INDEX `idx_name`(`name`);
EXPLAIN SELECT id, name FROM users WHERE name = 'NAME-49700'
```

可以看到，全部索引不需要回表
| id | select\_type | table | partitions | type | possible\_keys | key | key\_len | ref | rows | filtered | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | SIMPLE | users | NULL | ref | idx\_name | idx\_name | 83 | const | 13 | 100 | Using index |

但是如果换成前缀索引：
```sql
ALTER TABLE users DROP INDEX `idx_name`;
ALTER TABLE users ADD INDEX `idx_name`(`name`(7));

EXPLAIN SELECT * FROM users WHERE user_no BETWEEN 'U-00000496' AND 'U-00500000'
```


可以给字符串加哪些索引？
- 全部索引：以整个字符串建立索引
- 前序索引：以字符串的前N位创建索引
- 倒序索引：和前序索引的顺序相反。存数据的时候，对数据进行倒序，将倒序的结果存入数据库。
- Hash 字段索引：增加一个字段记录索引字段的哈希值，用于快速比较两个值是否相等。


先比较全部索引和前序索引：
```sql
alter table users add index `idx_user_no`(`user_no`);

#  NAME-20000
alter table users add index `idx_user_no`(`user_no`(4));
```



为什么要使用前缀索引：索引越长，占用磁盘空间就越大（如何计算?），相同的数据也能够存放的索引指针就越少，搜索的效率就会越低。


前缀索引：



计算有多少个不同的值：
```sql
SELECT COUNT(1) FROM users;
# 100万
SELECT COUNT(DISTINCT user_no) AS L1 FROM users;

# 100万
SELECT COUNT(DISTINCT(left(user_no,1))) as L1,     # 1
       COUNT(DISTINCT(left(user_no,2))) as L2,     # 1
       COUNT(DISTINCT(left(user_no,3))) as L3,     # 1
       COUNT(DISTINCT(left(user_no,4))) as L4,     # 2
       COUNT(DISTINCT(left(user_no,5))) as L5,     # 11
       COUNT(DISTINCT(left(user_no,6))) as L6,     # 101
       COUNT(DISTINCT(left(user_no,7))) as L7,     # 1001
       COUNT(DISTINCT(left(user_no,8))) as L8,     # 10001
       COUNT(DISTINCT(left(user_no,9))) as L9,     # 100001         
       COUNT(DISTINCT(left(user_no,10))) as L10    # 1000000
FROM users;

# NAME

SELECT COUNT(DISTINCT(left(name,1))) as L1,     # 1
       COUNT(DISTINCT(left(name,2))) as L2,     # 1
       COUNT(DISTINCT(left(name,3))) as L3,     # 1
       COUNT(DISTINCT(left(name,4))) as L4,     # 2
       COUNT(DISTINCT(left(name,5))) as L5,     # 11
       COUNT(DISTINCT(left(name,6))) as L6,     # 101
       COUNT(DISTINCT(left(name,7))) as L7,     # 1001
       COUNT(DISTINCT(left(name,8))) as L8,     # 10001
       COUNT(DISTINCT(left(name,9))) as L9,     # 100001         
       COUNT(DISTINCT(left(name,10))) as L10,    # 1000000
       COUNT(DISTINCT(left(name,11))) as L11    # 1000000
FROM users;

# 2：male and female
select COUNT(DISTINCT gender) as L2 FROM users;

select COUNT(DISTINCT name) as L2 FROM users;

select * FROM users  ORDER BY ID DESC LIMIT 10 
```