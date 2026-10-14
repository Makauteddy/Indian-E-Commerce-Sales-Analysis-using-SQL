-- 1.What is the total revenue generated from completed orders?

SELECT 
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM sales
WHERE order_status = 'Delivered';

--  2. How many completed orders has the business processed?
SELECT 
    COUNT(DISTINCT order_id) AS total_completed_orders
FROM sales
WHERE order_status = 'Delivered';

-- 3. What is the average order value for delivered orders?
SELECT 
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM sales
WHERE order_status = 'Delivered';

-- 4. How is monthly revenue changing over time?

SELECT DATE_TRUNC('month', order_date)::date AS month, 
       ROUND(SUM(total_amount), 2) AS revenue 
FROM sales 
WHERE order_status = 'Delivered' 
GROUP BY month 
ORDER BY month; 

-- 5. Which months experienced the largest decline in revenue?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(total_amount) AS revenue
    FROM sales
    WHERE order_status = 'Delivered'
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS revenue_change
FROM monthly_sales
ORDER BY month;  

-- 6. Which product categories generate the most revenue?
SELECT
    p.category,
    ROUND(SUM(s.total_amount), 2) AS revenue
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
WHERE s.order_status = 'Delivered'
GROUP BY p.category
ORDER BY revenue DESC;

-- 7. Which product categories are underperforming in revenue?
SELECT
    p.category,
    ROUND(SUM(s.total_amount), 2) AS revenue
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
WHERE s.order_status = 'Delivered'
GROUP BY p.category
ORDER BY revenue ASC;

-- 8. Which products contribute the most revenue?
SELECT
    p.product_name,
    ROUND(SUM(s.total_amount), 2) AS revenue
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
WHERE s.order_status = 'Delivered'
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;

--9. Which products have high stock levels but low sales?
SELECT
    p.product_name,
    p.stock_quantity,
    SUM(s.quantity) AS units_sold
FROM products p
JOIN sales s
    ON p.product_id = s.product_id
WHERE s.order_status = 'Delivered'
GROUP BY p.product_name, p.stock_quantity
ORDER BY p.stock_quantity DESC, units_sold ASC
LIMIT 10;

-- 10. Which brands contribute the most revenue?
SELECT
    p.brand,
    ROUND(SUM(s.total_amount), 2) AS revenue
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
WHERE s.order_status = 'Delivered'
GROUP BY p.brand
ORDER BY revenue DESC;

-- 11. Which products receive the lowest customer ratings?
SELECT
    p.product_name,
    ROUND(AVG(s.rating), 2) AS average_rating
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
WHERE s.rating IS NOT NULL
GROUP BY p.product_name
HAVING COUNT(s.rating) >= 20
ORDER BY average_rating ASC
LIMIT 10;

-- 12. Which products have the highest return rates?
SELECT
    p.product_name,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN s.order_status = 'Returned' THEN 1
        ELSE 0
    END) AS returned_orders,
    ROUND(
        SUM(CASE
            WHEN s.order_status = 'Returned' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS return_rate
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY return_rate DESC
LIMIT 10;

-- 13.Which product categories have the highest cancellation rates?
SELECT
    p.category,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN s.order_status = 'Cancelled' THEN 1
        ELSE 0
    END) AS cancelled_orders,
    ROUND(
        SUM(CASE
            WHEN s.order_status = 'Cancelled' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS cancellation_rate
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY cancellation_rate DESC;

--14.How much potential revenue is tied to cancelled orders?
SELECT
    COUNT(*) AS cancelled_orders,
    ROUND(SUM(total_amount), 2) AS potential_revenue_lost
FROM sales
WHERE order_status = 'Cancelled';

-- 15. How much revenue is affected by returned orders?
SELECT
    COUNT(*) AS returned_orders,
    ROUND(SUM(total_amount), 2) AS returned_order_value
FROM sales
WHERE order_status = 'Returned';

-- 16. Which payment methods have the highest cancellation rates?
SELECT
    payment_mode,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN order_status = 'Cancelled' THEN 1
        ELSE 0
    END) AS cancelled_orders,
    ROUND(
        SUM(CASE
            WHEN order_status = 'Cancelled' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS cancellation_rate
FROM sales
GROUP BY payment_mode
ORDER BY cancellation_rate DESC;

--17. How much is the business spending on coupon discounts?
SELECT
    ROUND(SUM(coupon_discount), 2) AS total_coupon_discount,
    ROUND(AVG(coupon_discount), 2) AS average_coupon_discount
FROM sales
WHERE order_status = 'Delivered';

--18. Do coupon users have a higher average order value?
SELECT
    CASE
        WHEN coupon_code IS NULL THEN 'No Coupon'
        ELSE 'Coupon Used'
    END AS coupon_usage,
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM sales
WHERE order_status = 'Delivered'
GROUP BY coupon_usage;

--19. Which customer tier contributes the largest share of revenue?
SELECT
    c.customer_tier,
    ROUND(SUM(s.total_amount), 2) AS revenue
FROM customers c
JOIN sales s
    ON c.customer_id = s.customer_id
WHERE s.order_status = 'Delivered'
GROUP BY c.customer_tier
ORDER BY revenue DESC;
--20. How much revenue comes from the top customers?
SELECT
    c.customer_name,
    COUNT(s.order_id) AS total_orders,
    ROUND(SUM(s.total_amount), 2) AS total_spent
FROM customers c
JOIN sales s
    ON c.customer_id = s.customer_id
WHERE s.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 10;
--21. Which states have the weakest sales performance?
SELECT
    state,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(total_amount), 2) AS revenue
FROM sales
WHERE order_status = 'Delivered'
GROUP BY state
ORDER BY revenue ASC;
--22. Which states experience the longest average delivery times?
SELECT
    state,
    ROUND(
        AVG(delivery_date - order_date),
        2
    ) AS average_delivery_days
FROM sales
WHERE order_status = 'Delivered'
  AND delivery_date IS NOT NULL
GROUP BY state
ORDER BY average_delivery_days DESC;