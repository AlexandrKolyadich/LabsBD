USE AdventureWorks2012;
GO

  /*
    Создайте scalar-valued функцию, которая будет принимать в качестве 
    входного параметра код валюты (Sales.Currency.CurrencyCode) и возвращать последний
     установленный курс по отношению к USD (Sales.CurrencyRate.ToCurrencyCode).
 */

CREATE FUNCTION Sales.getLatestUSDRate (@currencyCode NCHAR(3))
RETURNS MONEY AS 
BEGIN
	DECLARE @latestUSDRate MONEY

	SELECT TOP 1 @latestUSDRate = EndOfDayRate FROM Sales.CurrencyRate
	WHERE ToCurrencyCode = @currencyCode AND FromCurrencyCode = 'USD'
    ORDER BY CurrencyRateDate DESC

	RETURN @latestUSDRate
END
GO

/*
    Создайте inline table-valued функцию, 
    которая будет принимать в качестве входного параметра id продукта 
    (Production.Product.ProductID), а возвращать детали заказа на покупку 
    данного продукта из Purchasing.PurchaseOrderDetail, 
    где количество заказанных позиций более 1000 (OrderQty).
*/

CREATE FUNCTION
    Purchasing.getOrderDetails(@productId INT)
RETURNS
    TABLE
AS
RETURN
	(SELECT
        *
    FROM
        Purchasing.PurchaseOrderDetail
    WHERE
        ProductID = @productId
        AND OrderQty > 1000)
GO

/*
    Вызовите функцию для каждого продукта, 
    применив оператор CROSS APPLY. Вызовите функцию для каждого продукта, 
    применив оператор OUTER APPLY.
*/

SELECT * FROM Production.Product
CROSS APPLY Purchasing.getOrderDetails(Product.ProductID)
GO

SELECT * FROM Production.Product
OUTER APPLY Purchasing.getOrderDetails(Product.ProductID)
GO


/*
    Измените созданную inline table-valued функцию, сделав ее multistatement table-valued 
    (предварительно сохранив для проверки код создания inline table-valued функции).
*/

DROP FUNCTION
    Purchasing.getOrderDetails
GO

CREATE FUNCTION
    Purchasing.getOrderDetails(@ProductId INT)
RETURNS
    @OrderDetails TABLE
    (
        PurchaseOrderID INT,
        PurchaseOrderDetailID INT,
        DueDate DATETIME,
        OrderQty SMALLINT,
        ProductID INT,
        UnitPrice MONEY,
        LineTotal MONEY,
        ReceivedQty DECIMAL(8,2),
        RejectedQty DECIMAL(8,2),
        StockedQty DECIMAL(9,2),
        ModifiedDate DATETIME
    )
AS
BEGIN
    INSERT INTO
        @OrderDetails
        (
            PurchaseOrderID,
            PurchaseOrderDetailID,
            DueDate,
            OrderQty,
            ProductID,
            UnitPrice,
            LineTotal,
            ReceivedQty,
            RejectedQty,
            StockedQty,
            ModifiedDate
        )
    SELECT
        PurchaseOrderID,
        PurchaseOrderDetailID,
        DueDate,
        OrderQty,
        ProductID,
        UnitPrice,
        LineTotal,
        ReceivedQty,
        RejectedQty,
        StockedQty,
        ModifiedDate
    FROM
        Purchasing.PurchaseOrderDetail
    WHERE
        ProductID = @ProductId
        AND OrderQty > 1000
    RETURN
END
GO

