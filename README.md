1.启动数据库
docker start sql2022
docker ps

2.终端的查询命令
比如：docker exec -it sql2022 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Aa!23456Bb' -C -d BookStore -Q "SELECT TOP 5 * FROM Book;"

通过 sqlcmd -Q "..." 把 SQL 交给 SQL Server 执行。

3.退出
