USE master;
GO

IF DB_ID('BookStore') IS NOT NULL
BEGIN
    ALTER DATABASE BookStore SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    EXEC sp_detach_db 'BookStore';
END
GO

CREATE DATABASE BookStore
ON
(
    FILENAME = '/var/opt/mssql/data/BookStore.mdf'
),
(
    FILENAME = '/var/opt/mssql/data/BookStore_log.ldf'
)
FOR ATTACH;
GO

USE BookStore;
GO

SELECT name
FROM sys.tables
ORDER BY name;
GO