USE AdventureWorks2012
GO


/*
	Добавьте в таблицу dbo.PersonPhone поле City типа nvarchar(30);
*/


ALTER TABLE dbo.PersonPhone
ADD City NVARCHAR(30);


/*
	Объявите табличную переменную с такой же структурой как dbo.PersonPhone и заполните ее данными из dbo.PersonPhone. 
	Поле City заполните значениями из таблицы Person.Address поля City, а поле PostalCode значениями из Person.Address поля PostalCode. 
	Если поле PostalCode содержит буквы — заполните поле значением по умолчанию;
*/

DECLARE @TableVarPersonPhone TABLE(
	BusinessEntityId INT NOT NULL,
	PhoneNumber NVARCHAR(25) NOT NULL,
	PhoneNumberTypeId BIGINT  NULL,
	ModifiedDate DATETIME NULL,
	PostalCode NVARCHAR(15) NULL ,
	City NVARCHAR(30) NULL
	);

INSERT INTO
 @TableVarPersonPhone
 (	
	BusinessEntityId,
	PhoneNumber,
	PhoneNumberTypeId,
    ModifiedDate,
	PostalCode,
	City
)
SELECT
	dbo.PersonPhone.BusinessEntityID,
	dbo.PersonPhone.PhoneNumber,
	dbo.PersonPhone.PhoneNumberTypeID,
	dbo.PersonPhone.ModifiedDate,
	IIF(PATINDEX('%[A-Za-z]%', Address.PostalCode) <> 0,'0',Address.PostalCode ) ,
	Address.City
FROM dbo.PersonPhone
JOIN Person.BusinessEntityAddress ON BusinessEntityAddress.BusinessEntityID = dbo.PersonPhone.BusinessEntityID
JOIN Person.Address ON BusinessEntityAddress.AddressID=Address.AddressID

SELECT * FROM @TableVarPersonPhone

/*
	Обновите данные в полях PostalCode и City в dbo.PersonPhone данными из табличной переменной.
	Также обновите данные в поле PhoneNumber.
	Добавьте код ‘1 (11)’ для тех телефонов, для которых этот код не указан;
*/

UPDATE dbo.PersonPhone
SET dbo.PersonPhone.PostalCode = PhoneVariable.PostalCode,
	dbo.PersonPhone.City = PhoneVariable.City,
	PhoneNumber	= IIF(PATINDEX('%1 (11)%', dbo.PersonPhone.PhoneNumber) = 1, dbo.PersonPhone.PhoneNumber,'1 (11) ' + dbo.PersonPhone.PhoneNumber ) 
FROM dbo.PersonPhone
JOIN @TableVarPersonPhone AS PhoneVariable ON dbo.PersonPhone.BusinessEntityID = PhoneVariable.BusinessEntityId	

SELECT * FROM dbo.PersonPhone


/*
	Удалите данные из dbo.PersonPhone для сотрудников компании, 
	то есть где PersonType в Person.Person равен ‘EM’;
*/

DELETE 
	PhoneTable
FROM dbo.PersonPhone as PhoneTable
JOIN Person.Person ON PhoneTable.BusinessEntityID = Person.BusinessEntityID
WHERE PersonType = 'EM'


SELECT * FROM dbo.PersonPhone


/*
Удалите полe City из таблицы, удалите все созданные ограничения и значения по умолчанию.
Имена ограничений вы можете найти в метаданных.Имена значений по умолчанию найдите самостоятельно,
приведите код, которым пользовались для поиска;
*/


ALTER TABLE dbo.PersonPhone
DROP COLUMN City;
ALTER TABLE dbo.PersonPhone
DROP CONSTRAINT
    PK__PersonPh__00C7F7D4E1CDD8DB,
    df_PostalCode,
    CK__PersonPho__Posta__46136164;

/*
	 Удалите таблицу dbo.PersonPhone
*/

DROP TABLE
    dbo.PersonPhone;
