/*
	Напишите запрос на создание новой базы данных 
	используя инструкцию CREATE DATABASE
*/
CREATE DATABASE Lab_1;
GO

USE Lab_1;
GO

/*
	Создайте новую схему с помощью инструкции CREATE SCHEMA
*/
CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

/*
	Создайте новую таблицу в схеме sales с именем Orders, 
	содержащей одно поле OrderNum, тип данных которого INT
*/
CREATE TABLE sales.Orders 
	(
		OrderNum INT NULL
	);
GO

/*
	Создайте бэкап базы данных 
	используя инструкцию BACKUP DATABASE и 
	сохраните его в файловой системе.
*/
BACKUP DATABASE Lab_1
TO DISK = 'D:\Lab_1.bak';
GO  

/*
	Удалите базу данных используя инструкцию DROP DATABASE.
*/



DROP DATABASE Lab_1;
GO

/*
	Восстановите базу данных из сохраненного бэкапа 
	используя инструкцию RESTORE DATABASE.
*/


RESTORE DATABASE Lab_1
FROM DISK = 'D:\Lab_1.bak';
GO

