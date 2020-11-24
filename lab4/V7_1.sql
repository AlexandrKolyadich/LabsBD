USE AdventureWorks2012;
GO

/*
	Создайте таблицу Sales.CurrencyHst, которая будет хранить информацию об изменениях в таблице Sales.Currency.
	Обязательные поля, которые должны присутствовать в таблице: 
	ID — первичный ключ IDENTITY(1,1); 
	Action — совершенное действие (insert, update или delete); 
	ModifiedDate — дата и время, когда была совершена операция; 
	SourceID — первичный ключ исходной таблицы; 
	UserName — имя пользователя, совершившего операцию. 
	Создайте другие поля, если считаете их нужными.
*/

CREATE TABLE Sales.CurrencyHst (
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	Action NVARCHAR(20) CHECK(Action IN ('INSERT', 'UPDATE', 'DELETE')),
	ModifiedDate DATETIME NOT NULL,
	SourceID NVARCHAR(30) NOT NULL,
	UserName NVARCHAR(50)
);
GO

/*
	Создайте три AFTER триггера для трех операций INSERT, UPDATE, DELETE для таблицы Sales.Currency.
	Каждый триггер должен заполнять таблицу Sales.CurrencyHst с указанием типа операции в поле Action.
*/

CREATE TRIGGER CurrencyAfterInsert ON Sales.Currency
FOR INSERT
AS
	DECLARE @sourceID NVARCHAR(30);

	SELECT @sourceID = inserted.Name FROM inserted;

	INSERT INTO Sales.CurrencyHst(Action, ModifiedDate, SourceID, UserName)
	VALUES('INSERT', GETDATE(), @sourceID, CURRENT_USER);
GO

CREATE TRIGGER CurrencyAfterUpdate ON Sales.Currency
FOR UPDATE
AS
	DECLARE @sourceID NVARCHAR(30);

	SELECT @sourceID = inserted.Name FROM inserted;

	INSERT INTO Sales.CurrencyHst(Action, ModifiedDate, SourceID, UserName)
	VALUES('UPDATE', GETDATE(), @sourceID, CURRENT_USER);
GO

CREATE TRIGGER CurrencyAfterDelete ON Sales.Currency
FOR DELETE
AS
	DECLARE @sourceID NVARCHAR(30);

	SELECT @sourceID = deleted.Name FROM deleted;

	INSERT INTO Sales.CurrencyHst(Action, ModifiedDate, SourceID, UserName)
	VALUES('DELETE', GETDATE(), @sourceID, CURRENT_USER);
GO


/*
	 Создайте представление VIEW, отображающее все поля таблицы Sales.Currency. 
	 Сделайте невозможным просмотр исходного кода представления.
*/

CREATE VIEW Sales.ViewCurrency 
WITH ENCRYPTION 
AS SELECT * FROM Sales.Currency;
GO

/*
	Вставьте новую строку в Sales.Currency через представление. 
	Обновите вставленную строку. Удалите вставленную строку. 
	Убедитесь, что все три операции отображены в Sales.CurrencyHst.
*/
INSERT INTO Sales.ViewCurrency(CurrencyCode, ModifiedDate, Name)
	VALUES('WRW', GETDATE(), 'NamePlaceholder')
GO

UPDATE Sales.ViewCurrency
	SET ModifiedDate= GETDATE(), Name= 'NamePlaceholderEdited'
	WHERE CurrencyCode='WRW'
GO

DELETE FROM Sales.ViewCurrency
	WHERE CurrencyCode='WRW'
GO

SELECT * FROM Sales.CurrencyHst;
GO

