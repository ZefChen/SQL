-- Use Northwind database. 
-- All questions are based on assumptions described by the Database Diagram sent to you yesterday. 
-- When inserting, make up info if necessary. Write query for each step. Do not use IDE. 
-- BE CAREFUL WHEN DELETING DATA OR DROPPING TABLE.
USE Northwind
GO
-- 1. Create a view named “view_product_order_[your_last_name]”, 
-- list all products and total ordered quantity for that product.
CREATE VIEW view_product_order_Chen AS 
SELECT ProductID, SUM(Quantity) AS TotalQuantity
FROM [Order Details]
GROUP BY ProductID
GO 

-- 2. Create a stored procedure “sp_product_order_quantity_[your_last_name]” 
-- that accept product id as an input and total quantities of order as output parameter.
CREATE PROC sp_product_order_quantity_Chen
@ProdID int,
@TotQuantity int out
AS
BEGIN
SELECT @TotQuantity = TotalQuantity
FROM view_product_order_Chen
WHERE ProductID = @ProdID
END
GO 

-- 3. Create a stored procedure “sp_product_order_city_[your_last_name]” 
-- that accept product name as an input and top 5 cities that ordered most that product 
-- combined with the total quantity of that product ordered from that city as output.
CREATE PROC sp_product_order_city_Chen
@ProdName VARCHAR(20),
@TopCity VARCHAR(20) out,
@ProdOrder INT out
AS 
BEGIN 
SELECT TOP 5 @TopCity = City, @ProdOrder = [Product Ordered]
FROM (
    SELECT ProductName, City, SUM(Quantity) AS [Product Ordered], 
    RANK() OVER(PARTITION BY ProductName ORDER BY SUM(Quantity) DESC) AS ProdRnk
    FROM Products AS p
    JOIN [Order Details] AS od ON p.ProductID = od.ProductID
    JOIN Orders AS o ON o.OrderID = od.OrderID
    JOIN Customers AS c ON c.CustomerID = o.CustomerID
    GROUP BY ProductName, City
) AS dt
WHERE ProductName = @ProdName AND dt.ProdRnk <= 5
END


-- 4. Create 2 new tables “people_your_last_name” “city_your_last_name”. 
-- City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. 
-- People has three records: 
-- {id:1, Name: Aaron Rodgers, City: 2}, 
-- {id:2, Name: Russell Wilson, City:1}, 
-- {Id: 3, Name: Jody Nelson, City:2}. Remove city of Seattle. 
-- If there was anyone from Seattle, put them into a new city “Madison”.
-- Create a view “Packers_your_name” lists all people from Green Bay. If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.

--- a. CREATE TABLE
CREATE TABLE people_Chen
(
id int,
Name varchar(20),
City int
)

CREATE TABLE city_Chen
(
Id int,
City varchar(20)
)

--- b. INSERT DATA
INSERT INTO people_Chen
VALUES (1, 'Aaron Rodgers', 2)

INSERT INTO people_Chen
VALUES (2, 'Russel Wilson', 1)

INSERT INTO people_Chen
VALUES (3, 'Jody Nelson', 2)

INSERT INTO city_Chen
VALUES (1, 'Seattle')

INSERT INTO city_Chen
VALUES (2, 'Green Bay')

--- c. Remove Seattle, put people from Seattle in Madison
UPDATE city_Chen
SET City = 'Madison'
WHERE Id = 1
GO

--- d. CREATE a VIEW, list all people from Green Bay
CREATE VIEW Packers_Zefeng_Chen AS
SELECT p.Name
FROM people_Chen AS p 
INNER JOIN city_Chen AS c 
ON p.City = c.Id
WHERE c.City = 'Green Bay'
GO

--- e. DROP both TABLES and VIEW
DROP TABLE city_Chen
DROP TABLE people_Chen
DROP VIEW Packers_Zefeng_Chen
GO
-- 5. Create a stored procedure “sp_birthday_employees_[you_last_name]” 
-- that creates a new table “birthday_employees_your_last_name” 
-- and fill it with all employees that have a birthday on Feb. 
-- (Make a screen shot) drop the table. Employee table should not be affected.
--- a. Stored Procedure
CREATE PROC sp_birthday_employees_Chen AS
BEGIN
CREATE TABLE birthday_employees_your_Chen
(
NameofEmp     Varchar(20),
MonthOfBirth  int
)
INSERT INTO birthday_employees_your_Chen
(NameofEmp, MonthOfBirth)
SELECT FirstName + ' ' + LastName, Month(BirthDate)
FROM Employees
WHERE Month(BirthDate) = 2
END

--- b. EXECUTE sp
EXEC sp_birthday_employees_Chen

SELECT * FROM birthday_employees_your_Chen

--- c. DROP
DROP TABLE birthday_employees_your_Chen

-- 6. How do you make sure two tables have the same data?
--- USE INTERSECTION, if not empty, then there are same data