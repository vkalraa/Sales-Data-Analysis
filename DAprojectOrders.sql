#find top 10 highest reveue generating products 
SELECT product_id, SUM(sale_price) AS revenue
FROM df_orders
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;

#find top 5 highest selling products in each region

WITH CTE AS(
	SELECT product_id, region, SUM(sale_price) AS revenue,
    RANK() OVER(PARTITION BY region ORDER BY SUM(sale_price) DESC) AS ranking
	FROM df_orders
    GROUP BY 1,2
)
SELECT *
FROM CTE
WHERE ranking <=5;

#find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH CTE AS(
	SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY 1,2
)
SELECT order_month, SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023, 
ROUND(
        (SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) - 
         SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END)) / 
         NULLIF(SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END), 0) * 100, 2
    ) AS percentage_change
FROM CTE
GROUP BY 1
ORDER BY 1;

#for each category which month had highest sales 
#my original solution
WITH CTE AS(
SELECT category, SUM(sale_price) AS sales, MONTH(order_date) AS month,
RANK() OVER(PARTITION BY category ORDER BY SUM(sale_price) DESC) AS ranking
FROM df_orders
GROUP BY 1,3
)
SELECT *
FROM CTE
WHERE ranking = 1
ORDER BY sales DESC;

#my revised solution with different approach

WITH CTE AS (
    SELECT 
        category, 
        DATE_FORMAT(order_date, '%Y-%m') AS order_year_month, 
        SUM(sale_price) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(sale_price) DESC) AS row_num
    FROM df_orders
    GROUP BY 1, 2
)
SELECT category, order_year_month, total_sales
FROM CTE
WHERE row_num = 1
ORDER BY total_sales DESC;

#which sub category had highest growth by profit in 2023 compare to 2022

WITH CTE1 AS(
SELECT sub_category, YEAR(order_date) as order_year, SUM(profit) AS profit
FROM df_orders
GROUP BY 1,2
),
CTE2 AS(
SELECT sub_category, SUM(CASE WHEN order_year = 2022 THEN profit ELSE 0 END) AS profit_2022,
SUM(CASE WHEN order_year = 2023 THEN profit ELSE 0 END) AS profit_2023
FROM CTE1
GROUP BY 1
)
SELECT sub_category,profit_2022,profit_2023, profit_2023-profit_2022 AS absolute_growth, 
ROUND((profit_2023-profit_2022)/NULLIF(profit_2022, 0) * 100, 2) AS percentage_change
FROM CTE2 
ORDER BY 4 DESC
LIMIT 1;

