SELECT *
FROM pizza_sales_data;

-- KPI's--

-- Caculate Total Revenue --
SELECT SUM(total_price) AS 'Total Revenue'
FROM pizza_sales_data;

-- AVG Order Value--
SELECT (SUM(total_price) / COUNT(DISTINCT order_id)) AS 'Average order Value' 
FROM pizza_sales_data;

-- Total pizza sold--
SELECT SUM(quantity) AS 'Total pizza sold' 
FROM pizza_sales_data;

-- Total Orders --
SELECT COUNT(DISTINCT order_id) AS 'Total Orders'
FROM pizza_sales_data;

-- AVG Pizzas Per Order --
SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2))
AS Avg_Pizzas_per_order
FROM pizza_sales_data;


-- Daily Trend for Total Orders --
SELECT DAYNAME(order_date) AS order_day, COUNT(DISTINCT order_id) AS total_orders 
FROM pizza_sales_data
GROUP BY DAYNAME(order_date);

-- Monthly Trend for Total Orders --
SELECT MONTHNAME(order_date) AS order_day, COUNT(DISTINCT order_id) AS total_orders 
FROM pizza_sales_data
GROUP BY MONTHNAME(order_date);


-- Percentage of Sales by Pizza Category --
SELECT 	pizza_category, 
		CAST(SUM(total_price) AS DECIMAL(10,2)) AS 'Total Revenue', 
		CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) FROM pizza_sales_data) AS DECIMAL(10,2)) AS 'Percentage Category Total'
FROM pizza_sales_data
GROUP BY pizza_category
ORDER BY 3 DESC;

-- Percentage of Sales by Pizza Size--
SELECT 	pizza_size, 
		CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
		CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales_data) AS DECIMAL(10,2)) AS 'Percentage Category Total'
FROM pizza_sales_data
GROUP BY pizza_size
ORDER BY pizza_size;

-- Total Pizzas Sold by Pizza Category --
SELECT  pizza_category, 
		SUM(quantity) AS 'Total Quantity Sold'
FROM pizza_sales_data
GROUP BY pizza_category
ORDER BY  'Total Quantity Sold' DESC;

-- Top 5 Pizzas by Revenue--
SELECT pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales_data
GROUP BY pizza_name
ORDER BY Total_Revenue DESC
LIMIT 5;


-- TOP 5 lowest pizza by revenue --
SELECT pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales_data
GROUP BY pizza_name
ORDER BY Total_Revenue ASC
LIMIT 5;

-- Top 5 Pizza by Quanity--
SELECT pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales_data
GROUP BY pizza_name
ORDER BY Total_Pizza_Sold DESC
LIMIT 5;

-- Top 5 lowest Pizza by Quantity --
SELECT pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales_data
GROUP BY pizza_name
ORDER BY Total_Pizza_Sold 
LIMIT 5; 


-- Top 5 Pizzas by Total Order--
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales_data
GROUP BY pizza_name
ORDER BY Total_Orders DESC
LIMIT 5;

-- Top 5 lowest pizzas by Total Order --
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales_data
GROUP BY pizza_name
ORDER BY Total_Orders 
LIMIT 5;

-- Top 3 best seller product monthly --
SELECT Month_Name, pizza_name, pizza_category ,Max_Sold
FROM (
    SELECT 
        MONTHNAME(order_date) AS Month_Name,
        pizza_name, 
        pizza_category,
        SUM(quantity) AS Max_Sold,
        ROW_NUMBER() OVER(PARTITION BY MONTH(order_date) ORDER BY SUM(quantity) DESC) as rank_per_month
    FROM pizza_sales_data
    GROUP BY MONTH(order_date), Month_Name, pizza_name, pizza_category
) AS Ranked_Sales
WHERE rank_per_month <= 3
ORDER BY MONTH(STR_TO_DATE(Month_Name, '%M')); 

-- Peak Hours Analysis
SELECT HOUR(order_time) AS Order_Hour, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales_data
GROUP BY HOUR(order_time)
ORDER BY Total_Orders DESC;
-- Golden Hour from 12-13 and 17-19 --

-- Ingredients
SELECT pizza_ingredients, COUNT(pizza_ingredients)
FROM pizza_sales_data
GROUP BY 1;


-- Check which type of inngredients need for pizza
SELECT 
    CASE 
        WHEN pizza_ingredients LIKE '%Chicken%' THEN 'Chicken'
        WHEN pizza_ingredients LIKE '%Cheese%' THEN 'Cheese'
        WHEN pizza_ingredients LIKE '%Pepperoni%' THEN 'Pepperoni'
        WHEN pizza_ingredients LIKE '%Vegetables%' OR pizza_ingredients LIKE '%Tomatoes%' THEN 'Vegetables'
        ELSE 'Other'
    END AS Main_Ingredient,
    SUM(quantity) AS Total_Quantity_Sold
FROM pizza_sales_data
GROUP BY Main_Ingredient
ORDER BY Total_Quantity_Sold DESC;


-- Check the total of size category number then  separate them into 3 types of categories --
SELECT 
    Order_Size_Category,
    COUNT(*) AS Number_of_Orders
FROM (
    SELECT order_id, SUM(quantity) as total_qty,
    CASE 
        WHEN SUM(quantity) = 1 THEN 'Single Item'
        WHEN SUM(quantity) BETWEEN 2 AND 3 THEN 'Small Group (2-3)'
        ELSE 'Large Group (>3)'
    END AS Order_Size_Category
    FROM pizza_sales_data
    GROUP BY order_id
) AS Subquery
GROUP BY Order_Size_Category
ORDER BY 2 DESC;


-- Pareto 80/20 Revenue Analysis
WITH Revenue_CTE AS (
    SELECT
        pizza_name,
        SUM(total_price) AS product_revenue
    FROM pizza_sales_data
    GROUP BY pizza_name
),
Pareto AS (
    SELECT
        pizza_name,
        product_revenue,
        SUM(product_revenue) OVER (
            ORDER BY product_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,
        SUM(product_revenue) OVER () AS total_revenue
    FROM Revenue_CTE
)
SELECT
    pizza_name,
    product_revenue,
    ROUND(cumulative_revenue * 100.0 / total_revenue, 2) AS cumulative_percentage
FROM Pareto
ORDER BY product_revenue DESC;

