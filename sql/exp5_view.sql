USE BookStore;
GO

/*====================================================
  实验5：视图的创建及操纵
====================================================*/

/* 为了反复执行方便，先删除旧视图 */
IF OBJECT_ID('dbo.V_BookSell', 'V') IS NOT NULL
    DROP VIEW dbo.V_BookSell;
GO

IF OBJECT_ID('dbo.V_CustomerBookOrderDetail', 'V') IS NOT NULL
    DROP VIEW dbo.V_CustomerBookOrderDetail;
GO

IF OBJECT_ID('dbo.V_CustomerVIPABTotalOrder', 'V') IS NOT NULL
    DROP VIEW dbo.V_CustomerVIPABTotalOrder;
GO


/*====================================================
  1. 创建视图 V_BookSell
  显示：BookCode, BookName, Author, Publisher, Amount
====================================================*/
CREATE VIEW dbo.V_BookSell
AS
SELECT
    b.BookCode,
    b.BookName,
    b.Author,
    p.Publisher,
    ISNULL(SUM(od.Amount), 0) AS Amount
FROM Book b
JOIN Publisher p
    ON b.PublisherCode = p.PublisherCode
LEFT JOIN OrderDetail od
    ON b.BookCode = od.BookCode
GROUP BY
    b.BookCode,
    b.BookName,
    b.Author,
    p.Publisher;
GO

-- 【截图2】创建后查询结果
SELECT *
FROM dbo.V_BookSell
ORDER BY Amount DESC, BookCode;
GO


/*====================================================
  2. 创建视图 V_CustomerBookOrderDetail
  显示：OrderCode, Name, VIPClass, BookName, Price,
       Amount, Discount, TotalPrice
====================================================*/
CREATE VIEW dbo.V_CustomerBookOrderDetail
AS
SELECT
    o.OrderCode,
    c.Name,
    ce.VIPClass,
    b.BookName,
    b.Price,
    od.Amount,
    b.Discount,
    CAST(b.Price * od.Amount * b.Discount AS DECIMAL(10,2)) AS TotalPrice
FROM [Order] o
JOIN Customer c
    ON o.CustomerCode = c.CustomerCode
LEFT JOIN CustomerEvaluation ce
    ON c.CustomerCode = ce.CustomerCode
JOIN OrderDetail od
    ON o.OrderCode = od.OrderCode
JOIN Book b
    ON od.BookCode = b.BookCode;
GO

-- 【截图3】创建后查询结果
SELECT *
FROM dbo.V_CustomerBookOrderDetail
ORDER BY OrderCode, BookName;
GO


/*====================================================
  3. 创建视图 V_CustomerVIPABTotalOrder
  客户等级为A/B，且不姓郭/刘
====================================================*/
CREATE VIEW dbo.V_CustomerVIPABTotalOrder
AS
SELECT
    c.Name,
    CAST(SUM(o.TotalPrice) AS DECIMAL(10,2)) AS TotalAmount
FROM [Order] o
JOIN Customer c
    ON o.CustomerCode = c.CustomerCode
JOIN CustomerEvaluation ce
    ON c.CustomerCode = ce.CustomerCode
WHERE ce.VIPClass IN ('A', 'B')
  AND c.Name NOT LIKE N'郭%'
  AND c.Name NOT LIKE N'刘%'
GROUP BY c.Name;
GO

-- 【截图4】创建后查询结果
SELECT *
FROM dbo.V_CustomerVIPABTotalOrder
ORDER BY TotalAmount DESC, Name;
GO


/*====================================================
  4. 操纵视图 V_BookSell
  说明：这是聚合视图，不适合直接增删改
  所以这里采用“改基表 -> 查视图变化”的方式
====================================================*/

-- 【截图5】先查询 V_BookSell
SELECT *
FROM dbo.V_BookSell
ORDER BY Amount DESC, BookCode;
GO

/* 4-1 修改演示：修改某条订单明细数量，再观察视图变化 */
BEGIN TRAN;

DECLARE @OrderCode1 CHAR(8),
        @BookCode1  CHAR(4),
        @OldAmount1 INT;

SELECT TOP 1
    @OrderCode1 = OrderCode,
    @BookCode1 = BookCode,
    @OldAmount1 = Amount
FROM OrderDetail
ORDER BY OrderCode, BookCode;

SELECT N'修改前' AS Step, *
FROM dbo.V_BookSell
WHERE BookCode = @BookCode1;

UPDATE OrderDetail
SET Amount = Amount + 1
WHERE OrderCode = @OrderCode1
  AND BookCode = @BookCode1;

SELECT N'修改后' AS Step, *
FROM dbo.V_BookSell
WHERE BookCode = @BookCode1;

ROLLBACK TRAN;
GO

/* 4-2 插入 + 删除演示：插入一条新的订单明细，再删除 */
BEGIN TRAN;

DECLARE @OrderCode2 CHAR(8),
        @BookCode2  CHAR(4);

SELECT TOP 1
    @OrderCode2 = o.OrderCode,
    @BookCode2  = b.BookCode
FROM [Order] o
CROSS JOIN Book b
WHERE NOT EXISTS
(
    SELECT 1
    FROM OrderDetail od
    WHERE od.OrderCode = o.OrderCode
      AND od.BookCode  = b.BookCode
)
ORDER BY o.OrderCode, b.BookCode;

IF @OrderCode2 IS NOT NULL AND @BookCode2 IS NOT NULL
BEGIN
    SELECT N'插入前' AS Step, *
    FROM dbo.V_BookSell
    WHERE BookCode = @BookCode2;

    INSERT INTO OrderDetail(OrderCode, BookCode, Amount)
    VALUES(@OrderCode2, @BookCode2, 1);

    SELECT N'插入后' AS Step, *
    FROM dbo.V_BookSell
    WHERE BookCode = @BookCode2;

    DELETE FROM OrderDetail
    WHERE OrderCode = @OrderCode2
      AND BookCode  = @BookCode2;

    SELECT N'删除后' AS Step, *
    FROM dbo.V_BookSell
    WHERE BookCode = @BookCode2;
END

ROLLBACK TRAN;
GO


/*====================================================
  5. 操纵视图 V_CustomerBookOrderDetail
  说明：这是连接视图，也建议通过基表变化来体现
====================================================*/

-- 【截图7】先查询
SELECT *
FROM dbo.V_CustomerBookOrderDetail
ORDER BY OrderCode, BookName;
GO

/* 5-1 修改演示：修改订单明细数量 */
BEGIN TRAN;

DECLARE @OrderCode3 CHAR(8),
        @BookCode3  CHAR(4),
        @BookName3  NVARCHAR(100),
        @OldAmount3 INT;

SELECT TOP 1
    @OrderCode3 = od.OrderCode,
    @BookCode3  = od.BookCode,
    @OldAmount3 = od.Amount,
    @BookName3  = b.BookName
FROM OrderDetail od
JOIN Book b
    ON od.BookCode = b.BookCode
ORDER BY od.OrderCode, od.BookCode;

SELECT N'修改前' AS Step, *
FROM dbo.V_CustomerBookOrderDetail
WHERE OrderCode = @OrderCode3
  AND BookName  = @BookName3;

UPDATE OrderDetail
SET Amount = Amount + 1
WHERE OrderCode = @OrderCode3
  AND BookCode  = @BookCode3;

SELECT N'修改后' AS Step, *
FROM dbo.V_CustomerBookOrderDetail
WHERE OrderCode = @OrderCode3
  AND BookName  = @BookName3;

ROLLBACK TRAN;
GO

/* 5-2 插入 + 删除演示 */
BEGIN TRAN;

DECLARE @OrderCode4 CHAR(8),
        @BookCode4  CHAR(4),
        @BookName4  NVARCHAR(100);

SELECT TOP 1
    @OrderCode4 = o.OrderCode,
    @BookCode4  = b.BookCode,
    @BookName4  = b.BookName
FROM [Order] o
CROSS JOIN Book b
WHERE NOT EXISTS
(
    SELECT 1
    FROM OrderDetail od
    WHERE od.OrderCode = o.OrderCode
      AND od.BookCode  = b.BookCode
)
ORDER BY o.OrderCode, b.BookCode;

IF @OrderCode4 IS NOT NULL AND @BookCode4 IS NOT NULL
BEGIN
    SELECT N'插入前' AS Step, *
    FROM dbo.V_CustomerBookOrderDetail
    WHERE OrderCode = @OrderCode4
      AND BookName  = @BookName4;

    INSERT INTO OrderDetail(OrderCode, BookCode, Amount)
    VALUES(@OrderCode4, @BookCode4, 1);

    SELECT N'插入后' AS Step, *
    FROM dbo.V_CustomerBookOrderDetail
    WHERE OrderCode = @OrderCode4
      AND BookName  = @BookName4;

    DELETE FROM OrderDetail
    WHERE OrderCode = @OrderCode4
      AND BookCode  = @BookCode4;

    SELECT N'删除后' AS Step, *
    FROM dbo.V_CustomerBookOrderDetail
    WHERE OrderCode = @OrderCode4
      AND BookName  = @BookName4;
END

ROLLBACK TRAN;
GO


/*====================================================
  6. 删除视图 V_CustomerVIPABTotalOrder
  这里建议按“删除视图”来做
====================================================*/

SELECT name
FROM sys.views
WHERE name = 'V_CustomerVIPABTotalOrder';
GO

DROP VIEW dbo.V_CustomerVIPABTotalOrder;
GO

-- 【截图9】删除后检查
SELECT name
FROM sys.views
WHERE name = 'V_CustomerVIPABTotalOrder';
GO