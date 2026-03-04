/* =========================================================
   CUSTOMER SHOPPING BEHAVIOR ANALYSIS
   ========================================================= */


/* =========================================================
   1. IDENTIFY TRENDS
   ========================================================= */


/* 1.1 Category-wise Revenue */
WITH total_rev AS (
    SELECT SUM(purchase_amount) AS grand_total
    FROM customer
)

SELECT 
    c.category,
    SUM(c.purchase_amount) AS category_revenue,
    ROUND(
        (SUM(c.purchase_amount) / t.grand_total) * 100, 
        2
    ) AS revenue_percentage
FROM customer c
CROSS JOIN total_rev t
GROUP BY c.category, t.grand_total
ORDER BY category_revenue DESC;

/* 1.2 Season-wise Revenue */
SELECT 
    season,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY season
ORDER BY total_revenue DESC;


/* 1.3 Top 5 Revenue-Generating Items */
SELECT 
    item_purchased,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY item_purchased
ORDER BY total_revenue DESC
LIMIT 5;


/* 1.4 Size Distribution by Category */
SELECT 
    category,
    size,
    COUNT(*) AS total_orders
FROM customer
GROUP BY category, size
ORDER BY category, total_orders DESC;


/* =========================================================
   2. CUSTOMER SEGMENTATION
   ========================================================= */


/* 2.1 High-Value Customers 
   (Subscribed + Loyal + Frequent + Above Avg Spending) */

WITH avg_value AS (
    SELECT AVG(purchase_amount) AS avg_purchase
    FROM customer
)

SELECT 
    c.customer_id,
    c.purchase_amount,
    c.previous_purchases,
    c.frequency_of_purchases,
    c.subscription_status
FROM customer c
CROSS JOIN avg_value a
WHERE c.previous_purchases > 10
  AND c.subscription_status = 'Yes'
  AND c.purchase_amount > a.avg_purchase
  AND c.frequency_of_purchases IN (
        'Weekly',
        'Fortnightly',
        'Bi-Weekly',
        'Monthly'
  )
ORDER BY c.purchase_amount DESC, c.previous_purchases DESC;


/* 2.2 Loyal Customers (Previous Purchases > 10) */
SELECT 
    customer_id,
    previous_purchases
FROM customer
WHERE previous_purchases > 10
ORDER BY previous_purchases DESC;


/* 2.3 Subscription vs Non-Subscription Revenue */
SELECT
    SUM(CASE WHEN subscription_status = 'Yes' THEN purchase_amount ELSE 0 END) 
        AS subscription_revenue,
    SUM(CASE WHEN subscription_status = 'No' THEN purchase_amount ELSE 0 END) 
        AS non_subscription_revenue
FROM customer;


/* =========================================================
   3. MARKETING OPTIMIZATION
   ========================================================= */


/* 3.1 Discount Impact on Revenue */
SELECT 
    discount_applied,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount)::numeric, 2) AS avg_purchase,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY discount_applied;


/* 3.2 Are Discount Users Repeat Buyers? */
SELECT 
    discount_applied,
    ROUND(AVG(previous_purchases), 2) AS avg_previous_purchases
FROM customer
GROUP BY discount_applied;


/* 3.3 Payment Method Popularity */
SELECT 
    payment_method,
    COUNT(*) AS total_transactions
FROM customer
GROUP BY payment_method
ORDER BY total_transactions DESC;


/* =========================================================
   4. CUSTOMER ENGAGEMENT
   ========================================================= */


/* 4.1 Frequency of Purchase Distribution */
SELECT 
    frequency_of_purchases,
    COUNT(*) AS total_customers
FROM customer
GROUP BY frequency_of_purchases
ORDER BY total_customers DESC;


/* 4.2 Low-Rating Products (Avg Rating < 3.5) */
SELECT 
    category,
    item_purchased,
    ROUND(AVG(review_rating)::numeric, 2) AS avg_rating
FROM customer
GROUP BY category, item_purchased
HAVING AVG(review_rating) < 3.5
ORDER BY avg_rating ASC;


/* =========================================================
   5. ADVANCED ANALYSIS
   ========================================================= */


/* 5.1 Age Group Segmentation */
WITH age_groups AS (
    SELECT 
        customer_id,
        age,
        purchase_amount,
        CASE 
            WHEN age < 25 THEN 'Under 25'
            WHEN age BETWEEN 25 AND 40 THEN '25-40'
            WHEN age BETWEEN 41 AND 60 THEN '41-60'
            ELSE '60+'
        END AS age_group
    FROM customer
)

SELECT 
    age_group,
    ROUND(AVG(purchase_amount), 2) AS avg_spend
FROM age_groups
GROUP BY age_group
ORDER BY avg_spend DESC;


/* 5.2 Top 5 Revenue-Generating Locations */
SELECT 
    location,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY location
ORDER BY total_revenue DESC
LIMIT 5;

/* =========================================================
   END OF SCRIPT
   ========================================================= */