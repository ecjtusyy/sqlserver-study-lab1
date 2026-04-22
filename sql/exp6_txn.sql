USE BookStore;
GO

/*====================================================
  实验6-1：利用事务生成并提交订单
====================================================*/
BEGIN TRY
    BEGIN TRAN;

    IF EXISTS (SELECT 1 FROM dbo.[Order] WHERE OrderCode = '12010101')
    BEGIN
        DELETE FROM dbo.OrderDetail WHERE OrderCode = '12010101';
        DELETE FROM dbo.[Order] WHERE OrderCode = '12010101';
    END

    DECLARE @TotalPrice DECIMAL(18,2);

    SELECT @TotalPrice =
        CAST(SUM(v.Amount * ISNULL(b.Price, 0) * ISNULL(b.Discount, 1)) AS DECIMAL(18,2))
    FROM (VALUES ('0101', 1), ('1111', 2)) AS v(BookCode, Amount)
    JOIN dbo.Book b
        ON b.BookCode = v.BookCode;

    DECLARE @cols NVARCHAR(MAX) = N'OrderCode, CustomerCode';
    DECLARE @vals NVARCHAR(MAX) = N'''12010101'', ''1301''';

    IF COL_LENGTH('dbo.[Order]', 'Address') IS NOT NULL
    BEGIN
        SET @cols += N', Address';
        SET @vals += N', N''上海市新渔路 100 号''';
    END

    IF COL_LENGTH('dbo.[Order]', 'OrderDate') IS NOT NULL
    BEGIN
        SET @cols += N', OrderDate';
        SET @vals += N', GETDATE()';
    END

    IF COL_LENGTH('dbo.[Order]', 'TotalPrice') IS NOT NULL
    BEGIN
        SET @cols += N', TotalPrice';
        SET @vals += N', ' + CAST(ISNULL(@TotalPrice, 0) AS NVARCHAR(50));
    END

    IF COL_LENGTH('dbo.[Order]', 'OrderStatus') IS NOT NULL
    BEGIN
        SET @cols += N', OrderStatus';
        SET @vals += N', N''未发货''';
    END

    IF COL_LENGTH('dbo.[Order]', 'Status') IS NOT NULL
    BEGIN
        SET @cols += N', Status';
        SET @vals += N', N''未发货''';
    END

    IF COL_LENGTH('dbo.[Order]', 'State') IS NOT NULL
    BEGIN
        SET @cols += N', State';
        SET @vals += N', N''未发货''';
    END

    EXEC (N'INSERT INTO dbo.[Order] (' + @cols + N') VALUES (' + @vals + N')');

    INSERT INTO dbo.OrderDetail(OrderCode, BookCode, Amount)
    VALUES
        ('12010101', '0101', 1),
        ('12010101', '1111', 2);

    COMMIT TRAN;

    SELECT N'订单生成并提交成功' AS Msg;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

SELECT * FROM dbo.[Order] WHERE OrderCode = '12010101';
GO
SELECT * FROM dbo.OrderDetail WHERE OrderCode = '12010101';
GO


/*====================================================
  实验6-2：利用事务撤销订单
====================================================*/
BEGIN TRY
    BEGIN TRAN;

    DECLARE @StatusCol SYSNAME = NULL;
    DECLARE @StatusValue NVARCHAR(50) = NULL;
    DECLARE @sql NVARCHAR(MAX);

    SELECT TOP 1 @StatusCol = COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Order'
      AND COLUMN_NAME IN ('OrderStatus', 'Status', 'State', 'OrderState');

    IF @StatusCol IS NOT NULL
    BEGIN
        SET @sql = N'
            SELECT @outStatus = CAST(' + QUOTENAME(@StatusCol) + N' AS NVARCHAR(50))
            FROM dbo.[Order]
            WHERE OrderCode = ''12010101'';
        ';

        EXEC sp_executesql
            @sql,
            N'@outStatus NVARCHAR(50) OUTPUT',
            @outStatus = @StatusValue OUTPUT;
    END

    IF @StatusValue IN (N'已发货', N'结单')
    BEGIN
        RAISERROR(N'该订单状态为“%s”，不能撤销。', 16, 1, @StatusValue);
    END
    ELSE
    BEGIN
        DELETE FROM dbo.OrderDetail
        WHERE OrderCode = '12010101';

        DELETE FROM dbo.[Order]
        WHERE OrderCode = '12010101';

        COMMIT TRAN;

        SELECT N'订单撤销成功' AS Msg;
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

SELECT * FROM dbo.[Order] WHERE OrderCode = '12010101';
GO
SELECT * FROM dbo.OrderDetail WHERE OrderCode = '12010101';
GO