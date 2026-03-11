CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30),
customer VARCHAR(30),
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(6,4) NOT NULL,
total DECIMAL(12,4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pCT FLOAT(11,9),
gross_income DECIMAL(12,4) NOT NULL,
rating DECIMAL(2,1)

);
-- -----------------------------------------------------------------------------
-- ---------------------- Checking duplicates ---------------------------------
with cte_example as(
select *, ROW_NUMBER() OVER(PARTITION BY `date`, time, invoice_id) as row_num from sales)

select * from cte_example where row_num > 1;

 -- ----------------------------------------------------------------------------
 -- ---------------------- Feature Engeneering ---------------------------------
 
 -- time_of_day
 
 SELECT 
    `time`,
    (CASE
        WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS time_of_date
FROM
    sales;
 
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales 
SET 
    time_of_day = (CASE
        WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END);
    

-- day_name

SELECT `date`, DAYNAME(`date`) from sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(`date`);

-- month_name
SELECT 
    `date`, MONTHNAME(`date`)
FROM
    sales;
    
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales 
SET 
    month_name = MONTHNAME(`date`);
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- ---------------------------- Generic ----------------------------------------------

-- How many unique city does the data have?
SELECT DISTINCT
    city
FROM
    sales;
    
-- How many unique branch does the data have?
SELECT DISTINCT branch
    city
FROM
    sales;

-- in which city is each branch
SELECT DISTINCT
    city, branch
FROM
    sales;
    
-- ---------------------------------------------------------------------------------
-- ----------------------- Product -------------------------------------------------

-- How many unique product lines does the data have ?
SELECT 
    COUNT(DISTINCT product_line)
FROM
    sales;

-- what is the most common payment method ?
SELECT 
    payment_method, COUNT(payment_method) AS cnt
FROM
    sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- what is the most selling product line ?
SELECT 
    product_line, COUNT(product_line) AS cnt
FROM
    sales
GROUP BY product_line
ORDER BY cnt DESC;

-- What is the total revenue by month ?
SELECT 
    month_name as month, SUM(total) AS total_revenue
FROM
    sales
GROUP BY month
ORDER BY total_revenue DESC;

-- what month had the largest COGS?
SELECT 
    month_name AS month, SUM(cogs) AS cogs
FROM
    sales
GROUP BY month
ORDER BY cogs DESC;

-- what product line had the larget revenue?
SELECT 
    product_line, SUM(total) AS total_revenue
FROM
    sales
GROUP BY product_line
ORDER BY total_revenue desc;

-- what city has the largest revenue?
SELECT 
   branch, city, SUM(total) AS total_revenue
FROM
    sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- what product line had the largest VAT
SELECT 
    product_line, AVG(vat) AS avg_tax
FROM
    sales
GROUP BY product_line
ORDER BY avg_tax desc;

-- which branch sold more products than average product sold?
SELECT 
    branch, SUM(quantity) AS qty
FROM
    sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT 
        AVG(quantity)
    FROM
        sales);

-- what is the most common product line by gender?
SELECT 
    gender, product_line, COUNT(gender) AS cnt
FROM
    sales
GROUP BY gender , product_line
ORDER BY cnt DESC;

-- what is the average rating of each product line?
SELECT 
    product_line, ROUND(AVG(rating), 2)
FROM
    sales
GROUP BY product_line
ORDER BY AVG(rating) DESC;

-- -------------------------------------------------------------------------
-- ------------------------- Sales -----------------------------------------

-- Number of sales in each time of the day per week

SELECT 
    time_of_day, COUNT(*) AS total_sales
FROM
    sales
WHERE
    day_name = 'Friday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- which of the customer type brings the most revenue

SELECT 
    customer, round(SUM(total), 2) as total_revenue
FROM
    sales
GROUP BY customer
ORDER BY total_revenue DESC;

-- which city has the largest VAT 
SELECT 
    city, AVG(VAT)
FROM
    sales
GROUP BY city
ORDER BY AVG(VAT) DESC;

-- which customer type pays the most in vat
SELECT 
    customer, AVG(VAT)
FROM
    sales
GROUP BY customer
ORDER BY AVG(VAT) DESC;

-- ------------------------------------------------------------------
-- -------------------------- Customer --------------------------------

-- How many unique customer type does the data have

SELECT DISTINCT
    customer, COUNT(*) AS cnt
FROM
    sales
GROUP BY customer
ORDER BY cnt DESC;

-- How many unique payment method does the data has
SELECT DISTINCT
    payment_method
FROM
    sales;
    
-- What is the most customer type 
    SELECT 
    customer, COUNT(*)
FROM
    sales
GROUP BY customer;

-- which customer type buys the most
SELECT 
    customer, COUNT(*) AS cstm_cnt
FROM
    sales
GROUP BY customer
ORDER BY cstm_cnt desc;

-- what's the gender of most of the customer 
SELECT 
    gender, COUNT(*) as gender_cnt
FROM
    sales
GROUP BY gender;

-- what's the gender distribution per branch
SELECT 
    branch, gender, COUNT(*) AS gender_cnt
FROM
    sales
GROUP BY branch , gender
ORDER BY branch;

SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    sales
WHERE
    branch = 'A'
GROUP BY gender;

-- what time of the day do customers give most ratings
SELECT 
    time_of_day, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- which time of the day do customers give most rating per branch
SELECT 
    time_of_day, AVG(rating) AS avg_rating
FROM
    sales
WHERE
    branch = 'C'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- which day of the week has the best average rating
SELECT 
    day_name, count(*), AVG(rating) AS avg_rating
FROM
    sales
GROUP BY day_name
ORDER BY count(*) DESC;

-- Which day of the week has the best average ratings per branch
SELECT 
    day_name, AVG(rating) AS avg_rating
FROM
    sales
where branch = 'C'
GROUP BY day_name
ORDER BY avg_rating DESC;



