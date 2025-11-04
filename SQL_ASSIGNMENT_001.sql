-- Cleaned SQL script (DDL + sample DML)
DROP DATABASE IF EXISTS assignment;
CREATE DATABASE assignment;
USE  assignment;
DROP TABLE IF EXISTS Shipments;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Warehouses;

-- Warehouses
CREATE TABLE Warehouses (
    warehouse_id INTEGER PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    capacity_sqft BIGINT, -- allow larger capacity
    manager_name VARCHAR(100)
);

-- Suppliers
CREATE TABLE Suppliers (
    supplier_id INTEGER PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    registration_city VARCHAR(50)
);

-- Products
CREATE TABLE Products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    base_price DECIMAL(10,2) NOT NULL,
    hs_code VARCHAR(20) UNIQUE -- Harmonized System Code
);

-- Inventory (stock per warehouse)
CREATE TABLE Inventory (
    inventory_id INTEGER PRIMARY KEY,
    warehouse_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    reorder_level INTEGER DEFAULT 0,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Shipments
CREATE TABLE Shipments (
    shipment_id INTEGER PRIMARY KEY,
    product_id INTEGER NOT NULL,
    supplier_id INTEGER,
    origin_warehouse_id INTEGER NOT NULL,
    destination_city VARCHAR(50) NOT NULL,
    shipment_date DATE NOT NULL,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    shipping_cost DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20), -- 'In Transit', 'Delivered', 'Delayed'
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id),
    FOREIGN KEY (origin_warehouse_id) REFERENCES Warehouses(warehouse_id)
);
ALTER TABLE Shipments
RENAME COLUMN origin_warehouse_id to warehouse_id;
-- Insert sample Warehouses
INSERT INTO Warehouses (warehouse_id, warehouse_name, city, capacity_sqft, manager_name) VALUES
(1, 'Reliance Logistics Hub', 'Mumbai', 50000, 'Vivek Kulkarni'),
(2, 'Gati Cargo Depot', 'Delhi', 75000, 'Sneha Tandon'),
(3, 'TVS Supply Chain Point', 'Chennai', 40000, 'Gopal Iyer'),
(4, 'Amazon Fulfillment Center', 'Bangalore', 100000, 'Prabha Shetty');

-- Insert sample Suppliers (IDs used by Shipments must exist here)
INSERT INTO Suppliers (supplier_id, supplier_name, contact_person, registration_city) VALUES
(10, 'Lakshmi Textiles', 'Ramesh Kumar', 'Coimbatore'),
(20, 'Bharat Pharma Corp', 'Dr. Shanti Rao', 'Hyderabad'),
(30, 'Tata Motors Ancillaries', 'Pankaj Varma', 'Pune'),
(40, 'Amul Dairy Goods', 'Kiran Patel', 'Ahmedabad');

-- Insert sample Products (note base_price column)
INSERT INTO Products (product_id, product_name, category, base_price, hs_code) VALUES
(100, 'Basmati Rice (50kg)', 'Food Grain', 3500.00, '1006.30'),
(101, 'Auto Gearbox Unit', 'Automotive', 45000.00, '8708.40'),
(102, 'Cotton Fabric Roll', 'Textile', 8500.00, '5209.11'),
(103, 'Tablet Salt (Bulk)', 'Pharma Raw', 15000.00, '2501.00'),
(104, 'E-commerce Box (L)', 'Packaging', 50.00, '4819.10');

-- Insert sample Inventory
INSERT INTO Inventory (inventory_id, warehouse_id, product_id, stock_quantity, reorder_level) VALUES
(1000, 1, 100, 500, 100),
(1001, 1, 104, 15000, 5000),
(1002, 2, 101, 250, 50),
(1003, 3, 102, 300, 75),
(1004, 4, 100, 1000, 200),
(1005, 4, 103, 150, 100);

-- Insert sample Shipments (supplier_ids match Suppliers table)
INSERT INTO Shipments (shipment_id, product_id, supplier_id, origin_warehouse_id, destination_city, shipment_date, expected_delivery_date, actual_delivery_date, shipping_cost, status) VALUES
(5001, 101, 30, 2, 'Chennai', '2024-06-01', '2024-06-07', '2024-06-08', 12500.00, 'Delayed'),
(5002, 104, NULL, 1, 'Pune', '2024-06-05', '2024-06-07', '2024-06-07', 3500.00, 'Delivered'),
(5003, 102, 10, 3, 'Mumbai', '2024-06-10', '2024-06-15', '2024-06-15', 8900.00, 'Delivered'),
(5004, 103, 20, 4, 'Hyderabad', '2024-06-12', '2024-06-14', NULL, 6000.00, 'In Transit'),
(5005, 100, 40, 1, 'Kolkata', '2024-06-15', '2024-06-22', NULL, 15000.00, 'In Transit'),
(5006, 100, 40, 4, 'Delhi', '2024-06-18', '2024-06-20', '2024-06-20', 4200.00, 'Delivered');

SELECT * FROM Inventory;
SELECT * FROM Products;
SELECT * FROM Shipments;
SELECT * FROM Suppliers;
SELECT * FROM Warehouses;

-- I. DDL (Data Definition Language) - 4 Questions
-- Q1 Add a new column ’contact_email’ (VARCHAR 100, unique constraint) to the Suppliers table.
ALTER TABLE Suppliers
ADD COLUMN contact_email VARCHAR(100) UNIQUE;

-- Q2 Rename the column ’unit_cost’ in the Products table to ’base_price’.
ALTER TABLE Products
RENAME COLUMN base_price to unit_cost;

-- Q3 Create a non-unique index named ’idx_shipment_status’ on the ’status’ column of the Shipments table.
CREATE INDEX idx_shipment_status
ON Shipments (status);

ALTER TABLE Shipments
ADD INDEX idx_shipment_status (status);
-- use any one of the above

SELECT * FROM Shipments;

-- Q4 Modify the ’capacity_sqft’ column in the Warehouses table to allow a larger capacity (e.g., BIGINT).
ALTER TABLE Warehouses
MODIFY COLUMN capacity_sqft BIGINT;

DESCRIBE Warehouses;
SELECT * FROM Warehouses;

-- II. DML (Data Manipulation Language - CRUD) - 6 Questions
-- Q5 Insert a new product: ID 105, ’Solar Panel Unit’, category ’Renewable’, cost 25000.00, HS code ’8541.40’.
SELECT * FROM Products;
INSERT INTO Products (product_id, product_name, category,unit_cost , hs_code) VALUES
( 105, 'Solar Panel Unit', 'Renewable',  25000.00, '8541.40');
SELECT * FROM Products;

-- Q6 Update the stock quantity of ’Basmati Rice (50kg)’ (Product ID 100) in the Mumbai warehouse (ID 1) to 600 units

UPDATE Inventory
SET Stock_quantity=600
WHERE product_id=100
and warehouse_id=1;

-- Q7 Update the status of Shipment ID 5004 to’Delayed’and set the’actual_delivery_date’ to ’2024-06-17’.
SELECT * FROM Shipments;
UPDATE Shipments
SET status = 'Delayed',
actual_delivery_date = '2024-06-17'
where shipment_id=5004;

-- Q8 Insert a new warehouse: ID 5, ’Adani Logistics Park’, ’Ahmedabad’, 60000 sqft, managed by ’Anil Singh’.
INSERT INTO Warehouses (warehouse_id, warehouse_name, city, capacity_sqft, manager_name) VALUES
(5,'Adani Logistics Park','Ahemdabad',6000,'Anil Singh' );

-- Q9 Delete all inventory records for products belonging to the ’Pharma Raw’ category.
SELECT * FROM Inventory;
DELETE FROM Inventory
WHERE Product_id=103;

DELETE FROM Inventory
WHERE product_id IN (
    SELECT product_id
    FROM Products
    WHERE category = 'Pharma Raw'
);
SELECT * FROM Inventory;

 -- Q10 Delete the supplier named ’Amul Dairy Goods’ (ID 40).
 SELECT * FROM Suppliers;
 DELETE FROM Shipments
 WHERE supplier_id=40;

DELETE FROM Suppliers
WHERE supplier_name='Amul Dairy Goods'
AND supplier_id=40;


--  III. DQL- Basic SELECT (Data Query Language)- 7 Questions
--  Q11 Select the warehouse name, city, and manager name for all warehouses in ’Mumbai’ or ’Bangalore’.
select * from Warehouses;
SELECT warehouse_name , city, manager_name FROM Warehouses
WHERE city='Mumbai' OR city= 'Bangalore'; 

 -- Q12 Select the product name and HS code for all products whose category is NOT’Food Grain’.
SELECT product_name ,hs_code FROM Products
WHERE 	NOT category  = 'Food Grain';

-- Q13 Find all unique registration cities of suppliers.
 SELECT DISTINCT registration_city
FROM Suppliers;

 -- Q14 List all shipments with a shipping cost between 5000.00 and 10000.00 (inclusive), ordered by cost descending.

SELECT * FROM Shipments
WHERE shipping_cost BETWEEN '5000' AND '10000'
ORDER BY shipping_cost DESC;

 -- Q15 Select all products whose product name contains the word ’Unit’ or ’Roll’.

SELECT *  FROM Products
WHERE Product_name LIKE '%unit%' 
	OR Product_name LIKE  '%roll%';

 -- Q16 List the top 2 highest capacity warehouses.

SELECT * FROM Warehouses
LIMIT 2;
-- Q17 Select all shipments that do not have an associated supplier (supplier_id is NULL).

SELECT * FROM Shipments
WHERE NOT supplier_id = 'NULL';

--  IV. Functions (String, Numeric, Date)- 8 Questions
--  Q18 Concatenate the product name and category into a single string: ”NAME[CATEGORY]”.

SELECT CONCAT(product_name , category) AS  'NAME[CATEGORY] ' 
FROM Products;

 -- Q19 Display the supplier name, replacing all occurrences of ’Corp’ with ’Corporation’.
SELECT REPLACE(supplier_name,'Corp', 'Corporation')  FROM Suppliers ;

-- Q20 Select the shipment date, and the date that is 45 days after the shipment date, labeled ’PaymentDue_Date’.
SELECT * FROM Shipments;
DESCRIBE Shipments;
SELECT adddate(shipment_date,45) AS PaymentDue_Date FROM Shipments;

-- Q21 Calculate the difference in days between ’expected_delivery_date’ and ’actual_delivery_date’ for all shipments, labeled ’DeliveryDelayInDays’.
 SELECT datediff(actual_delivery_date,expected_delivery_date) as bufferdate FROM Shipments;
SELECT * FROM Shipments;

 -- Q22 Display the warehouse name, converting it to all lowercase letters.
SELECT lower(warehouse_name)  AS house_name FROM  Warehouses;

-- Q23 Calculate the total stock quantity of all products, rounded up to the nearest thousand.
SELECT ROUND(SUM(stock_quantity), -3) AS sum_of_stocks
FROM Inventory;

 -- Q24 Extract the year from the ’shipment_date’ for all shipments.
SELECT year(shipment_date) from Shipments;


--  Q25 Select the supplier name andthefirst three characters of their contact person’s name.
SELECT supplier_name, MID(supplier_name,1,3) FROM Suppliers;

--  V. Basic Joins- 8 Questions
-- Q26 List the product name, its current stock quantity, and the warehouse name where it is stored. (3-table INNER JOIN)
SELECT * FROM warehouses;
SELECT * FROM Products;
SELECT * FROM Inventory;
SELECT p.product_name,
i.stock_quantity,
w.warehouse_name
FROM Inventory i
INNER JOIN  Products p
	on i.product_id=p.product_id
    INNER JOIN Warehouses w 
    on i.warehouse_id= w.warehouse_id;
 -- Q27 List all shipments, showing the Shipment ID, the Supplier Name, and the destination city. (INNER JOIN)
 SELECT * FROM Shipments;
 SELECT * FROM Suppliers;
SELECT s.shipment_id,
 s.destination_city,
 p.supplier_name
 FROM Shipments s
 INNER JOIN suppliers p 
	on s.supplier_id=p.supplier_id;
    
 -- Q28 List all warehouses and the products they hold in stock (show warehouses even if they hold no stock). (LEFT JOIN)
SELECT w.warehouse_name,
 p.product_name,
i.stock_quantity

FROM Warehouses w
LEFT JOIN  Inventory i
    on i.warehouse_id= w.warehouse_id
LEFT JOIN  Products p
	on i.product_id=p.product_id;
-- Q29 Find all products that are currently NOT in stock in any warehouse. (LEFT JOIN with WHEREISNULL)

SELECT p.product_id,
		p.product_name
FROM Products p 
   LEFT JOIN Inventory i 
   on i.product_id = p.product_id
   WHERE i.product_id IS NULL
   ;

-- Q30 List all suppliers and their corresponding shipment IDs (show NULL for suppliers with no shipments). (LEFT JOIN)
SELECT * FROM suppliers;
SELECT * FROM Shipments;
SELECT s.supplier_name,
	   p.shipment_id
FROM Suppliers s 
	LEFT JOIN Shipments p 
    on p.supplier_id=s.supplier_id;
    
-- Q31 List the product  name and the name of the supplier who supplied the product for Shipment ID 5001.
SELECT p.product_name,
	   s.supplier_name
FROM Shipments w 
 LEFT JOIN Products p 
	on p.product_id=w.product_id
LEFT JOIN Suppliers s 
	on s.supplier_id= w.supplier_id
    WHERE w.shipment_id =5001;
    
-- Q32 List the product name, its category, and the name of the warehouse that stores it,
-- only for products with stock below their reorder level.
 SELECT p.product_name,
p.category,
w.warehouse_name
FROM Inventory i
INNER JOIN  Products p
	on i.product_id=p.product_id
    INNER JOIN Warehouses w 
    on i.warehouse_id= w.warehouse_id
WHERE  i.reorder_level > i.stock_quantity ;
 
 
 -- Q33 Combine all suppliers and all warehouses, listing every possible supplier warehouse pair. (CROSS JOIN)
 
 SELECT * 
 FROM Suppliers s 
 CROSS JOIN Warehouses w ;
 
 SELECT * 
FROM Suppliers s, Warehouses w;

--   VI. Self-Joins- 3 Questions
--  Q34 Findpairs of warehouses located in the same city, but with different warehouse IDs.
 
 SELECT * FROM Warehouses;
 SELECT w.warehouse_name
 FROM Warehouses w 
 JOIN Warehouses p 
 on NOT w.city = p.city AND  w.warehouse_id <>p.warehouse_id;
 
 -- Q35 List all inventory items that have a lower stock quantity than another item stored in the same warehouse.
 SELECT * FROM Warehouses;
 SELECT * FROM Inventory;
SELECT i.warehouse_id,i.stock_quantity
 FROM Inventory i 
 JOIN Inventory p 
 on i.warehouse_id= p.warehouse_id
 where i.stock_quantity < p.stock_quantity
 ;
 
-- Q36 Find the names of managers who manage a warehouse in the same city as the ’Reliance Logistics Hub’ (ID 1).
SELECT w.manager_name
FROM warehouses w 
join warehouses p 
on p.city= w.city
WHERE w.warehouse_name ='Reliance Logistics Hub'
AND w.warehouse_id <> p.warehouse_id
;

-- VII. Advanced DQL - Aggregation and Grouping - 8 Questions
-- Q37 Calculate the total number of unique products currently in inventory.
  SELECT * from inventory;
 SELECT COUNT(DISTINCT(product_id)) as unique_products FROM Inventory;

-- Q38 Find the average shipping cost for shipments with a status of ’Delivered’.
SELECT * FROM Shipments;
SELECT AVG(shipping_cost) as avg_shipping_cost
 FROM Shipments
 WHERE status = 'Delivered'; 
 
 SELECT AVG(s.shipping_cost) as avg_shipping_cost , s.status 
 FROM Shipments s
 JOIN Shipments p 
  on s.shipment_id = p.shipment_id
   WHERE s.status ='Delivered'
  ;
 
 -- Q39 List the total stock quantity for each product category (Category and Total Stock).
 SELECT * FROM Products;
 SELECT * FROM Inventory;
--  SELECT i.stock_quantity ,i.count(*) as no_of_category, p.category
--  FROM Inventory i 
--  RIGHT JOIN Products p 
--  on i.product_id= p.product_id
--   GROUP BY category
--  ;
 SELECT product_id ,count(*) as no_of_same_category,SUM(stock_quantity) FROM Inventory
 GROUP BY product_id ;

-- Q40 Find the number of shipments originated from each warehouse (WarehouseName and Shipment Count).
SELECT * FROM Warehouses ;
SELECT * FROM  Shipments;

SELECT w.warehouse_name,s.warehouse_id,count(*) as Shipment_Count 
 FROM Shipments s
 LEFT JOIN Warehouses w
 on w.warehouse_id=s.warehouse_id
GROUP BY s.warehouse_id;

-- Q41 Determine the maximum and minimum capacity of the warehouses.
SELECT min(capacity_sqft) as minimum_capacity , max(capacity_sqft) as maximum_capacity FROM Warehouses;

-- Q42 List the total stock value (stock_quantity * unit_cost) for each product name.
SELECT * FROM Products;

 SELECT p.product_id ,count(*) as no_of_same_category,SUM(i.stock_quantity*p.unit_cost) 
 FROM Inventory i 
 RIGHT JOIN Products p 
  on p.product_id=i.product_id
 GROUP BY p.product_id ;

-- Q43 Find the cities where the average warehouse capacity is greater than 60000 sqft. (HAVING AVG)

SELECT * FROM warehouses;
SELECT city,AVG(capacity_sqft) as average_capacity FROM warehouses
GROUP BY city
HAVING AVG( capacity_sqft) >60000
;
-- Q44 Find the supplier (name) that has supplied products for the highest number of distinct shipments.
SELECT * FROM suppliers;
SELECT * FROM Shipments;
SELECT s.supplier_name,COUNT(p.supplier_id) as number_of_shipments
 FROM suppliers s
 LEFT JOIN shipments p 
  on s.supplier_id=p.supplier_id
  GROUP BY s.supplier_id
  ORDER BY number_of_shipments asc;
   
  
SELECT s.supplier_name, COUNT(p.supplier_id) AS number_of_shipments
FROM suppliers s
LEFT JOIN shipments p 
  ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.supplier_name
HAVING COUNT(p.supplier_id) = (
  SELECT MIN(cnt)
  FROM (
    SELECT COUNT(p2.supplier_id) AS cnt
    FROM shipments p2
    GROUP BY p2.supplier_id
  ) AS temp
);


  
  ;
  SELECT s.supplier_name, COUNT(p.supplier_id) AS number_of_shipments
FROM suppliers s
LEFT JOIN shipments p 
  ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY number_of_shipments DESC
LIMIT 1;

  

-- Q45 Find the names of all products that have been part of a shipment. (Subquery with EXISTS)
SELECT * FROM Products;
SELECT * FROM Shipments;
SELECT DISTINCT(P.product_id) ,p.product_name
FROM Products p 
LEFT JOIN Shipments s 
on s.product_id= p.product_id
;

-- Q46 Find the warehouse names where the stock quantity of any product
-- is below the overall minimum reorder level across all inventory items. (ScalarSubquery)
SELECT * FROM Warehouses;
SELECT * FROM Inventory;

SELECT i.warehouse_id,w.warehouse_name
FROM Inventory i 
LEFT JOIN warehouses w
on i.warehouse_id = w.warehouse_id
WHERE i.stock_quantity < (
    SELECT MIN(reorder_level)
    FROM Inventory
) ;

-- Q47 List the names of suppliers whose registration city is the same as the city of
-- the ’TVS Supply Chain Point’ warehouse. (Scalar Subquery)
SELECT * FROM Suppliers;
SELECT * FROM Warehouses;
SELECT supplier_name, registration_city
FROM Suppliers
WHERE registration_city = (
    SELECT city 
    FROM Warehouses 
    WHERE warehouse_name = 'TVS Supply Chain Point'
);



-- Q48 Find the shipments where the ’shipping_cost’ is higher than the average
-- shipping cost for ALL shipments. (Scalar Subquery)
SELECT * FROM Shipments;
SELECT shipping_cost FROM Shipments
 WHERE shipping_cost >(select AVG(shipping_cost) from Shipments)
;

-- Q49 List the product names whose total stock quantity (sum of stock across all
-- warehouses) is greater than 1200. (Subquery in HAVING)
SELECT * FROM Warehouses;
SELECT * from Inventory;
SELECT * FROM Products;
SELECT p.product_name , sum(i.stock_quantity) as total_stock_each_product
FROM products p 
LEFT JOIN inventory i 
on i.product_id= p.product_id
GROUP BY p.product_id
HAVING sum(i.stock_quantity)>1200;

-- Q50 Find the products (names) that have never been shipped. (Subquery with NOT IN)
SELECT 
    product_name
FROM Products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id 
    FROM Shipments
);
