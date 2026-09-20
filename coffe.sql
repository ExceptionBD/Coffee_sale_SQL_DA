create database intro_db
use intro_db
create table emp2
(
emp_id int,
emp_name varchar(20),
Gender int,
Age int,
selary int
) 
                                                      
show tables

alter table emp
add location varchar(20)

alter table emp
drop column location

CREATE TABLE Products
(
	ProductId int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	ProductName VARCHAR(200) NOT NULL,
	BrandName VARCHAR(200) NOT NULL,
	ReceiveDate DATE NULL,
	AvailableStock FLOAT NOT NULL,
	Price float NOT NULL
);

select * from products
INSERT INTO Products (ProductName, BrandName, ReceiveDate, 
AvailableStock, Price)
VALUES 
('Logitech MX Master 3', 'Logitech', '2022-07-18', 100, 99.99),
('Apple Magic Keyboard', 'Apple', '2022-03-28', 200, 199.99),
('Samsung T7 Portable SSD', 'Samsung', '2022-04-15', 150, 179.99),
('990 Pro 2TB SSD', 'Samsung', '2022-09-07', 300, 279.99),
('Magic Mouse', 'Apple', '2022-03-28', 50, 99.99),
('SIGNATURE K650', 'Logitech', '2022-03-28', 100, 49.99),
('870 Evo SATA 250GB', 'Samsung', '2022-03-28', 75, 49.99),
('MX Key Mini', 'Logitech', '2022-03-28', 200, 99.99),
('Samsung T5 Portable SSD', 'Samsung', '2022-03-28', 100, 197.99),
('AirTag Leasther Loop', 'Apple', '2022-03-28', 20, 39.99);


select p.ProductName, p.BrandName, sum(Price) 
from products p
group by p.ProductName, p.BrandName;

select p.ProductName, p.BrandName, sum(p.Price) over(partition by p.BrandName order by p.ProductName) TP
from products p

select * , Row_number() over(partition by p.BrandName order by p.Price) Ro
from products p

select * , Rank() over(partition by p.BrandName order by p.Price) Rnk
from products p

SET SQL_SAFE_UPDATES = 0;
update products set Price=197.99 where Price=197.99


SELECT ROW_COUNT();

===================================================================================================================================================
;
Create database coffee
use coffee

;CREATE TABLE city
(
    city_id INT PRIMARY KEY,
    city_name VARCHAR(15),
    population BIGINT,
    estimated_rent DECIMAL(10,2),
    city_rank INT
);

CREATE TABLE customers
(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(25),
    city_id INT,
    CONSTRAINT fk_city 
        FOREIGN KEY (city_id) REFERENCES city(city_id)
);

CREATE TABLE products
(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(35),
    price DECIMAL(10,2)
);

CREATE TABLE sales
(
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    product_id INT,
    customer_id INT,
    total DECIMAL(10,2),
    rating INT,
    CONSTRAINT fk_products 
        FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_customers 
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
select * from city
select * from customers
select * from products
select * from sales

-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
	city_name,
	Round(population*.25/1000000,2) as coffee_consumers_in_millions,
    city_rank 
FROM city
ORDER BY 2 DESC

-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select *,
year(sale_date) as year,
QUARTER(sale_date) as quarter
from sales
where
year(sale_date)=2023 and
QUARTER(sale_date)=4

SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
WHERE 
	year(sale_date)=2023 and
    QUARTER(sale_date)=4
GROUP BY 1
ORDER BY 2 DESC limit 5

-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
	 p.product_name,
	 COUNT(s.sale_id) as total_orders
FROM products as p
LEFT JOIN
sales as s
ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC


-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city abd total sale
-- no cx in each these city

select * from city
select * from customers
select * from products
select * from sales


select 
c.customer_name,
ci.city_name,
avg(s.total) as total_sale_avg
from city ci
join customers c
on c.city_id=ci.city_id
join sales s
on s.customer_id=c.customer_id
group by 1,2


--
SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCT s.customer_id) as total_cx,
	ROUND(
    SUM(s.total) / COUNT(DISTINCT s.customer_id),
    2) AS avg_sale_pr_cx
	
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC

-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

WITH city_table as 
(
	SELECT 
		city_name,
		ROUND((population * 0.25)/1000000, 2) as coffee_consumers
	FROM city
),
customers_table
AS
(
	SELECT 
		ci.city_name,
		COUNT(DISTINCT c.customer_id) as unique_cx
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
)
SELECT 
	customers_table.city_name,
	city_table.coffee_consumers as coffee_consumer_in_millions,
	customers_table.unique_cx
FROM city_table
JOIN 
customers_table
ON city_table.city_name = customers_table.city_name

order by 3 desc

----- i think both is same result
SELECT 
		ci.city_name,
        ROUND((ci.population * 0.25)/1000000, 2) as coffee_consumers,
		COUNT(DISTINCT c.customer_id) as unique_cx
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
    Group by 1,2 
    order by 3 desc
    
    -- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT * 
FROM 
(
	SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rnk
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2
	-- ORDER BY 1, 3 DESC
) as t1
WHERE rnk <= 3

-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
-- this query is for who purchase any of product 
SELECT * FROM products;



SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id is not null
GROUP BY 1

-- second approach-------only who pershase the cofee products
SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY 1

select * from city
select * from customers
select * from products
select * from sales

-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

select
     ci.city_name as city,
     COUNT(DISTINCT c.customer_id) as customer,
     sum(s.total) as Total_sale,
     cast(SUM(s.total) / COUNT(DISTINCT s.customer_id)
    AS DECIMAL(10,2)) as avg_sale,
     sum(ci.estimated_rent) as Total_rent,
     cast(SUM(ci.estimated_rent) / COUNT(DISTINCT s.customer_id)
     AS DECIMAL(10,2)) as avg_rent
     
FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
Group by 1


------

WITH city_table
AS
(
	SELECT 
		ci.city_name,
		COUNT(DISTINCT s.customer_id) as total_cx,
		sum(s.total) as Total_sale,
        cast(SUM(s.total) / COUNT(DISTINCT s.customer_id)
    AS DECIMAL(10,2)) as avg_sale_pr_cx
		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(SELECT 
	city_name, 
	estimated_rent
FROM city
)
SELECT 
	cr.city_name,
	cr.estimated_rent,
	ct.total_cx,
	ct.avg_sale_pr_cx,
	sum(ci.estimated_rent) as Total_rent,
     cast(SUM(ci.estimated_rent) / COUNT(DISTINCT s.customer_id)
     AS DECIMAL(10,2)) as avg_rent
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 4 DESC

-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

WITH
monthly_sales
AS
(
	SELECT 
		ci.city_name as city_name,
		month(sale_date) as month,
	    year(sale_date) as year,
		SUM(s.total) as total_sale
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2, 3
	ORDER BY 1, 3, 2
),
growth_ratio
AS
(
		SELECT
			city_name,
			month,
			year,
			total_sale as cr_month_sale,
			LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale
		FROM monthly_sales
)

SELECT
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	Round(
		cast((cr_month_sale-last_month_sale)/last_month_sale*100
     AS DECIMAL(10,2)),2) 
		 as growth_ratio

FROM growth_ratio
WHERE 
	last_month_sale IS NOT NULL	


-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer



WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as total_cx,
		ROUND(
			cast(SUM(s.total) / COUNT(DISTINCT s.customer_id)
    AS DECIMAL(10,2)),1) as avg_sale_pr_cx
		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(
	SELECT 
		city_name, 
		estimated_rent,
		ROUND((population * 0.25)/1000000, 3) as estimated_coffee_consumer_in_millions
	FROM city
)
SELECT 
	cr.city_name,
	total_revenue,
	cr.estimated_rent as total_rent,
	ct.total_cx,
	estimated_coffee_consumer_in_millions,
	ct.avg_sale_pr_cx,
	cr.estimated_rent as Total_rent,
     Round(cast((cr.estimated_rent) / ct.total_cx
     AS DECIMAL(10,2)),2) as avg_rent
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 2 DESC