-- EXPLORATORY DATA ANALYSIS
SELECT COUNT(*) AS total_records,
       AVG(Order_Amount) AS avg_order_amount,
       MIN(Order_Amount) AS min_order_amount,
       MAX(Order_Amount) AS max_order_amount
FROM sales_fr;

SELECT COUNT(*) AS total_records,
       AVG(Order_Amount) AS avg_order_amount,
       MIN(Order_Amount) AS min_order_amount,
       MAX(Order_Amount) AS max_order_amount
FROM sales_us;

SELECT COUNT(*) AS total_records,
       AVG(Order_Amount) AS avg_order_amount,
       MIN(Order_Amount) AS min_order_amount,
       MAX(Order_Amount) AS max_order_amount
FROM sales_in;

SELECT 
    COUNT(*) - COUNT(PROMOTION_CODE) AS missing_promo,
FROM sales_fr;

SELECT 
    COUNT(*) - COUNT(PROMOTION_CODE) AS missing_promo,
FROM sales_us;

SELECT 
    COUNT(*) - COUNT(PROMOTION_CODE) AS missing_promo,
FROM sales_in;

SELECT 
    order_date,
    SUM(Order_Amount) AS total_sales,
    COUNT(*) AS number_of_orders
FROM sales_fr
GROUP BY order_date
ORDER BY order_date;

SELECT 
    order_date,
    SUM(Order_Amount) AS total_sales,
    COUNT(*) AS number_of_orders
FROM sales_us
GROUP BY order_date
ORDER BY order_date;

SELECT 
    order_date,
    SUM(Order_Amount) AS total_sales,
    COUNT(*) AS number_of_orders
FROM sales_in
GROUP BY order_date
ORDER BY order_date;

SELECT 
    payment_method,
    SUM(Order_Amount) AS total_sales,
    COUNT(*) AS number_of_orders
FROM sales_fr
GROUP BY payment_method
ORDER BY total_sales DESC;

SELECT 
    payment_method,
    SUM(Order_Amount) AS total_sales,
    COUNT(*) AS number_of_orders
FROM sales_us
GROUP BY payment_method
ORDER BY total_sales DESC;

SELECT 
    payment_method,
    SUM(Order_Amount) AS total_sales,
    COUNT(*) AS number_of_orders
FROM sales_in
GROUP BY payment_method
ORDER BY total_sales DESC;

SELECT 
    shipping_status,
    SUM(Order_Amount) AS total_sales,
    COUNT(*) AS number_of_orders
FROM sales_fr
GROUP BY shipping_status
ORDER BY total_sales DESC;

SELECT 
    shipping_status,
    SUM(Order_Amount) AS total_sales,
    COUNT(*) AS number_of_orders
FROM sales_us
GROUP BY shipping_status
ORDER BY total_sales DESC;

SELECT 
    shipping_status,
    SUM(Order_Amount) AS total_sales,
    COUNT(*) AS number_of_orders
FROM sales_in
GROUP BY shipping_status
ORDER BY total_sales DESC;

SELECT 
    'India' AS region, Order_ID, Customer_Name, Order_Amount, Order_Date
FROM sales_in
UNION ALL
SELECT 
    'USA' AS region, Order_ID, Customer_Name, Order_Amount, Order_Date
FROM sales_us
UNION ALL
SELECT 
    'France' AS region, Order_ID, Customer_Name, Order_Amount, Order_Date
FROM sales_fr;