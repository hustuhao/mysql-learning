
## DB Login

```
docker-compose exec mysql bash -c "mysql --defaults-extra-file=/root/mysql-dbaccess.cnf test_database"
```

## Init Database

```
docker-compose exec mysql bash -c "mysql --defaults-extra-file=/root/mysql-dbaccess.cnf test_database < /docker-entrypoint-initdb.d/initial.sql"
```

## Test Data Creating
见 docker/mysql/init.sql
