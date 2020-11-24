USE AdventureWorks2012;
GO

/*
	Создайте представление VIEW, отображающее данные из таблиц Sales.Currency и Sales.CurrencyRate. 
	Таблица Sales.Currency должна отображать название валюты для поля ToCurrencyCode. 
	Создайте уникальный кластерный индекс в представлении по полю CurrencyRateID.
*/

CREATE VIEW Sales.ViewCurrency2
WITH SCHEMABINDING
AS
SELECT 
	currencyRate.CurrencyRateID,
	currencyRate.CurrencyRateDate,
	currencyRate.FromCurrencyCode,
	currency.Name,
	currency.CurrencyCode,
	currencyRate.AverageRate,
	currencyRate.EndOfDayRate
FROM Sales.Currency AS currency
INNER JOIN Sales.CurrencyRate AS currencyRate
	ON currency.CurrencyCode = currencyRate.ToCurrencyCode
GO

CREATE UNIQUE CLUSTERED INDEX IX_CurrencyRateID
	ON Sales.ViewCurrency2 (CurrencyRateID)
GO





/*
	Создайте один INSTEAD OF триггер для представления на три операции INSERT, UPDATE, DELETE. 
	Триггер должен выполнять соответствующие операции в таблицах Sales.Currency и Sales.CurrencyRate.
*/

CREATE TRIGGER InsteadViewCurrency2Trigger ON Sales.ViewCurrency2
	INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @currencyCode NVARCHAR(50);
	/*DELETE*/
	IF NOT EXISTS (SELECT * FROM inserted)
		BEGIN 
			SELECT @currencyCode = deleted.CurrencyCode FROM deleted;

			DELETE
			FROM Sales.CurrencyRate
			WHERE ToCurrencyCode = @currencyCode;
			
			DELETE 
			FROM Sales.Currency
			WHERE CurrencyCode = @currencyCode
		END;
	/*INSERT*/
	ELSE IF NOT EXISTS (SELECT * FROM deleted)
		BEGIN
			IF NOT EXISTS (
				SELECT * 
				FROM Sales.Currency AS sc 
				JOIN inserted ON inserted.CurrencyCode = sc.CurrencyCode)
			BEGIN
				INSERT INTO Sales.Currency (
					CurrencyCode,
					Name,
					ModifiedDate)
				SELECT 
					CurrencyCode,
					Name,
					GETDATE()
				FROM inserted
			END
			ELSE
				UPDATE
				    Sales.Currency
				SET
				    Name = inserted.Name,
				    ModifiedDate = GETDATE()
				FROM
				    inserted
				WHERE
				    Currency.CurrencyCode = inserted.CurrencyCode

			INSERT INTO Sales.CurrencyRate(
				CurrencyRateDate,
				FromCurrencyCode,
				ToCurrencyCode,
				AverageRate,
				EndOfDayRate,
				ModifiedDate)
			SELECT 
				CurrencyRateDate,
				FromCurrencyCode,
				CurrencyCode,
				AverageRate,
				EndOfDayRate,
				GETDATE()
			FROM inserted
		END;
		/*UPDATE*/
	ELSE
		BEGIN
			UPDATE Sales.Currency
			SET 
				Name = inserted.Name,
				ModifiedDate = GETDATE()
			FROM Sales.Currency AS currencies
			JOIN inserted ON inserted.CurrencyCode = currencies.CurrencyCode

			UPDATE Sales.CurrencyRate
			SET 
				CurrencyRateDate= inserted.CurrencyRateDate,
				AverageRate= inserted.AverageRate,
				EndOfDayRate= inserted.EndOfDayRate,
				ModifiedDate= GETDATE()
			FROM Sales.CurrencyRate AS currencyRates
			JOIN inserted ON inserted.CurrencyRateID = currencyRates.CurrencyRateID
		END;
END;

/*
	Вставьте новую строку в представление, указав новые данные для Currency и CurrencyRate (укажите FromCurrencyCode = ‘USD’). 
	Триггер должен добавить новые строки в таблицы Sales.Currency и Sales.CurrencyRate. 
	Обновите вставленные строки через представление. Удалите строки.
*/

INSERT INTO Sales.ViewCurrency2(
	CurrencyRateDate,
	FromCurrencyCode,
	CurrencyCode,
	Name,
	AverageRate,
	EndOfDayRate)
VALUES(GETDATE(), 'USD','WRW', 'NamePlaceholder', 2.01, 1.65)
GO

SELECT * FROM Sales.Currency WHERE CurrencyCode = 'WRW'       
SELECT * FROM Sales.CurrencyRate WHERE ToCurrencyCode = 'WRW'  

UPDATE Sales.ViewCurrency2
SET 
	Name='NamePlaceholderUpdated',
	AverageRate = 2.33,
	EndOfDayRate=3.1
WHERE CurrencyCode = 'WRW'
GO

SELECT * FROM Sales.Currency WHERE CurrencyCode = 'WRW'       
SELECT * FROM Sales.CurrencyRate WHERE ToCurrencyCode = 'WRW' 

DELETE 
FROM Sales.ViewCurrency2
WHERE CurrencyCode = 'WRW'
GO

SELECT * FROM Sales.Currency WHERE CurrencyCode = 'WRW'       
SELECT * FROM Sales.CurrencyRate WHERE ToCurrencyCode = 'WRW'  