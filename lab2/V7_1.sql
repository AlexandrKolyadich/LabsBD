USE AdventureWorks2012
GO

/*
	Вывести на экран последнюю дату изменения почасовой ставки для каждого сотрудника.

*/
SELECT HumanResources.Employee.BusinessEntityID, HumanResources.Employee.JobTitle,
MAX(EmployeePayHistory.RateChangeDate) AS LastRateDate 
 FROM HumanResources.Employee JOIN HumanResources.EmployeePayHistory 
 ON HumanResources.Employee.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID
 GROUP BY Employee.BusinessEntityID, Employee.JobTitle

/*
	Вывести на экран количество лет, которые каждый сотрудник проработал в каждом отделе. 
	Если сотрудник работает в отделе по настоящее время, количество лет считайте до сегодняшнего дня.
*/

SELECT Employee.BusinessEntityID,
 Employee.JobTitle,
  Department.Name AS  DepartamentName,
   EmployeeDepartmentHistory.StartDate,
    EmployeeDepartmentHistory.EndDate,
	 DATEDIFF(YEAR, EmployeeDepartmentHistory.StartDate,COALESCE(EmployeeDepartmentHistory.EndDate,GETDATE())) AS Years
	  FROM HumanResources.EmployeeDepartmentHistory
	  JOIN HumanResources.Employee  ON Employee.BusinessEntityID=EmployeeDepartmentHistory.BusinessEntityID
	  JOIN HumanResources.Department ON EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID


/*
	Вывести на экран информацию обо всех сотрудниках, с указанием отдела, в котором они работают в настоящий момент.
	Вывести также первое слово из названия группы отделов.
*/


SELECT Employee.BusinessEntityID,
	Employee.JobTitle,
	Department.Name,
	Department.GroupName,
	SUBSTRING(LTRIM(Department.GroupName),1,(CHARINDEX(' ',LTRIM(Department.GroupName) + ' ')-1)) AS DepGroup	
FROM HumanResources.Employee
JOIN HumanResources.EmployeeDepartmentHistory
ON Employee.BusinessEntityID = EmployeeDepartmentHistory.BusinessEntityID
JOIN HumanResources.Department
ON EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID
AND EmployeeDepartmentHistory.[EndDate] IS NULL;