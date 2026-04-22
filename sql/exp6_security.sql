USE master;
GO

/*====================================================
  实验6-7：创建 Judy 登录名和用户
====================================================*/
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Judy')
    DROP LOGIN Judy;
GO

CREATE LOGIN Judy
WITH PASSWORD = '123',
     CHECK_POLICY = OFF,
     CHECK_EXPIRATION = OFF;
GO

USE BookStore;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Judy')
    DROP USER Judy;
GO

CREATE USER Judy FOR LOGIN Judy;
GO

GRANT SELECT (BookCode, BookName, Author, BookPicture)
ON dbo.Book TO Judy;
GO

GRANT DELETE
ON dbo.Book TO Judy;
GO

DENY INSERT
ON dbo.Book TO Judy;
GO

DENY UPDATE
ON dbo.Book TO Judy;
GO

SELECT dp.name AS UserName,
       o.name AS ObjectName,
       p.permission_name,
       p.state_desc
FROM sys.database_permissions p
JOIN sys.database_principals dp
    ON p.grantee_principal_id = dp.principal_id
LEFT JOIN sys.objects o
    ON p.major_id = o.object_id
WHERE dp.name = 'Judy'
ORDER BY ObjectName, p.permission_name;
GO


/*====================================================
  实验6-8：创建角色 Customer 并授权
====================================================*/
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Customer' AND type = 'R')
    DROP ROLE [Customer];
GO

CREATE ROLE [Customer];
GO

GRANT SELECT
ON dbo.Book TO [Customer];
GO

DENY DELETE
ON dbo.Book TO [Customer];
GO

GRANT INSERT, UPDATE, DELETE
ON dbo.[Order] TO [Customer];
GO

GRANT INSERT, UPDATE, DELETE
ON dbo.OrderDetail TO [Customer];
GO

SELECT dp.name AS RoleName,
       o.name AS ObjectName,
       p.permission_name,
       p.state_desc
FROM sys.database_permissions p
JOIN sys.database_principals dp
    ON p.grantee_principal_id = dp.principal_id
LEFT JOIN sys.objects o
    ON p.major_id = o.object_id
WHERE dp.name = 'Customer'
ORDER BY ObjectName, p.permission_name;
GO