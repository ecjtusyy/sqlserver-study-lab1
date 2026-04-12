USE BookStore;
GO

/* 1. INSERT */

/* 1）在Publisher表中添加一条记录 */
INSERT INTO Publisher(PublisherCode, Publisher, Telephone)
VALUES ('66', N'群众出版社', '0321-76584391');
GO

SELECT *
FROM Publisher
WHERE PublisherCode = '66';
GO


/* 2）在OrderDetail表中添加一条记录 */
INSERT INTO OrderDetail(OrderCode, BookCode, Amount)
VALUES ('08110801', '0701', 3);
GO

SELECT *
FROM OrderDetail
WHERE OrderCode = '08110801' AND BookCode = '0701';
GO


/* 3）在Customer表中添加一条记录，只填写必填字段 */
INSERT INTO Customer(CustomerCode, Name, Sex, Telephone)
VALUES ('6001', N'王岚', N'女', '87654390');
GO

SELECT *
FROM Customer
WHERE CustomerCode = '6001';
GO


/* 2. UPDATE */

/* 1）修改 Publisher 表中出版社代号为 01 的联系电话 */
UPDATE Publisher
SET Telephone = '010-79797979'
WHERE PublisherCode = '01';
GO

SELECT *
FROM Publisher
WHERE PublisherCode = '01';
GO


/* 2）将 Book 表中所有“外语”类图书价格降低10%，并将折扣设为8折 */
UPDATE Book
SET Price = Price * 0.9,
    Discount = 0.8
WHERE BookSort = N'外语';
GO

SELECT BookCode, BookName, BookSort, Price, Discount
FROM Book
WHERE BookSort = N'外语';
GO


/* 3）修改 CustomerEvaluation 表，将消费总额在100~200元之间的客户等级修改为 B */
UPDATE CustomerEvaluation
SET VIPClass = 'B'
WHERE CustomerCode IN
(
    SELECT CustomerCode
    FROM [Order]
    GROUP BY CustomerCode
    HAVING SUM(TotalPrice) BETWEEN 100 AND 200
);
GO

SELECT *
FROM CustomerEvaluation
WHERE VIPClass = 'B';
GO


/* 3. DELETE */

/* 1）从 Publisher 表中删除“群众出版社”记录 */
DELETE FROM Publisher
WHERE Publisher = N'群众出版社';
GO

SELECT *
FROM Publisher
WHERE Publisher = N'群众出版社';
GO


/* 2）删除 CustomerEvaluation 表中没有购买过书的客户评价记录 */
DELETE FROM CustomerEvaluation
WHERE CustomerCode NOT IN
(
    SELECT DISTINCT CustomerCode
    FROM [Order]
);
GO

SELECT *
FROM CustomerEvaluation
WHERE CustomerCode NOT IN
(
    SELECT DISTINCT CustomerCode
    FROM [Order]
);
GO