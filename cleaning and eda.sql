/*
                E-COMMERCE SALES ANALYTICS PROJECT
                DATABASE SETUP + DATA CLEANING + EDA
*/


# STEP 1 : CREATE DATABASE
CREATE DATABASE ecommerce_sales;
USE ecommerce_sales;


# STEP 2 : CREATE TABLE + IMPORT DATA
CREATE TABLE ecommerce_sales_analytics_raw (
    order_id INT PRIMARY KEY,
    order_date VARCHAR (20),
    customer_id INT,
    product_category VARCHAR(100),
    region VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(5,2),
    payment_method VARCHAR(50),
    delivery_days INT,
    customer_rating DECIMAL(3,2),
    revenue DECIMAL(12,2)
);


# STEP 3 : DISABLE SAFE UPDATE
SET SQL_SAFE_UPDATES = 0;


# STEP 4 : CONVERT ORDER DATE TO SQL DATE FORMAT
UPDATE ecommerce_sales_analytics_raw
SET order_date = STR_TO_DATE(order_date,'%d-%m-%Y')
ALTER TABLE ecommerce_sales_analytics_raw
MODIFY COLUMN order_date DATE;


# STEP 5 : ENABLE SAFE UPDATE
SET SQL_SAFE_UPDATES = 1;


# STEP 6 : DATA VALIDATION
# Number of Records
SELECT COUNT(*) AS total_records
FROM ecommerce_sales_analytics_raw;

# Preview Dataset
SELECT *
FROM ecommerce_sales_analytics_raw
LIMIT 10;

#Check Table Structure
DESCRIBE ecommerce_sales_analytics_raw;


# STEP 7 : CHECK MISSING VALUES
SELECT
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_missing,
SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_missing,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_missing,
SUM(CASE WHEN product_category IS NULL OR product_category='' THEN 1 ELSE 0 END) AS product_category_missing,
SUM(CASE WHEN region IS NULL OR region='' THEN 1 ELSE 0 END) AS region_missing,
SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_missing,
SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price_missing,
SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS discount_missing,
SUM(CASE WHEN payment_method IS NULL OR payment_method='' THEN 1 ELSE 0 END) AS payment_method_missing,
SUM(CASE WHEN delivery_days IS NULL THEN 1 ELSE 0 END) AS delivery_days_missing,
SUM(CASE WHEN customer_rating IS NULL THEN 1 ELSE 0 END) AS customer_rating_missing,
SUM(CASE WHEN revenue IS NULL THEN 1 ELSE 0 END) AS revenue_missing
FROM ecommerce_sales_analytics_raw;


# STEP 8 : CHECK DUPLICATE ORDERS
SELECT order_id,
COUNT(*) AS duplicate_count
FROM ecommerce_sales_analytics_raw
GROUP BY order_id
HAVING COUNT(*)>1;


# STEP 9 : CREATE CLEAN TABLE
CREATE TABLE ecommerce_sales_clean AS
SELECT * FROM ecommerce_sales_analytics_raw;


# STEP 10 : DATA RANGE CHECK
SELECT
MIN(order_date) AS first_order,
MAX(order_date) AS last_order
FROM ecommerce_sales_clean;

SELECT
    order_id,
    order_date
FROM ecommerce_sales_clean
ORDER BY order_date DESC
LIMIT 20;


# STEP 11 : DATASET OVERVIEW (EDA)
# Total Orders
SELECT COUNT(*) AS total_orders
FROM ecommerce_sales_clean;

# Total Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM ecommerce_sales_clean;

# Product Categories
SELECT COUNT(DISTINCT product_category) AS total_categories
FROM ecommerce_sales_clean;

# Regions
SELECT COUNT(DISTINCT region) AS total_regions
FROM ecommerce_sales_clean;

# Payment Methods
SELECT DISTINCT payment_method
FROM ecommerce_sales_clean;


# STEP 12 : SALES OVERVIEW
# Total Revenue
SELECT ROUND(SUM(revenue),2) AS total_revenue
FROM ecommerce_sales_clean;

# Average Order Value
SELECT ROUND(AVG(revenue),2) AS average_order_value
FROM ecommerce_sales_clean;

# Highest Revenue Order
SELECT *
FROM ecommerce_sales_clean
ORDER BY revenue DESC
LIMIT 1;


# STEP 13 : CUSTOMER OVERVIEW
# Top Customers by Orders
SELECT customer_id,
COUNT(*) AS total_orders
FROM ecommerce_sales_clean
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 10;

# Average Customer Rating
SELECT
ROUND(AVG(customer_rating),2) AS average_customer_rating
FROM ecommerce_sales_clean;


# STEP 14 : PRODUCT OVERVIEW
# Orders by Category
SELECT product_category,
COUNT(*) AS total_orders
FROM ecommerce_sales_clean
GROUP BY product_category
ORDER BY total_orders DESC;

# Quantity Sold by Category
SELECT product_category,
SUM(quantity) AS quantity_sold
FROM ecommerce_sales_clean
GROUP BY product_category
ORDER BY quantity_sold DESC;


# STEP 15 : TIME ANALYSIS
# Orders by Year
SELECT YEAR(order_date) AS year,
COUNT(*) AS total_orders
FROM ecommerce_sales_clean
GROUP BY YEAR(order_date);

# Orders by Month
SELECT MONTH(order_date) AS month_no,
MONTHNAME(order_date) AS month,
COUNT(*) AS total_orders
FROM ecommerce_sales_clean
GROUP BY MONTH(order_date),MONTHNAME(order_date)
ORDER BY month_no;


# STEP 16 : REGIONAL ANALYSIS
SELECT region,
ROUND(SUM(revenue),2) AS total_revenue
FROM ecommerce_sales_clean
GROUP BY region
ORDER BY total_revenue DESC;


# STEP 17 : PAYMENT METHOD DISTRIBUTION
SELECT payment_method,
COUNT(*) AS total_orders
FROM ecommerce_sales_clean
GROUP BY payment_method
ORDER BY total_orders DESC;


# STEP 18 : Advanced Analysis
# Categories with Above Average Revenue
WITH CategoryRevenue AS
(
    SELECT
        product_category,
        SUM(revenue) AS total_revenue
    FROM ecommerce_sales_clean
    GROUP BY product_category
)

SELECT *
FROM CategoryRevenue
WHERE total_revenue >
(
    SELECT AVG(total_revenue)
    FROM CategoryRevenue
)
ORDER BY total_revenue DESC;


# CTE 2 : High Value Customers
WITH CustomerRevenue AS
(
    SELECT
        customer_id,
        SUM(revenue) AS total_spent
    FROM ecommerce_sales_clean
    GROUP BY customer_id
)

SELECT *
FROM CustomerRevenue
WHERE total_spent >
(
    SELECT AVG(total_spent)
    FROM CustomerRevenue
)
ORDER BY total_spent DESC;


# Revenue based rank assigning to product_category
SELECT
    product_category,
    SUM(revenue) AS total_revenue,
    ROW_NUMBER() OVER
    (
        ORDER BY SUM(revenue) DESC
    ) AS row_num

FROM ecommerce_sales_clean
GROUP BY product_category;


SELECT
product_category,
SUM(revenue) AS total_revenue,
     RANK() OVER
    (
        ORDER BY SUM(revenue) DESC
    ) AS revenue_rank
FROM ecommerce_sales_clean
GROUP BY product_category;


SELECT

    product_category,

    SUM(revenue) AS total_revenue,

    DENSE_RANK() OVER
    (
        ORDER BY SUM(revenue) DESC
    ) AS category_rank

FROM ecommerce_sales_clean

GROUP BY product_category;


# Views 
CREATE VIEW sales_summary AS
SELECT
product_category,
SUM(revenue) total_revenue,
SUM(quantity) total_quantity,
AVG(discount) average_discount
FROM ecommerce_sales_clean
GROUP BY product_category;
SELECT *
FROM sales_summary;


# Revenue above average
SELECT *
FROM ecommerce_sales_clean
WHERE revenue >
(
SELECT AVG(revenue)
FROM ecommerce_sales_clean
);


# categories earning more than 500000
SELECT
product_category,
SUM(revenue) total_revenue
FROM ecommerce_sales_clean
GROUP BY product_category
HAVING SUM(revenue) > 500000;


# categorize customer by spending value
SELECT
customer_id,
SUM(revenue) total_spent,
CASE
WHEN SUM(revenue)>=10000 THEN 'High Value'
WHEN SUM(revenue)>=5000 THEN 'Medium Value'
ELSE 'Low Value'
END AS customer_segment
FROM ecommerce_sales_clean
GROUP BY customer_id;


# Rechecking the new table for dashboard creation
DESCRIBE ecommerce_sales_clean;
SELECT COUNT(*) FROM ecommerce_sales_clean;
SELECT * FROM ecommerce_sales_clean LIMIT 10;


# Creating dashboard
CREATE TABLE ecommerce_sales_dashboard AS
SELECT
    order_id,
    order_date,
    customer_id,
    product_category,
    region,
    quantity,
    unit_price,
    discount,
    payment_method,
    delivery_days,
    customer_rating,
    revenue,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    QUARTER(order_date) AS order_quarter,
    MONTHNAME(order_date) AS month_name,
	CASE
        WHEN discount < 0.10 THEN 'Low Discount'
        WHEN discount < 0.25 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_category,
    CASE
        WHEN customer_rating >= 4.5 THEN 'Excellent'
        WHEN customer_rating >= 3.5 THEN 'Good'
        WHEN customer_rating >= 2.5 THEN 'Average'
        ELSE 'Poor'
    END AS rating_category
FROM ecommerce_sales_clean;

SELECT *
FROM ecommerce_sales_dashboard
LIMIT 10;
SELECT COUNT(*)
FROM ecommerce_sales_dashboard;

