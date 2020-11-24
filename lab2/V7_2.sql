USE AdventureWorks2012
GO

/*
	Создайте таблицу dbo.PersonPhone с такой же структурой как Person.PersonPhone,
	не включая индексы, ограничения и триггеры;
*/

CREATE TABLE dbo.PersonPhone
(
	BusinessEntityID INT NOT NULL,
	PhoneNumber NVARCHAR(25) NOT NULL,
	PhoneNumberTypeID INT,
	ModifiedDate DATETIME
);
GO
/*
	Используя инструкцию ALTER TABLE, создайте для таблицы dbo.PersonPhone
	составной первичный ключ из полей BusinessEntityID и PhoneNumber;
*/

ALTER TABLE dbo.PersonPhone
ADD PRIMARY KEY (BusinessEntityID, PhoneNumber);



/*
	Используя инструкцию ALTER TABLE, создайте для таблицы dbo.PersonPhone новое поле PostalCode nvarchar(15) 
	и ограничение для этого поля, запрещающее заполнение этого поля буквами;
*/

ALTER TABLE dbo.PersonPhone
ADD PostalCode NVARCHAR(15) 
CHECK (PATINDEX('%[^A-Za-z]%', PostalCode) <> 0);

/*
	Используя инструкцию ALTER TABLE, 
	создайте для таблицы dbo.PersonPhone ограничение DEFAULT для поля PostalCode, задайте значение по умолчанию ‘0’;
*/


ALTER TABLE dbo.PersonPhone
ADD CONSTRAINT df_PostalCode
DEFAULT '0' FOR PostalCode



/* 
	Заполните новую таблицу данными из Person.PersonPhone,
	только контактами с типом ‘Cell’ из таблицы PhoneNumberType;
*/
INSERT INTO dbo.PersonPhone(BusinessEntityID,PhoneNumber,PhoneNumberTypeID, ModifiedDate)
SELECT
	Person.PersonPhone.BusinessEntityID,
	Person.PersonPhone.PhoneNumber,
	Person.PersonPhone.PhoneNumberTypeID,
	Person.PersonPhone.ModifiedDate
FROM Person.PersonPhone
JOIN Person.PhoneNumberType
ON Person.PersonPhone.PhoneNumberTypeID = Person.PhoneNumberType.PhoneNumberTypeID
WHERE Person.PhoneNumberType.Name = 'Cell';
GO

SELECT * 
FROM dbo.PersonPhone



/*
	Измените тип поля PhoneNumberTypeID на bigint и допускающим NULL значения.
*/


ALTER TABLE dbo.PersonPhone
ALTER COLUMN PhoneNumberTypeID BIGINT NULL