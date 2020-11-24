USE AdventureWorks2012
GO

/*
	Выполните код, созданный во втором задании второй лабораторной работы. 
    Добавьте в таблицу dbo.PersonPhone поля OrdersCount INT и CardType NVARCHAR(50). 
    Также создайте в таблице вычисляемое поле IsSuperior, которое будет хранить 1,
    если тип карты ‘SuperiorCard’ и 0 для остальных карт.
*/

ALTER TABLE dbo.PersonPhone
ADD
    OrdersCount INT,
    CardType NVARCHAR(50),
    IsSuperior AS IIF (CardType = 'SuperiorCard', 1, 0);

/*
	 Создайте временную таблицу #PersonPhone, с первичным ключом по полю BusinessEntityID. 
     Временная таблица должна включать все поля таблицы dbo.PersonPhone за исключением поля IsSuperior.
*/

CREATE TABLE #PersonPhone
(
    BusinessEntityID INT NOT NULL PRIMARY KEY,
    PhoneNumber NVARCHAR(25) NOT NULL,
    PhoneNumberTypeID BIGINT NULL,
    ModifiedDate DATETIME,
    PostalCode NVARCHAR(15) DEFAULT ('0'),
    OrdersCount INT,
    CardType NVARCHAR(50)
);

/*
	Заполните временную таблицу данными из dbo.PersonPhone. 
    Поле CardType заполните данными из таблицы Sales.CreditCard. 
    Посчитайте количество заказов, оплаченных каждой картой (CreditCardID) 
    в таблице Sales.SalesOrderHeader и заполните этими значениями поле OrdersCount. 
    Подсчет количества заказов осуществите в Common Table Expression (CTE).
*/

WITH OrdersCTE (CreditCardID, OrdersCount)
AS
(
    SELECT
        CreditCardID,
        COUNT(*) AS OrdersCount
    FROM
        AdventureWorks2012.Sales.SalesOrderHeader
    GROUP BY
        CreditCardID
)
INSERT INTO #PersonPhone
    (
        BusinessEntityID,
        PhoneNumber,
        PhoneNumberTypeID,
        ModifiedDate,
        PostalCode,
        OrdersCount,
        CardType
    )

SELECT 
	dbo.PersonPhone.BusinessEntityID,
    dbo.PersonPhone.PhoneNumber,
    dbo.PersonPhone.PhoneNumberTypeID,
    dbo.PersonPhone.ModifiedDate,
    dbo.PersonPhone.PostalCode,
    OrdersCTE.OrdersCount,
    AdventureWorks2012.Sales.CreditCard.CardType
FROM dbo.PersonPhone
JOIN AdventureWorks2012.Sales.PersonCreditCard ON (dbo.PersonPhone.BusinessEntityID = AdventureWorks2012.Sales.PersonCreditCard.BusinessEntityID)
JOIN AdventureWorks2012.Sales.CreditCard ON (AdventureWorks2012.Sales.PersonCreditCard.CreditCardID = CreditCard.CreditCardID)
JOIN OrdersCTE ON (CreditCard.CreditCardID = OrdersCTE.CreditCardID);

/*
	Удалите из таблицы dbo.PersonPhone одну строку (где BusinessEntityID = 297)
*/

DELETE
FROM
    dbo.PersonPhone
WHERE
    BusinessEntityID = 297;

/*
	Напишите Merge выражение, использующее dbo.PersonPhone как target, а временную таблицу как source. 
    Для связи target и source используйте BusinessEntityID. Обновите поля OrdersCount и CardType, 
    если запись присутствует в source и target. Если строка присутствует во временной таблице, 
    но не существует в target, добавьте строку в dbo.PersonPhone. 
    Если в dbo.PersonPhone присутствует такая строка, которой не существует во временной таблице, удалите строку из dbo.PersonPhone.
*/

MERGE dbo.PersonPhone AS TARGET
USING #PersonPhone AS source
ON (TARGET.BusinessEntityID = source.BusinessEntityID)
WHEN MATCHED THEN
	UPDATE SET
		OrdersCount = source.OrdersCount,
		CardType = source.CardType
WHEN NOT MATCHED BY TARGET THEN
	INSERT
    (
        BusinessEntityID,
        PhoneNumber,
        PhoneNumberTypeID,
        ModifiedDate,
        OrdersCount,
        CardType
    )
    VALUES
    (
        BusinessEntityID,
        PhoneNumber,
        PhoneNumberTypeID,
        ModifiedDate,
        OrdersCount,
        CardType
    )
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;


SELECT * FROM dbo.PersonPhone