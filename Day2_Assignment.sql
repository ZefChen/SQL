-- Joins:
-- (AdventureWorks)

USE AdventureWorks2019
GO

-- 1. Write a query that lists the country and province names 
-- from person.CountryRegion and person.StateProvince tables. 
-- Join them and produce a result set similar to the following.
-- Country                        Province

SELECT c.Name AS Country, s.Name AS Province
FROM person.CountryRegion AS c
INNER JOIN person.StateProvince AS s
ON c.CountryRegionCode = s.CountryRegionCode


-- 2. Write a query that lists the country and province names 
-- from person.CountryRegion and person.StateProvince tables 
-- and list the countries filter them by Germany and Canada.
-- Join them and produce a result set similar to the following.
-- Country                        Province

SELECT c.Name AS Country, s.Name AS Province
FROM person.CountryRegion AS c
INNER JOIN person.StateProvince AS s
ON c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Germany', 'Canada')


-- Using Northwind Database: (Use aliases for all the Joins)
USE Northwind
GO


-- 3. List all Products that has been sold at least once in last 25 years.

SELECT ProductName, SUM(od.Quantity) AS [Total Quantity] FROM Products AS p
INNER JOIN [Order Details] AS od ON p.ProductID = od.ProductID
INNER JOIN Orders AS o ON o.OrderID = od.OrderID
WHERE OrderDate >= DATEADD(YEAR, -25, GETDATE())
GROUP BY ProductName
HAVING SUM(od.Quantity) > 0




-- 4. List top 5 locations (Zip Code) where the products sold most in last 25 years.

SELECT TOP 5 ShipPostalCode, SUM(Quantity) As [Products Sold]
FROM Orders AS o INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
WHERE OrderDate >= DATEADD(YEAR, -25, GETDATE())
GROUP BY ShipPostalCode
ORDER BY SUM(Quantity) DESC



-- 5. List all city names and number of customers in that city.    

SELECT City, COUNT(CustomerID) AS [number of customers]
FROM Customers
GROUP BY City



-- 6. List city names which have more than 2 customers, and number of customers in that city

SELECT City, COUNT(CustomerID) AS [number of customers]
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2



-- 7. Display the names of all customers along with the count of products they bought

SELECT CompanyName, COUNT(OrderID) AS [count of products]
FROM Customers AS c INNER JOIN Orders AS o 
ON c.CustomerID = o.CustomerID
GROUP BY CompanyName


-- 8. Display the customer ids who bought more than 100 Products with count of products.

SELECT CustomerID, SUM(Quantity) AS [count of products]
FROM Orders AS o INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
GROUP BY CustomerID
HAVING SUM(Quantity) > 100

-- 9. List all of the possible ways that suppliers can ship their products. Display the results as below
-- Supplier Company Name                Shipping Company Name

SELECT sl.CompanyName AS [Supplier Company Name], 
sh.CompanyName AS [Shipping Company Name]
FROM Suppliers AS sl CROSS JOIN Shippers AS sh



-- 10. Display the products order each day. Show Order date and Product Name.

SELECT o.OrderDate, ProductName
FROM Orders AS o 
INNER JOIN [Order Details] AS od ON o.OrderID = od.OrderID
INNER JOIN Products AS p ON od.ProductID = p.ProductID
ORDER BY o.OrderDate


-- 11. Displays pairs of employees who have the same job title.

SELECT FirstName + ' ' + LastName AS [Employee Name], Title
FROM Employees
ORDER BY Title



-- 12. Display all the Managers who have more than 2 employees reporting to them.

SELECT e1.FirstName + ' ' + e1.LastName AS Managers
FROM Employees AS e1
JOIN Employees AS e2
ON e2.ReportsTo = e1.EmployeeID
GROUP BY e1.FirstName + ' ' + e1.LastName
HAVING COUNT(e2.ReportsTo) > 2




-- 13. Display the customers and suppliers by city. The results should have the following columns
-- City
-- Name
-- Contact Name,
-- Type (Customer or Supplier)

WITH CustomerCTE 
AS (
    SELECT City, CompanyName, ContactName, 'Customer' AS Type
    FROM Customers
),
 SupplierCTE
AS (
    SELECT City, CompanyName, ContactName, 'Supplier' AS Type
    FROM Suppliers
)
SELECT * FROM SupplierCTE
UNION ALL 
SELECT * FROM CustomerCTE




-- All scenarios are based on Database NORTHWIND.


-- 14. List all cities that have both Employees and Customers.

SELECT City FROM Employees
INTERSECT
SELECT City FROM Customers


-- 15. List all cities that have Customers but no Employee.
-- a. Use sub-query

SELECT DISTINCT City FROM Customers
WHERE City NOT IN (
    SELECT City FROM Employees
)



-- b. Do not use sub-query

SELECT DISTINCT City FROM Customers
EXCEPT
SELECT DISTINCT City FROM Employees


-- 16. List all products and their total order quantities throughout all orders.

SELECT ProductName, o.OrderID, SUM(Quantity) AS [total order quantities]
FROM Products AS p 
INNER JOIN [Order Details] AS od ON p.ProductID = od.ProductID
INNER JOIN Orders AS o ON o.OrderID = od.OrderID
GROUP BY ProductName, o.OrderID
ORDER BY ProductName


-- 17. List all Customer Cities that have at least two customers.
-- a. Use Union

SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2
UNION
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) = 2

-- b. Use no union

SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) >= 2

-- 18. List all Customer Cities that have ordered at least two different kinds of products.

WITH TwoKindCTE
AS(
    SELECT CustomerID, COUNT(ProductID) AS [Product Kinds Ordered]
    FROM Orders AS o
    INNER JOIN [Order Details] AS od ON o.OrderID = od.OrderID
    GROUP BY CustomerID
    HAVING COUNT(ProductID) >= 2
)
SELECT DISTINCT City FROM Customers AS c
INNER JOIN TwoKindCTE AS cte ON cte.CustomerID = c.CustomerID




-- 19. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.

SELECT pop.ProductName, avp.AvgPrice, mquan.City
FROM(SELECT TOP 5 ProductName, p.ProductID, SUM(Quantity) AS [total order quantities]
    FROM Products AS p 
    INNER JOIN [Order Details] AS od ON p.ProductID = od.ProductID
    INNER JOIN Orders AS o ON o.OrderID = od.OrderID
    GROUP BY ProductName, p.ProductID
    ORDER BY SUM(Quantity) DESC) AS pop
INNER JOIN (
    SELECT ProductID, SUM(UnitPrice * Quantity * (1-Discount))/SUM(Quantity) AS AvgPrice
    FROM [Order Details]
    GROUP BY ProductID 
) AS avp ON pop.ProductID = avp.ProductID
INNER JOIN (
    SELECT City, ProductID, SUM(Quantity) AS [total order quantities],
    RANK() OVER(PARTITION BY ProductID ORDER BY SUM(Quantity) DESC) AS rnk
    FROM [Order Details] AS od
    INNER JOIN Customers AS c ON od.ProductID = od.ProductID
    INNER JOIN Orders AS o ON o.OrderID = od.OrderID
    GROUP BY City, ProductID
) AS mquan ON mquan.ProductID = pop.ProductID
WHERE mquan.rnk = 1
 


-- 20. List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, 
-- and also the city of most total quantity of products ordered from. (tip: join  sub-query)

SELECT sales.City, orderquan.City FROM 
(SELECT e.City
FROM Employees AS e
INNER JOIN 
(SELECT TOP 1 EmployeeID, COUNT(OrderID) AS TotalOrders
FROM Orders AS o
GROUP BY EmployeeID
ORDER BY COUNT(OrderID) DESC) AS sl
ON e.EmployeeID = sl.EmployeeID) AS sales
INNER JOIN
(SELECT TOP 1 c.City, SUM(od.Quantity) AS TotalQuantity
FROM Customers AS c
INNER JOIN Orders AS o 
ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
GROUP BY c.City
ORDER BY TotalQuantity DESC) AS orderquan
ON sales.City = orderquan.City


-- 21. How do you remove the duplicates record of a table?
---- 1. ROW_NUMBER() + RANK() and delete rows with different numbers
---- 2. DISTINCT

