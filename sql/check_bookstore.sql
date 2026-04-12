USE BookStore;
GO

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'Publisher',
    'Book',
    'OrderDetail',
    'Customer',
    'CustomerEvaluation',
    'Order'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO