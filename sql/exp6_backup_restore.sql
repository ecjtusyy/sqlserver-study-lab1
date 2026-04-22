USE master;
GO

/*====================================================
  实验6-3：完全备份 BookStore
====================================================*/
BACKUP DATABASE BookStore
TO DISK = '/var/opt/mssql/backup/BookStoreBackup.bak'
WITH INIT, FORMAT, NAME = N'BookStore Full Backup';
GO

RESTORE HEADERONLY
FROM DISK = '/var/opt/mssql/backup/BookStoreBackup.bak';
GO

RESTORE FILELISTONLY
FROM DISK = '/var/opt/mssql/backup/BookStoreBackup.bak';
GO


/*====================================================
  实验6-4：恢复为 BookStore2
====================================================*/
IF DB_ID('BookStore2') IS NOT NULL
BEGIN
    ALTER DATABASE BookStore2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BookStore2;
END
GO

RESTORE DATABASE BookStore2
FROM DISK = '/var/opt/mssql/backup/BookStoreBackup.bak'
WITH
    MOVE 'BookStore' TO '/var/opt/mssql/data/BookStore2.mdf',
    MOVE 'BookStore_log' TO '/var/opt/mssql/data/BookStore2_log.ldf',
    REPLACE,
    RECOVERY;
GO

SELECT name, state_desc
FROM sys.databases
WHERE name IN ('BookStore', 'BookStore2');
GO

USE BookStore2;
GO
SELECT TOP 5 * FROM Book;
GO


/*====================================================
  实验6-6：分离并重新附加 BookStore
====================================================*/
USE master;
GO

IF DB_ID('BookStore') IS NOT NULL
BEGIN
    ALTER DATABASE BookStore SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    EXEC sp_detach_db 'BookStore';
END
GO

SELECT name
FROM sys.databases
WHERE name = 'BookStore';
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

SELECT name
FROM sys.databases
WHERE name = 'BookStore';
GO

USE BookStore;
GO
SELECT TOP 5 * FROM Book;
GO