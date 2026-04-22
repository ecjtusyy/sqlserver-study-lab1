USE BookStore;
GO

/*====================================================
  一、创建存储过程
====================================================*/

/* 1. proc_SearchBook：按书名精确查询 */
IF OBJECT_ID('dbo.proc_SearchBook', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_SearchBook;
GO

CREATE PROCEDURE dbo.proc_SearchBook
    @bookname NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT BookName, Author, BookSort, ISBN
    FROM dbo.Book
    WHERE BookName = @bookname;
END;
GO

EXEC dbo.proc_SearchBook N'VB程序设计';
GO


/* 2. proc_FuzzySearchBook：按书名模糊查询 */
IF OBJECT_ID('dbo.proc_FuzzySearchBook', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_FuzzySearchBook;
GO

CREATE PROCEDURE dbo.proc_FuzzySearchBook
    @bookname NVARCHAR(50) = N'%'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT BookName, Author, BookSort, ISBN
    FROM dbo.Book
    WHERE BookName LIKE @bookname;
END;
GO

EXEC dbo.proc_FuzzySearchBook;
GO
EXEC dbo.proc_FuzzySearchBook N'VB程序设计';
GO
EXEC dbo.proc_FuzzySearchBook N'%程序设计%';
GO


/* 3. proc_SearchCustomerMoney：查询某客户某年之前的购书总金额 */
IF OBJECT_ID('dbo.proc_SearchCustomerMoney', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_SearchCustomerMoney;
GO

CREATE PROCEDURE dbo.proc_SearchCustomerMoney
    @code CHAR(4),
    @year INT,
    @totalfee MONEY OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @totalfee = ISNULL(SUM(TotalPrice), 0)
    FROM dbo.[Order]
    WHERE CustomerCode = @code
      AND YEAR(OrderTime) <= @year;
END;
GO

DECLARE @total MONEY;
EXEC dbo.proc_SearchCustomerMoney '2401', 2012, @total OUTPUT;
SELECT @total AS 总金额;
GO


/* 4. proc_UpdateVIPClass：修改客户等级和评价时间 */
IF OBJECT_ID('dbo.proc_UpdateVIPClass', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_UpdateVIPClass;
GO

CREATE PROCEDURE dbo.proc_UpdateVIPClass
    @code CHAR(4),
    @class CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.CustomerEvaluation
    SET VIPClass = @class,
        EvaluateDate = GETDATE()
    WHERE CustomerCode = @code;
END;
GO

EXEC dbo.proc_UpdateVIPClass '2401', 'A';
SELECT * FROM dbo.CustomerEvaluation WHERE CustomerCode = '2401';
GO


/* 5. proc_InsertOrderDetail：向 OrderDetail 插入一条记录 */
IF OBJECT_ID('dbo.proc_InsertOrderDetail', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_InsertOrderDetail;
GO

CREATE PROCEDURE dbo.proc_InsertOrderDetail
    @ordcode CHAR(8),
    @bookcode CHAR(4),
    @count INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.OrderDetail(OrderCode, BookCode, Amount)
    VALUES(@ordcode, @bookcode, @count);
END;
GO

/* 为了避免重复执行出错，先删除同一条记录 */
DELETE FROM dbo.OrderDetail
WHERE OrderCode = '10120701'
  AND BookCode = '0202';
GO

EXEC dbo.proc_InsertOrderDetail '10120701', '0202', 5;
SELECT * FROM dbo.OrderDetail WHERE OrderCode = '10120701' AND BookCode = '0202';
GO



/*====================================================
  二、创建触发器
====================================================*/

/* 1. tri_OrderDetailInsertUpdate：
      当 OrderDetail 插入或更新时，自动计算订单总价 */
IF OBJECT_ID('dbo.tri_OrderDetailInsertUpdate', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tri_OrderDetailInsertUpdate;
GO

CREATE TRIGGER dbo.tri_OrderDetailInsertUpdate
ON dbo.OrderDetail
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE o
    SET o.TotalPrice = x.TotalPrice
    FROM dbo.[Order] o
    JOIN
    (
        SELECT od.OrderCode,
               CAST(SUM(od.Amount * b.Price * b.Discount) AS MONEY) AS TotalPrice
        FROM dbo.OrderDetail od
        JOIN dbo.Book b
            ON od.BookCode = b.BookCode
        WHERE od.OrderCode IN (SELECT DISTINCT OrderCode FROM inserted)
        GROUP BY od.OrderCode
    ) x
        ON o.OrderCode = x.OrderCode;
END;
GO

SELECT * FROM dbo.[Order]
WHERE OrderCode = '08110801';
GO

UPDATE dbo.OrderDetail
SET Amount = 8
WHERE OrderCode = '08110801'
  AND BookCode = '0202';
GO

SELECT * FROM dbo.[Order]
WHERE OrderCode = '08110801';
GO


/* 2. tri_CustomerEvaluationInsertUpdate：
      CustomerEvaluation 插入或修改时自动写入当前时间 */
IF OBJECT_ID('dbo.tri_CustomerEvaluationInsertUpdate', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tri_CustomerEvaluationInsertUpdate;
GO

CREATE TRIGGER dbo.tri_CustomerEvaluationInsertUpdate
ON dbo.CustomerEvaluation
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ce
    SET EvaluateDate = GETDATE()
    FROM dbo.CustomerEvaluation ce
    JOIN inserted i
        ON ce.CustomerCode = i.CustomerCode;
END;
GO

SELECT * FROM dbo.CustomerEvaluation
WHERE CustomerCode = '1201';
GO

UPDATE dbo.CustomerEvaluation
SET VIPClass = 'A'
WHERE CustomerCode = '1201';
GO

SELECT * FROM dbo.CustomerEvaluation
WHERE CustomerCode = '1201';
GO


/* 3. tri_UpdateOrderStatus：
      当订单状态改为“结单”时，自动更新客户等级 */
IF OBJECT_ID('dbo.tri_UpdateOrderStatus', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tri_UpdateOrderStatus;
GO

CREATE TRIGGER dbo.tri_UpdateOrderStatus
ON dbo.[Order]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(OrderStatus)
    BEGIN
        ;WITH ClosedOrders AS
        (
            SELECT CustomerCode
            FROM inserted
            WHERE OrderStatus = N'结单'
        ),
        CustomerSpend AS
        (
            SELECT o.CustomerCode,
                   SUM(o.TotalPrice) AS TotalMoney,
                   NTILE(10) OVER (ORDER BY SUM(o.TotalPrice) DESC) AS grp10
            FROM dbo.[Order] o
            GROUP BY o.CustomerCode
        )
        UPDATE ce
        SET VIPClass =
            CASE
                WHEN cs.grp10 = 1 THEN 'A'
                WHEN cs.grp10 <= 3 THEN 'B'
                WHEN cs.grp10 <= 9 THEN 'C'
                ELSE 'D'
            END
        FROM dbo.CustomerEvaluation ce
        JOIN ClosedOrders co
            ON ce.CustomerCode = co.CustomerCode
        JOIN CustomerSpend cs
            ON ce.CustomerCode = cs.CustomerCode;
    END
END;
GO

SELECT * FROM dbo.[Order]
WHERE CustomerCode IN
(
    SELECT CustomerCode
    FROM dbo.[Order]
    WHERE OrderCode = '10060802'
);
GO

SELECT * FROM dbo.CustomerEvaluation
WHERE CustomerCode IN
(
    SELECT CustomerCode
    FROM dbo.[Order]
    WHERE OrderCode = '10060802'
);
GO

UPDATE dbo.[Order]
SET OrderStatus = N'结单'
WHERE OrderCode = '10060802';
GO

SELECT * FROM dbo.[Order]
WHERE CustomerCode IN
(
    SELECT CustomerCode
    FROM dbo.[Order]
    WHERE OrderCode = '10060802'
);
GO

SELECT * FROM dbo.CustomerEvaluation
WHERE CustomerCode IN
(
    SELECT CustomerCode
    FROM dbo.[Order]
    WHERE OrderCode = '10060802'
);
GO


/* 4. tri_BookOrderDel：
      删除订单时检查状态，不是“待处理”则禁止删除 */
IF OBJECT_ID('dbo.tri_BookOrderDel', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tri_BookOrderDel;
GO

CREATE TRIGGER dbo.tri_BookOrderDel
ON dbo.[Order]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM deleted
        WHERE OrderStatus <> N'待处理'
    )
    BEGIN
        RAISERROR(N'结单或已发货，订单不能被删除。',16,1);
        RETURN;
    END

    DELETE od
    FROM dbo.OrderDetail od
    JOIN deleted d
        ON od.OrderCode = d.OrderCode;

    DELETE o
    FROM dbo.[Order] o
    JOIN deleted d
        ON o.OrderCode = d.OrderCode;
END;
GO