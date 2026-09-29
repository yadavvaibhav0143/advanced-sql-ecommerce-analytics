-- ======================================================
-- ADVANCED SQL PORTFOLIO: BUSINESS ANALYTICS QUERY SUITE
-- FINAL CONSOLIDATED VERSION | PostgreSQL
-- ======================================================

-- Q01: Monthly Sales Trend & Growth Rate
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS sales_month,
           SUM(gross_amount - discount_applied) AS net_sales
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT TO_CHAR(sales_month, 'YYYY-MM') AS calendar_month,
       ROUND(net_sales, 2) AS net_sales,
       ROUND(LAG(net_sales) OVER (ORDER BY sales_month), 2) AS previous_month_sales,
       ROUND(((net_sales - LAG(net_sales) OVER (ORDER BY sales_month)) * 100.0) /
             NULLIF(LAG(net_sales) OVER (ORDER BY sales_month), 0), 2) AS mom_growth_pct
FROM monthly_revenue
ORDER BY sales_month;

-- Q02: Cohort Retention Analysis
WITH cohort_baseline AS (
    SELECT customer_id, DATE_TRUNC('month', signup_date) AS cohort_month
    FROM customers
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM cohort_baseline
    GROUP BY cohort_month
),
activity AS (
    SELECT DISTINCT
        c.customer_id,
        c.cohort_month,
        EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', o.order_date), c.cohort_month)) * 12 +
        EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.order_date), c.cohort_month)) AS months_elapsed
    FROM cohort_baseline c
    JOIN orders o
      ON o.customer_id = c.customer_id
     AND o.order_status = 'Delivered'
     AND o.order_date >= c.cohort_month
),
data_horizon AS (
    SELECT DATE_TRUNC('month', MAX(order_date)) AS max_order_month
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT
    TO_CHAR(cs.cohort_month, 'YYYY-MM') AS cohort_group,
    cs.cohort_size,

    COUNT(DISTINCT a.customer_id)
        FILTER (WHERE a.months_elapsed = 1) AS month_1_retained,

    CASE
        WHEN cs.cohort_month + INTERVAL '1 month' <= dh.max_order_month
        THEN ROUND(
            COUNT(DISTINCT a.customer_id)
                FILTER (WHERE a.months_elapsed = 1) * 100.0 / cs.cohort_size,
            2
        )
    END AS month_1_retention_pct,

    COUNT(DISTINCT a.customer_id)
        FILTER (WHERE a.months_elapsed = 2) AS month_2_retained,

    CASE
        WHEN cs.cohort_month + INTERVAL '2 months' <= dh.max_order_month
        THEN ROUND(
            COUNT(DISTINCT a.customer_id)
                FILTER (WHERE a.months_elapsed = 2) * 100.0 / cs.cohort_size,
            2
        )
    END AS month_2_retention_pct

FROM cohort_size cs
CROSS JOIN data_horizon dh
LEFT JOIN activity a
  ON a.cohort_month = cs.cohort_month
GROUP BY cs.cohort_month, cs.cohort_size, dh.max_order_month
ORDER BY cs.cohort_month;

-- Q03: Customer Spend & Order Velocity
SELECT order_id, customer_id, order_date,
       ROUND(gross_amount - discount_applied, 2) AS net_order_amount,
       ROUND(SUM(gross_amount - discount_applied)
             OVER (PARTITION BY customer_id ORDER BY order_date, order_id), 2) AS cumulative_spend_to_date,
       order_date - LAG(order_date) OVER
             (PARTITION BY customer_id ORDER BY order_date, order_id) AS days_since_last_order
FROM orders
WHERE order_status = 'Delivered'
ORDER BY customer_id, order_date, order_id;

-- Q04: First-Touch Channel Revenue Attribution
WITH first_touch AS (
    SELECT customer_id, channel_source,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY touchpoint_rank, interaction_time, interaction_id
           ) AS touch_rank
    FROM marketing_attribution
),
customer_revenue AS (
    SELECT customer_id, SUM(gross_amount - discount_applied) AS net_revenue
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT ft.channel_source,
       COUNT(DISTINCT ft.customer_id) AS converted_customers,
       ROUND(SUM(cr.net_revenue), 2) AS total_attributed_revenue,
       ROUND(AVG(cr.net_revenue), 2) AS average_customer_revenue
FROM first_touch ft
JOIN customer_revenue cr ON cr.customer_id = ft.customer_id
WHERE ft.touch_rank = 1
GROUP BY ft.channel_source
ORDER BY total_attributed_revenue DESC;

-- Q05: Product Performance Ranking by Category
SELECT p.category, p.product_name,
       SUM(i.quantity) AS units_sold,
       ROUND(SUM(i.quantity * i.purchase_price), 2) AS total_sales_revenue,
       DENSE_RANK() OVER (
           PARTITION BY p.category
           ORDER BY SUM(i.quantity * i.purchase_price) DESC
       ) AS ranking_in_category
FROM order_items i
JOIN products p ON i.product_id = p.product_id
JOIN orders o ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category, p.product_name
ORDER BY p.category, ranking_in_category, p.product_name;

-- Q06: Average Order Value (AOV) Sizing Analysis
SELECT TO_CHAR(order_date, 'YYYY-MM') AS fiscal_month,
       COUNT(order_id) AS total_completed_orders,
       ROUND(SUM(gross_amount - discount_applied), 2) AS net_sales,
       ROUND(AVG(gross_amount - discount_applied), 2) AS dynamic_aov
FROM orders
WHERE order_status = 'Delivered'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY fiscal_month;

-- Q07: Repeat Purchase Frequency Profile
SELECT customer_id, COUNT(order_id) AS purchases,
       CASE WHEN COUNT(order_id) >= 3 THEN 'Power_User'
            WHEN COUNT(order_id) = 2 THEN 'Repeat_Buyer'
            ELSE 'Single_Buyer' END AS customer_tier
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY purchases DESC, customer_id;

-- Q08: Payment Failure & Risk Decline Analysis
SELECT p.payment_method,
       COUNT(*) AS total_attempts,
       COUNT(*) FILTER (WHERE p.gateway_status = 'Success') AS successful_attempts,
       COUNT(*) FILTER (WHERE p.gateway_status = 'Failed') AS failed_attempts,
       COUNT(*) FILTER (WHERE p.gateway_status = 'Risk_Decline') AS risk_declines,
       ROUND(COUNT(*) FILTER (WHERE p.gateway_status <> 'Success') * 100.0 /
             NULLIF(COUNT(*), 0), 2) AS non_success_rate_pct,
       ROUND(SUM(CASE WHEN p.gateway_status <> 'Success' THEN o.gross_amount ELSE 0 END), 2)
             AS attempted_non_success_order_value
FROM payment_ledger p
JOIN orders o ON p.order_id = o.order_id
GROUP BY p.payment_method
ORDER BY non_success_rate_pct DESC, p.payment_method;

-- Q09: Returned Product Exposure
SELECT p.product_name,
       COUNT(DISTINCT o.order_id) AS return_count,
       ROUND(SUM(i.quantity * i.purchase_price), 2) AS returned_line_item_value
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
WHERE o.order_status = 'Returned'
GROUP BY p.product_name
ORDER BY returned_line_item_value DESC;

-- Q10: Promotional Discount Impact Analysis
SELECT TO_CHAR(order_date, 'YYYY-MM') AS sales_period,
       ROUND(SUM(gross_amount), 2) AS gross_sales,
       ROUND(SUM(discount_applied), 2) AS total_discounts,
       ROUND(SUM(discount_applied) * 100.0 / NULLIF(SUM(gross_amount), 0), 2) AS discount_rate_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY sales_period;

-- Q11: Customer Recency Analysis
-- Change the as_of_date when running the analysis for a different reporting date.
WITH analysis_date AS (SELECT DATE '2026-04-01' AS as_of_date)
SELECT o.customer_id, MAX(o.order_date) AS final_purchase_date,
       a.as_of_date - MAX(o.order_date) AS days_since_active
FROM orders o
CROSS JOIN analysis_date a
WHERE o.order_status = 'Delivered'
GROUP BY o.customer_id, a.as_of_date
ORDER BY days_since_active DESC, o.customer_id;

-- Q12: Top Lifetime Value Customers
WITH customer_value AS (
    SELECT customer_id, SUM(gross_amount - discount_applied) AS net_lifetime_value
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT customer_id, ROUND(net_lifetime_value, 2) AS net_lifetime_value,
           DENSE_RANK() OVER (ORDER BY net_lifetime_value DESC) AS vip_rank
    FROM customer_value
)
SELECT customer_id, net_lifetime_value, vip_rank
FROM ranked_customers
WHERE vip_rank <= 3
ORDER BY vip_rank, customer_id;

-- Q13: Moving Average Customer Order Revenue Trends
SELECT order_id, customer_id, order_date,
       ROUND(gross_amount - discount_applied, 2) AS net_amount,
       ROUND(AVG(gross_amount - discount_applied) OVER (
           PARTITION BY customer_id
           ORDER BY order_date, order_id
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3_order_avg
FROM orders
WHERE order_status = 'Delivered'
ORDER BY customer_id, order_date, order_id;

-- Q14: Marketing Touchpoint Conversion Analysis
SELECT channel_source,
       COUNT(interaction_id) AS total_touchpoints,
       SUM(conversion_flag) AS conversions,
       ROUND(SUM(conversion_flag) * 100.0 /
             NULLIF(COUNT(interaction_id), 0), 2) AS conversion_rate_pct
FROM marketing_attribution
GROUP BY channel_source
ORDER BY conversion_rate_pct DESC, channel_source;

-- Q15: Cart Size & Average Basket Value Analysis
WITH item_counts AS (
    SELECT order_id, SUM(quantity) AS cart_items
    FROM order_items
    GROUP BY order_id
)
SELECT c.cart_items,
       COUNT(o.order_id) AS total_orders,
       ROUND(SUM(o.gross_amount - o.discount_applied), 2) AS net_sales,
       ROUND(AVG(o.gross_amount - o.discount_applied), 2) AS average_basket_value
FROM orders o
JOIN item_counts c ON o.order_id = c.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.cart_items
ORDER BY c.cart_items;

-- Q16: High-Value Revenue Segment Contribution Tracker
WITH segments AS (
    SELECT order_id, gross_amount,
           CASE WHEN gross_amount > 5000 THEN 'Premium_Ticket'
                ELSE 'Standard_Ticket' END AS order_tier
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT order_tier, COUNT(order_id) AS total_orders,
       ROUND(SUM(gross_amount), 2) AS total_sales,
       ROUND(SUM(gross_amount) * 100.0 /
             NULLIF((SELECT SUM(gross_amount) FROM orders WHERE order_status = 'Delivered'), 0), 2)
             AS portfolio_contribution_pct
FROM segments
GROUP BY order_tier
ORDER BY total_sales DESC;

-- Q17: Day-of-Week Sales Analysis
SELECT EXTRACT(DOW FROM order_date) AS day_index,
       TO_CHAR(order_date, 'FMDay') AS weekday_name,
       COUNT(order_id) AS transaction_count,
       ROUND(SUM(gross_amount - discount_applied), 2) AS net_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY EXTRACT(DOW FROM order_date), TO_CHAR(order_date, 'FMDay')
ORDER BY net_revenue DESC, day_index;

-- Q18: Payment Processing Cost Analysis
SELECT payment_method,
       COUNT(order_id) AS successful_charges,
       ROUND(SUM(processing_fee), 2) AS total_fees_paid,
       ROUND(AVG(processing_fee), 2) AS average_processing_fee
FROM payment_ledger
WHERE gateway_status = 'Success'
GROUP BY payment_method
ORDER BY total_fees_paid DESC, payment_method;

-- Q19: Historical Value of Churned Customers
SELECT c.customer_id, c.customer_email, c.acquisition_channel,
       ROUND(SUM(o.gross_amount - o.discount_applied), 2) AS historical_net_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.account_status = 'Churned'
  AND o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_email, c.acquisition_channel
HAVING SUM(o.gross_amount - o.discount_applied) > 3000
ORDER BY historical_net_revenue DESC;

-- Q20: Maximum Applied Promotional Discount
WITH max_discount AS (
    SELECT MAX(discount_applied) AS maximum_discount
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT o.order_id, o.customer_id, o.discount_applied
FROM orders o
CROSS JOIN max_discount m
WHERE o.order_status = 'Delivered'
  AND o.discount_applied = m.maximum_discount
ORDER BY o.order_id;

-- Q21: Sequential Revenue Variance Gap
WITH ordered_sales AS (
    SELECT order_id, customer_id, order_date, gross_amount,
           LAG(gross_amount) OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS previous_order_value
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT order_id, customer_id, order_date,
       ROUND(gross_amount, 2) AS gross_amount,
       ROUND(previous_order_value, 2) AS previous_order_value,
       ROUND(gross_amount - previous_order_value, 2) AS revenue_variance
FROM ordered_sales
ORDER BY customer_id, order_date, order_id;

-- Q22: Acquisition Channel Revenue Analysis
SELECT c.acquisition_channel,
       COUNT(DISTINCT c.customer_id) AS users_acquired,
       COUNT(DISTINCT o.customer_id) AS customers_with_delivered_orders,
       COUNT(o.order_id) AS completed_orders,
       ROUND(COALESCE(SUM(o.gross_amount - o.discount_applied), 0), 2) AS net_sales_volume
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
    AND o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY net_sales_volume DESC;

-- Q23: Category Fulfillment Volume Distribution
SELECT p.category,
       COUNT(DISTINCT l.order_id) AS orders_penetrated,
       SUM(l.quantity) AS total_units_shipped
FROM order_items l
JOIN products p ON l.product_id = p.product_id
JOIN orders o ON l.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY total_units_shipped DESC, p.category;

-- Q24: Order Status & Pipeline Value Analysis
SELECT order_status,
       COUNT(order_id) AS order_count,
       ROUND(SUM(gross_amount), 2) AS total_order_value
FROM orders
GROUP BY order_status
ORDER BY total_order_value DESC, order_status;

-- Q25: Signup-to-First-Purchase Velocity
WITH first_purchases AS (
    SELECT order_id, customer_id, order_date,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS order_sequence
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT c.customer_id, c.signup_date,
       f.order_date AS purchase_date,
       f.order_date - c.signup_date AS conversion_delay_days
FROM customers c
JOIN first_purchases f ON c.customer_id = f.customer_id
WHERE f.order_sequence = 1
ORDER BY conversion_delay_days, c.customer_id;

-- ======================================
-- END OF BUSINESS ANALYTICS QUERY SUITE
-- ======================================
