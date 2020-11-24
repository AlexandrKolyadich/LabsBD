USE AdventureWorks2012;
GO

/*
	Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT), 
	отображающую данные о количестве сотрудников (HumanResources.Employee) работающих в определенную 
	смену (HumanResources.Shift). Вывести информацию необходимо для каждого отдела (HumanResources.Department).
	Список названий смен передайте в процедуру через входной параметр.
	Таким образом, вызов процедуры будет выглядеть следующим образом:
	EXECUTE dbo.EmpCountByShift ‘[Day],[Evening],[Night]’
*/




CREATE PROCEDURE dbo.getEmpCountByShiftName
    @ShiftsNames NVARCHAR(50)
AS
	DECLARE @query NVARCHAR(1000);
	
	SET @query = 'SELECT DepName,' + @ShiftsNames + '
	FROM
	(
		SELECT
		    Department.Name AS DepName,
		    Shift.Name AS ShiftName
		FROM
		    HumanResources.Department
		    JOIN HumanResources.EmployeeDepartmentHistory
		        ON Department.DepartmentID = EmployeeDepartmentHistory.DepartmentID
		    JOIN HumanResources.Shift
		        ON EmployeeDepartmentHistory.ShiftID = Shift.ShiftID
		WHERE
		    EndDate IS NULL
	) AS source
	PIVOT
	(
	    COUNT(ShiftName)
	    FOR ShiftName
	    IN (' + @ShiftsNames + ')
	) AS PivotTable'

	EXEC sp_executesql @query
GO

EXECUTE dbo.getEmpCountByShiftName '[Day],[Evening],[Night]'

DROP PROCEDURE dbo.getEmpCountByShiftName
GO