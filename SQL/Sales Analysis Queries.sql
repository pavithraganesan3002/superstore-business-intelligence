# Create a  New Database 
Create database sales_project;
use sales_project;

# Create a New Table 
CREATE TABLE superstore_cleaned (
    Row_Id INT,
    Order_ID varchar(50),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_mode VARCHAR(50),
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(100),
    City VARCHAR(100),
    State VARCHAR(100),
    Postal_Code INT,
    Region VARCHAR(50),
    Product_ID VARCHAR(100),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(200) ,
    Sales DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(10,2),
    Profit DECIMAL(10,2),
    Order_Day INT,
    Order_Month VARCHAR(20),
    Order_Year INT,
    Ship_Day INT,
    Ship_Month VARCHAR(20),
    Ship_Year INT,
    Shipping_Delay INT,
    Profit_Margin DECIMAL(10,2)
);


#Basic Data Check
Select * from sales_project.superstore_cleaned limit 10 ;

#count of records
SELECT COUNT(*) FROM superstore_cleaned;


#Total Sales, Profit & Quantity
SELECT
    round(SUM(Sales),2) AS Total_Sales,
    Round(SUM(Profit),2) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity,
    count(order_id) as total_orders
FROM superstore_cleaned;

#Yearly Sales Trend
SELECT 
	Order_Year,
    Round(SUM(Sales),2) AS Total_Sales
FROM superstore_cleaned
GROUP BY Order_Year
ORDER BY Order_Year;

#Monthly Sales Trend
SELECT 
    Order_Year as Year,
    Order_Month AS Month,
    Round(SUM(Sales),2) AS Monthly_Sales
FROM superstore_Cleaned
GROUP BY Year, Month
ORDER BY Year, Month;

#Region-wise Sales & Profit 
SELECT 
    Region,
    Round(SUM(Sales),2) AS Sales,
    Round(SUM(Profit),2)AS Profit
FROM superstore_cleaned
GROUP BY Region
ORDER BY Sales DESC;

#Category & Sub-Category Performance
SELECT 
    Category,
    Sub_Category,
    Round(SUM(Sales),2) AS Sales,
    Round(SUM(Profit),2) AS Profit
FROM superstore_cleaned
GROUP BY Category, Sub_Category
ORDER BY Profit DESC;

#Top 10 Most Profitable Products
SELECT 
    Product_Name,
    Round(SUM(Sales),2) AS Sales,
    Round(SUM(Profit),2)AS Profit
FROM superstore_cleaned
GROUP BY Product_Name
ORDER BY Profit DESC
LIMIT 10;

#Loss-Making Products (Negative Profit)
SELECT 
    Product_Name,
    Round(SUM(Sales),2)AS Sales,
    Round(SUM(Profit),2) AS Profit
FROM superstore_cleaned
GROUP BY Product_Name
HAVING SUM(Profit) < 0
ORDER BY Profit ASC
LIMIT 20;

#Shipping Delay Calculation
SELECT 
    Ship_Mode,
    Round(AVG(Shipping_Delay),2) AS Avg_Delay,
    COUNT(*) AS Total_Orders
FROM superstore_cleaned
GROUP BY Ship_Mode
ORDER BY Avg_Delay DESC;

#Correlation: Discount vs Profit
SELECT 
    Discount,
    Round(SUM(Sales),2) AS Sales,
    Round(SUM(Profit),2) AS Profit
FROM superstore_cleaned
GROUP BY Discount
ORDER BY Discount;

# Segment-wise Performance
SELECT 
    Segment,
    Round(SUM(Sales),2) AS Sales,
    Round(SUM(Profit),2)AS Profit,
    COUNT(*) AS Total_Orders
FROM superstore_cleaned
GROUP BY Segment
ORDER BY Sales DESC;

# Top 10 Most Valuable Customers
SELECT 
    Customer_Name,
    Round(SUM(Sales),2) AS Total_Sales,
    Round(SUM(Profit),2) AS Total_Profit
FROM superstore_cleaned
GROUP BY Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;

#Average Shipping Time by Region
SELECT
    Region,
    Round(AVG(Shipping_Delay),2) AS Avg_Shipping_Time
FROM superstore_cleaned
GROUP BY Region
ORDER BY Avg_Shipping_Time DESC;

#Order Count by Ship Mode
SELECT
    Ship_Mode,
    COUNT(*) AS Orders
FROM superstore_cleaned
GROUP BY Ship_Mode
ORDER BY Orders DESC;

#Profit Margin Calculation
SELECT 
    Category,
    Round(AVG(Profit_Margin),2) AS Avg_Margin
FROM superstore_cleaned
GROUP BY Category
ORDER BY Avg_Margin DESC;

#City-wise Sales (Top 10 Cities)
SELECT 
    City,
    Round(SUM(Sales),2) AS Sales
FROM superstore_cleaned
GROUP BY City
ORDER BY Sales DESC
LIMIT 10;

#High Discount but Loss-Making Orders 
SELECT 
    Order_ID,
    Category,
    Sub_Category,
    Discount,
    Sales,
    Profit
FROM superstore_cleaned
WHERE Discount > 0.3 AND Profit < 0
ORDER BY Discount DESC, Profit ASC;


#Year-over-Year (YoY) Sales Growth (Window Function)
SELECT 
    Order_Year,
    SUM(Sales) AS total_sales,
    LAG(SUM(Sales)) OVER (ORDER BY Order_Year) AS prev_year_sales,
    ROUND(
        (SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY Order_Year))
        / LAG(SUM(Sales)) OVER (ORDER BY Order_Year) * 100, 2
    ) AS yoy_growth_percentage
FROM superstore_cleaned
GROUP BY Order_Year;

#Top 3 Products by Profit in Each Category (RANK)
SELECT *
FROM (
    SELECT 
        Category,
		Sub_Category,
        SUM(Profit) AS total_profit,
        RANK() OVER (PARTITION BY Category ORDER BY SUM(Profit) DESC) AS rnk
    FROM superstore_cleaned
    GROUP BY Category, Sub_Category
) t
WHERE rnk <= 3;

#Customers Causing Loss Despite High Sales

SELECT 
    Customer_Name,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM superstore_cleaned
GROUP BY Customer_Name
HAVING total_sales > 10000 AND total_profit < 0
ORDER BY total_sales DESC;

#Region-wise Contribution % to Total Sales

SELECT
    Region,
    ROUND(SUM(Sales),2) AS region_sales,
    ROUND(SUM(Sales) / (SELECT SUM(Sales) FROM superstore_cleaned) * 100, 2
    ) AS contribution_percentage
FROM superstore_cleaned
GROUP BY Region;


#Customer Lifetime Value (CLV – Project Level)
SELECT
    Customer_ID,
    Customer_Name,
    ROUND(SUM(Sales),2) AS lifetime_sales,
    ROUND(SUM(Profit),2) AS lifetime_profit
FROM superstore_cleaned
GROUP BY Customer_ID, Customer_Name
ORDER BY lifetime_profit DESC;


#Discount Impact on Profit (Advanced Aggregation)
SELECT 
    Discount,
    COUNT(*) AS order_count,
    ROUND(SUM(Profit),2) AS total_profit,
    ROUND(AVG(Profit),2) AS avg_profit
FROM superstore_cleaned
GROUP BY Discount
ORDER BY Discount desc;

#Monthly Sales Trend with Moving Average
SELECT
    Order_Year,
    Order_Month,
    SUM(Sales) AS monthly_sales,
    ROUND(
        AVG(SUM(Sales)) OVER (
            PARTITION BY Order_Year
            ORDER BY Order_Month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),2
    ) AS moving_avg_sales
FROM superstore_cleaned
GROUP BY Order_Year, Order_Month;
