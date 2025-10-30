
-- Create schemas
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS core_dw;
CREATE SCHEMA IF NOT EXISTS data_mart;

-- Create the staging table for coffee sales
CREATE TABLE staging.sale10 (
    Coffee_Sale_id INT,
    
    Size DECIMAL(16,2),
    Unit_Price DECIMAL(10,2),
    
    Sales DECIMAL(10,2),
    Coffee_Type VARCHAR(50),
    Roast_Type VARCHAR(50),
    Loyalty_Card VARCHAR(10)
);



SELECT * 
FROM staging.sale10;

-- Adjust column lengths if data allows:
CREATE TABLE staging.product_coffee10 (
    Product_ID INT,
    Coffee_Type VARCHAR(50),
    Roast_Type VARCHAR(10),
    Size DECIMAL(16,2),
    Unit_Price DECIMAL(16,2),
    Price_per_100g DECIMAL(16,2),
    Profit DECIMAL(16,2)
);


SELECT * 
FROM staging.product_coffee10;

-- Create STAGING table for raw customer data
CREATE TABLE staging.customer12 (
    Customer_ID INT,
    Customer_Name VARCHAR(100),
    Email VARCHAR(100),
    Phone_Number VARCHAR(20),
    Address_Line_1 VARCHAR(100),
    City VARCHAR(50),
    Country VARCHAR(50),
    Postcode VARCHAR(20),
    Loyalty_Card VARCHAR(10)
);
SELECT * 
FROM staging.customer12;

CREATE TABLE core_dw.dim_customer12 (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Email VARCHAR(100),
    Phone_Number VARCHAR(20),
    Address_Line_1 VARCHAR(100),
    City VARCHAR(50),
    Country VARCHAR(50),
    Postcode VARCHAR(20),
    Loyalty_Card VARCHAR(10)
);
SELECT * 
FROM core_dw.dim_customer12


CREATE TABLE core_dw.dim_product11 (
    
    Product_ID INT PRIMARY KEY,
    Coffee_Type VARCHAR(50),
    Roast_Type VARCHAR(10),
    Size DECIMAL(16,2),
    Unit_Price DECIMAL(16,2),
    Price_per_100g DECIMAL(16,2),
    Profit DECIMAL(16,2)
);
SELECT * 
FROM core_dw.dim_product11


CREATE TABLE IF NOT EXISTS core_dw.fact_sale_coffee10 (
    Coffee_Sale_id     INT PRIMARY KEY,
    Product_ID         INT,
    Customer_ID        INT,

    Size               DECIMAL(16,2),
    Unit_Price         DECIMAL(10,2),
    Sales              DECIMAL(10,2),
    Sales_1            DECIMAL(10,2),
    Loyalty_Card       VARCHAR(10),
    Sale_Date          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Coffee_Type        VARCHAR(50),
    Roast_Type         VARCHAR(50),

    FOREIGN KEY (Product_ID) REFERENCES core_dw.dim_product11(Product_ID),
    FOREIGN KEY (Customer_ID) REFERENCES core_dw.dim_customer12(Customer_ID)
);
SELECT * 
FROM core_dw.fact_sale_coffee10 



-- Most Purchased Country and City
SELECT 
    c.Country,
    c.City,
    SUM(f.Sales) AS Total_Sales
FROM 
    core_dw.fact_sale_coffee4 f
JOIN 
    core_dw.dim_customer3 c ON f.Loyalty_Card = c.Loyalty_Card
GROUP BY 
    c.Country, c.City
ORDER BY 
    Total_Sales DESC
LIMIT 1;



-- Top Country by Total Sales
SELECT 
    c.Country,
    SUM(f.Sales) AS Total_Sales
FROM 
    core_dw.fact_sale_coffee4 f
JOIN 
    core_dw.dim_customer3 c ON f.Loyalty_Card = c.Loyalty_Card
GROUP BY 
    c.Country
ORDER BY 
    Total_Sales DESC
LIMIT 1;

-- Top City by Total Sales
SELECT 
    c.City,
    SUM(f.Sales) AS Total_Sales
FROM 
    core_dw.fact_sale_coffee4 f
JOIN 
    core_dw.dim_customer3 c ON f.Loyalty_Card = c.Loyalty_Card
GROUP BY 
    c.City
ORDER BY 
    Total_Sales DESC
LIMIT 1;


-- Country Bean Preference: Total Sales by Coffee Type and Country
SELECT 
    f.Coffee_Type_Name AS Coffee_Type,
    c.Country,
    SUM(f.Sales) AS Total_Sales
FROM 
    core_dw.fact_sale_coffee4 f
JOIN 
    core_dw.dim_customer3 c ON f.Loyalty_Card = c.Loyalty_Card
WHERE 
    c.Country IN ('Ireland', 'United Kingdom', 'United States')  -- or your actual top 3
GROUP BY 
    f.Coffee_Type_Name, c.Country
ORDER BY 
    f.Coffee_Type_Name, c.Country;


SELECT 
    p.Coffee_Type,
    ROUND(SUM(p.Profit), 2) AS Total_Profit
FROM 
    core_dw.dim_product p
GROUP BY 
    p.Coffee_Type
ORDER BY 
    Total_Profit DESC;


SELECT 
    p.Roast_Type,
    ROUND(AVG(p.Price_per_100g), 2) AS Avg_Price_100g
FROM 
    core_dw.dim_product p
GROUP BY 
    p.Roast_Type
ORDER BY 
    p.Roast_Type;


SELECT
    f.coffee_type,
    f.size,
    ROUND(AVG(p.profit), 2) AS avg_profit
    
FROM core_dw.fact_sale_coffee10 f
JOIN core_dw.dim_product11 p ON f.product_id = p.product_id
GROUP BY f.coffee_type, f.size
HAVING COUNT(f.coffee_sale_id) < 100
ORDER BY avg_profit DESC;


SELECT 
    size,
    SUM(Sales) AS total_sales
FROM 
    core_dw.fact_sale_coffee4
GROUP BY 
    size
ORDER BY 
    total_sales DESC
LIMIT 1;



SELECT 
    Coffee_Type_Name AS coffee_type,
    SUM(Sales) AS total_sales
FROM 
    core_dw.fact_sale_coffee4
GROUP BY 
    Coffee_Type_Name
ORDER BY 
    total_sales DESC;


SELECT 
    Loyalty_Card,
    SUM(Sales) AS total_sales,
    ROUND(AVG(Sales), 2) AS avg_purchase_value
FROM 
    core_dw.fact_sale_coffee4
GROUP BY 
    Loyalty_Card;



SELECT 
    Coffee_Type_Name AS coffee_type,
    ROUND(AVG(Sales), 2) AS avg_revenue
FROM 
    core_dw.fact_sale_coffee4
GROUP BY 
    Coffee_Type_Name
ORDER BY 
    avg_revenue DESC;


SELECT 
    size,
    COUNT(*) AS Count
FROM 
    core_dw.fact_sale_coffee4
WHERE 
    Loyalty_Card = 'Yes'
GROUP BY 
    size
ORDER BY 
    size;