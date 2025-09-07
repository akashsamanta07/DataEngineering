
create database sales_db;
use sales_db;
show tables;
drop table orders;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);

select * from orders;

-- Find top 10 highest revenue generating products
SELECT product_id, SUM(sale_price) AS sales
FROM orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- find top 5 highest selling products in each region
WITH product_sales AS (
    SELECT region, 
           product_id, 
           SUM(sale_price) AS total_sales,
           ROW_NUMBER() OVER (PARTITION BY region 
                              ORDER BY SUM(sale_price) DESC) AS rn
    FROM orders
    GROUP BY region, product_id
)
SELECT region, product_id, total_sales
FROM product_sales
WHERE rn <= 5
ORDER BY region, total_sales DESC;


-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(MONTH FROM order_date) AS month,
        SUM(sale_price) AS total_sales
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) IN (2022, 2023)
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT 
    m2022.month,
    m2022.total_sales AS sales_2022,
    m2023.total_sales AS sales_2023,
    (m2023.total_sales - m2022.total_sales) AS sales_difference,
    ROUND(((m2023.total_sales - m2022.total_sales) / m2022.total_sales) * 100, 2) AS pct_growth
FROM monthly_sales m2022
JOIN monthly_sales m2023
  ON m2022.month = m2023.month
 AND m2022.year = 2022
 AND m2023.year = 2023
ORDER BY m2022.month;

-- for each category which month had highest sales 
WITH monthly_sales AS (
    SELECT 
        category,
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(MONTH FROM order_date) AS month,
        SUM(sale_price) AS total_sales
    FROM orders
    GROUP BY category, EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
, ranked_sales AS (
    SELECT 
        category,
        year,
        month,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY total_sales DESC
        ) AS rn
    FROM monthly_sales
)
SELECT category, year, month, total_sales
FROM ranked_sales
WHERE rn = 1
ORDER BY category;



-- which sub category had highest growth by profit in 2023 compare to 2022
WITH yearly_profit AS (
    SELECT 
        sub_category,
        EXTRACT(YEAR FROM order_date) AS year,
        SUM(profit) AS total_profit
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) IN (2022, 2023)
    GROUP BY sub_category, EXTRACT(YEAR FROM order_date)
)
, compare AS (
    SELECT 
        p2022.sub_category,
        p2022.total_profit AS profit_2022,
        p2023.total_profit AS profit_2023,
        (p2023.total_profit - p2022.total_profit) AS profit_difference,
        ROUND(((p2023.total_profit - p2022.total_profit) / NULLIF(p2022.total_profit,0)) * 100, 2) AS pct_growth
    FROM yearly_profit p2022
    JOIN yearly_profit p2023
      ON p2022.sub_category = p2023.sub_category
     AND p2022.year = 2022
     AND p2023.year = 2023
)
SELECT *
FROM compare
ORDER BY pct_growth DESC
LIMIT 1;













