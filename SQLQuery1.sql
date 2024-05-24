use AdventureWorks

select * from Sales.Customer


SELECT *                               --tables and table type
FROM AdventureWorks.INFORMATION_SCHEMA.TABLES;

SELECT TABLE_NAME                             --actual tables
FROM AdventureWorks.INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';


SELECT * FROM Sales.Store              --retrieving data for company name

select * from Sales.Customer

SELECT * FROM Person.Person      --retirving data of customer (name)


SELECT c.* , s.Name             --retrieving data of customer having company name ending with n
FROM Sales.Store s, Sales.Customer c
where s.BusinessEntityID = c.StoreID
and s.Name LIKE '%n'

--list of all customers who live in berlin or london
SELECT DISTINCT c.CustomerID, 
                COALESCE(p.FirstName, s.Name) AS FirstNameOrStoreName, 
                p.LastName, 
                a.AddressLine1, 
                a.City, 
                sp.Name AS StateProvince, 
                a.PostalCode
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID OR c.StoreID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE a.City IN ('Berlin', 'London')

--list of all customers who live in UK or USA
SELECT DISTINCT c.CustomerID, 
                COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
                a.AddressLine1, 
                a.City, 
                sp.Name AS StateProvince, 
                cr.Name AS Country, 
                a.PostalCode
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID OR c.StoreID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States')

--list of all products sorted by product name
SELECT * FROM Production.Product
SELECT ProductID,Name,ProductNumber FROM Production.Product ORDER BY Name

--list of all products where product name starts with A
SELECT ProductID,Name,ProductNumber FROM Production.Product where Name LIKE 'A%'
--list of customers who ever placed an order
select * from  Sales.SalesOrderHeader
SELECT DISTINCT c.CustomerID, 
                COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID


--list of all customers who live in london and have bought chai
SELECT DISTINCT c.CustomerID, 
                COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName, 
                a.AddressLine1, 
                a.City, 
                sp.Name AS StateProvince, 
                a.PostalCode
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID OR c.StoreID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE a.City = 'London'
  AND pr.Name = 'Chai'


--list of all customers who never placed an order
select * from  Sales.SalesOrderHeader
SELECT DISTINCT c.CustomerID, 
                COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
where soh.CustomerID IS NULL

--list of customers who ordered Tofu
SELECT DISTINCT c.CustomerID, 
                COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE pr.Name = 'Tofu'

--details of first order of system
-- Subquery to find the SalesOrderID of the first order
WITH FirstOrder AS (
    SELECT TOP 1 SalesOrderID
    FROM Sales.SalesOrderHeader
    ORDER BY OrderDate ASC
)
-- Main query to get the details of the first order
SELECT soh.SalesOrderID,
       soh.OrderDate,
       soh.DueDate,
       soh.ShipDate,
       soh.Status,
       soh.OnlineOrderFlag,
       soh.SalesOrderNumber,
       soh.PurchaseOrderNumber,
       soh.AccountNumber,
       soh.CustomerID,
       COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
       soh.ShipToAddressID,
       a.AddressLine1,
       a.City,
       sp.Name AS StateProvince,
       cr.Name AS Country,
       soh.TotalDue
FROM Sales.SalesOrderHeader soh
JOIN FirstOrder fo ON soh.SalesOrderID = fo.SalesOrderID
LEFT JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress bea ON soh.ShipToAddressID = bea.AddressID
LEFT JOIN Person.Address a ON bea.AddressID = a.AddressID
LEFT JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
LEFT JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode

--details of most expensive order date
-- Subquery to find the SalesOrderID of the most expensive order
WITH MostExpensiveOrder AS (
    SELECT TOP 1 SalesOrderID
    FROM Sales.SalesOrderHeader
    ORDER BY TotalDue DESC
)
-- Main query to get the details of the most expensive order
SELECT soh.SalesOrderID,
       soh.OrderDate,
       soh.DueDate,
       soh.ShipDate,
       soh.Status,
       soh.OnlineOrderFlag,
       soh.SalesOrderNumber,
       soh.PurchaseOrderNumber,
       soh.AccountNumber,
       soh.CustomerID,
       COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
       soh.ShipToAddressID,
       a.AddressLine1,
       a.City,
       sp.Name AS StateProvince,
       cr.Name AS Country,
       soh.TotalDue
FROM Sales.SalesOrderHeader soh
JOIN MostExpensiveOrder meo ON soh.SalesOrderID = meo.SalesOrderID
LEFT JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress bea ON soh.ShipToAddressID = bea.AddressID
LEFT JOIN Person.Address a ON bea.AddressID = a.AddressID
LEFT JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
LEFT JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode

--orderID and avg quantity of items in that order
SELECT * FROM Sales.SalesOrderHeader as soh
SELECT * FROM Sales.SalesOrderDetail as sod

SELECT soh.SalesOrderID,
       AVG(sod.OrderQty) AS AvgQuantity
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID
ORDER BY soh.SalesOrderID

--OR

SELECT sod.SalesOrderID,AVG(sod.OrderQty) as AverageQty from Sales.SalesOrderDetail as sod  GROUP BY sod.SalesOrderID ORDER BY sod.SalesOrderID

--for each orderID min and max quantity of items in that order
SELECT sod.SalesOrderID,MIN(sod.OrderQty) as MinQty,MAX(sod.OrderQty) as MaxQty from Sales.SalesOrderDetail as sod  GROUP BY sod.SalesOrderID ORDER BY sod.SalesOrderID

--list of all managers and total no. of employees who report to them

SELECT m.BusinessEntityID AS ManagerID,
       COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS ManagerName,
       COUNT(e.BusinessEntityID) AS TotalEmployees
FROM HumanResources.Employee e
JOIN HumanResources.Employee m ON e.BusinessEntityID = m.BusinessEntityID
LEFT JOIN Person.Person p ON m.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON m.BusinessEntityID = s.BusinessEntityID
GROUP BY m.BusinessEntityID, COALESCE(p.FirstName + ' ' + p.LastName, s.Name)
ORDER BY TotalEmployees DESC

--get orderID and total quantity of each order that has total quantity>300
SELECT sod.SalesOrderID,count(sod.OrderQty) as totalQty from Sales.SalesOrderDetail as sod 
GROUP BY sod.SalesOrderID HAVING count(sod.OrderQty)>300
order by sod.SalesOrderID

--list of all orders placed on or afterv 1996/12/31
SELECT * FROM Sales.SalesOrderHeader WHERE OrderDate>=1996/12/31

--list of all orders shipped to Canada
SELECT soh.SalesOrderID,
       soh.OrderDate,
       soh.ShipDate,
       soh.Status,
       soh.SalesOrderNumber,
       soh.CustomerID,
       a.AddressLine1,
       a.City,
       sp.Name AS StateProvince,
       cr.Name AS Country
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada'
ORDER BY soh.OrderDate DESC

--order total>200
SELECT sod.SalesOrderID,count(sod.OrderQty) as totalQty from Sales.SalesOrderDetail as sod 
GROUP BY sod.SalesOrderID HAVING count(sod.OrderQty)>200
order by sod.SalesOrderID

--list of countries and sales made in each country
SELECT cr.Name AS Country,
       SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC

--list of customer contactNames and no. of orders they placed
SELECT COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS ContactName,
       COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY COALESCE(p.FirstName + ' ' + p.LastName, s.Name)
ORDER BY NumberOfOrders DESC

select * from Sales.Customer   --personid,storeID
select * from Person.Person     --businessEntityid
select * from Sales.Store     --businessEntityId
select * from Sales.SalesOrderHeader --customerId,SalesOrderId


--list of customer contact names who have placed more than 3 orders
SELECT COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS ContactName,
       COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c 
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY COALESCE(p.FirstName + ' ' + p.LastName, s.Name) having COUNT(soh.SalesOrderID)>3
ORDER BY NumberOfOrders DESC 

--list of discontinued products which were ordered between 1/1/1997 and 1/1/1998
select * from Production.Product

SELECT DISTINCT p.ProductID, 
                p.Name AS ProductName, 
                p.ProductNumber, 
                p.DiscontinuedDate
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01'
  AND p.DiscontinuedDate IS NOT NULL
ORDER BY p.Name

--list of employee First name,last name,Supervisor first name ,last name
SELECT e.BusinessEntityID AS EmployeeID,
       ep.FirstName AS EmployeeFirstName,
       ep.LastName AS EmployeeLastName,
       sp.FirstName AS SupervisorFirstName,
       sp.LastName AS SupervisorLastName
FROM HumanResources.Employee e
JOIN Person.Person ep ON e.BusinessEntityID = ep.BusinessEntityID
LEFT JOIN HumanResources.Employee s ON e.BusinessEntityID = s.BusinessEntityID
LEFT JOIN Person.Person sp ON s.BusinessEntityID = sp.BusinessEntityID
ORDER BY e.BusinessEntityID


--list of employee id and total sale conducted by employee
select * from HumanResources.Employee
select * from Sales.SalesOrderHeader

SELECT e.BusinessEntityID AS EmployeeID,
       SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
GROUP BY e.BusinessEntityID
ORDER BY TotalSales DESC

--list of employees whose first name contains character a
SELECT p.FirstName AS FirstName,p.BusinessEntityID  AS EmployeeId FROM Person.Person AS p 
join HumanResources.Employee AS he ON p.BusinessEntityID = he.BusinessEntityID WHERE p.FirstName LIKE '%a%' ORDER BY p.FirstName

--list of managers who have more than 4 people reporting to them
SELECT e.BusinessEntityID AS ManagerID,
       p.FirstName AS ManagerFirstName,
       p.LastName AS ManagerLastName,
       COUNT(e.BusinessEntityID) AS NumberOfReports
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(e.BusinessEntityID) > 4
ORDER BY NumberOfReports DESC

--list of orders and product names
SELECT sod.ProductID,sod.OrderQty,pr.Name FROM Sales.SalesOrderDetail as sod 
JOIN Production.Product AS pr ON sod.ProductID = pr.ProductID ORDER BY sod.OrderQty

--list of orders placed by best customer
WITH CustomerOrderTotals AS (                --best customer
    SELECT soh.CustomerID,
           SUM(soh.TotalDue) AS TotalOrderValue
    FROM Sales.SalesOrderHeader soh
    GROUP BY soh.CustomerID
)
SELECT TOP 1 CustomerID
FROM CustomerOrderTotals
ORDER BY TotalOrderValue DESC

WITH CustomerOrderTotals AS (      --list of orderes
    SELECT soh.CustomerID,
           SUM(soh.TotalDue) AS TotalOrderValue
    FROM Sales.SalesOrderHeader soh
    GROUP BY soh.CustomerID
),
BestCustomer AS (
    SELECT TOP 1 CustomerID
    FROM CustomerOrderTotals
    ORDER BY TotalOrderValue DESC
)
SELECT soh.SalesOrderID,
       soh.OrderDate,
       soh.TotalDue,
       soh.ShipDate,
       soh.Status,
       soh.SalesOrderNumber
FROM Sales.SalesOrderHeader soh
JOIN BestCustomer bc ON soh.CustomerID = bc.CustomerID
ORDER BY soh.OrderDate DESC

--list of orders placed by customers who dont have fax no
SELECT soh.SalesOrderID,
       soh.OrderDate,
       soh.TotalDue,
       soh.ShipDate,
       soh.Status,
       soh.SalesOrderNumber,
       c.CustomerID,
       p.FirstName,
       p.LastName
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
WHERE pp.PhoneNumber IS NULL AND p.BusinessEntityID IS NOT NULL
ORDER BY soh.OrderDate DESC

--list of postal codes where product tofu was shipped
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Tofu'
ORDER BY a.PostalCode
--list of product names that were shipped to France
SELECT DISTINCT p.Name AS ProductName
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France'
ORDER BY p.Name

--list of product names and categories for supplier 'Speciality Biscuits,Ltd'
SELECT p.Name AS ProductName,
       psc.Name AS CategoryName
FROM Production.Product p
JOIN Purchasing.Vendor pv ON p.ProductID = pv.BusinessEntityID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
LEFT JOIN Production.ProductCategory psc ON ps.ProductCategoryID = psc.ProductCategoryID
WHERE v.Name = 'Speciality Biscuits, Ltd'
ORDER BY p.Name

--list of products that were never ordered
SELECT p.ProductID,
       p.Name AS ProductName,
       p.ProductNumber,
       p.ListPrice
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL
ORDER BY p.Name

--list of products where units in stock is less than 10 and units on order are 0
SELECT p.ProductID,
       p.Name AS ProductName,
       pi.Quantity AS UnitsInStock,
       pi.QuantityOnOrder AS UnitsOnOrder
FROM Production.Product p
JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
WHERE pi.Quantity < 10
  AND pi.QuantityOnOrder = 0
ORDER BY p.Name


--list of top 10 countries by sale
SELECT TOP 10 cr.Name AS Country,
       SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC

--no. of orders each employee has taken for customers with customerID betn A and AO
SELECT e.BusinessEntityID AS EmployeeID,
       COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN HumanResources.Employee e ON soh.SalesPersonID = e.BusinessEntityID
WHERE c.CustomerID BETWEEN 'A' AND 'AO'
GROUP BY e.BusinessEntityID
ORDER BY NumberOfOrders DESC

--orderate of most expensive order
SELECT TOP 1 OrderDate
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC

--product name and total revenue from that product
SELECT p.Name AS ProductName,
       SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC

--supplierid and numbers of product offered
SELECT pv.BusinessEntityID AS SupplierID,
       COUNT(pv.ProductID) AS NumberOfProducts
FROM Purchasing.ProductVendor pv
GROUP BY pv.BusinessEntityID
ORDER BY NumberOfProducts DESC

select * from Production.

--top ten customers based on their business
SELECT TOP 10 c.CustomerID,
       p.FirstName + ' ' + p.LastName AS CustomerName,
       SUM(soh.TotalDue) AS TotalBusiness
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalBusiness DESC

--what is total revenue of compnay
SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader









