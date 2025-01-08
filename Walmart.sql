USE walmart_db;

SELECT * FROM walmart;

-- DROP TABLE walmart;

SELECT COUNT(*) FROM walmart;

-- Count payment methods and number of transactions by payment method
SELECT 
	payment_method,
    COUNT(*) AS Quantity 
FROM walmart
GROUP BY payment_method;

-- Distinct branches and their respective quantities
SELECT DISTINCT branch, COUNT(*) AS branch_count
FROM walmart
GROUP BY branch;

-- Business Problem 
-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method
SELECT 
	payment_method,
    COUNT(*) AS number_of_transactions,
    SUM(quantity) AS quantity
FROM walmart
GROUP BY payment_method;

-- Q2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
SELECT 
	category,
    branch,
    avg_rating
FROM 
(
SELECT 
	branch,
    category,
    AVG(rating) AS avg_rating,
    RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking
FROM walmart
GROUP BY branch, category
) AS ranked
WHERE ranking = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
SELECT 
	branch,
    day_name,
    transactions
FROM
(
SELECT 
	branch,
    -- DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%Y-%m-%d') AS new_date_format,
    DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
	COUNT(*) AS transactions,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
FROM walmart
GROUP BY branch, day_name
) AS day_ranking
WHERE ranking = 1;

-- Q4: Calculate the total quantity of items sold per payment method

SELECT 
	payment_method,
    SUM(quantity) AS quantity_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
-- List the city, average_rating, min_rating and max_rating
SELECT 
	city,
    category,
    AVG(rating) AS average_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category;

-- Q6: Calculate the total profit and total revenue for each category
SELECT 
	category,
    SUM(total) AS total_revenue,
    SUM(total*profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch
WITH CTE AS
(
SELECT 
	branch,
    payment_method,
    COUNT(*) AS total_transactions,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
FROM walmart
GROUP BY branch, payment_method
)
SELECT * 
FROM CTE
WHERE ranking = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
-- Get the shift and the number of invoices per shift for each branch
SELECT DISTINCT
	branch,
    CASE 
		WHEN HOUR(DATE_FORMAT(TIME(time), '%H:%i:%s')) < 12 THEN 'Morning'
        WHEN HOUR(DATE_FORMAT(TIME(time), '%H:%i:%s')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END AS shift,
        COUNT(*) AS invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
-- revenue decrease ratio = ((last year revenue - current year revenue)/last year revenue) * 100

-- 2022 sales
WITH revenue_2022 AS
(
SELECT 
	branch,
	SUM(total) as revenue
FROM walmart
WHERE YEAR(DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%Y-%m-%d')) = 2022
GROUP BY branch
),
revenue_2023 AS
(
SELECT 
	branch,
	SUM(total) as revenue
FROM walmart
WHERE YEAR(DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%Y-%m-%d')) = 2023
GROUP BY branch
)
SELECT 
	r2022.branch,
    r2022.revenue AS 2022_revenue,
    r2023.revenue AS 2023_revenue,
    ROUND(((r2022.revenue - r2023.revenue)/r2022.revenue) *100,2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023
ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;


