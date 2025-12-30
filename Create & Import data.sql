USE pizza;

DROP TABLE pizza_sales_data;

CREATE TABLE pizza_sales_data (
    pizza_id INT PRIMARY KEY,
    order_id INT,
    pizza_name_id VARCHAR(50),
    quantity INT,
    order_date VARCHAR(10),
    order_time TIME,
    unit_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    pizza_size VARCHAR(10),
    pizza_category VARCHAR(50),
    pizza_ingredients VARCHAR(255),
    pizza_name VARCHAR(255)
);


LOAD DATA LOCAL INFILE 'C:/Users/vieth/Downloads/pizza_sales.csv' 
INTO TABLE pizza_sales_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET SQL_SAFE_UPDATES = 0;

SELECT *
FROM pizza_sales_data;

UPDATE pizza_sales_data 
SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y');

-- Data Quality Check
SELECT * FROM pizza_sales_data 
WHERE total_price <= 0 OR quantity <= 0 OR order_date IS NULL;