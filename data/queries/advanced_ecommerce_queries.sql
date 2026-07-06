-- ==============================================================================
-- ADVANCED SQL PORTFOLIO: BUSINESS ANALYTICS QUERY SUITE
-- ==============================================================================

-- Q01: Monthly Sales Trend & Growth Rate
-- Calculates net revenue growth month-over-month to identify performance velocity.
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(gross_amount - discount_applied) AS net_sales
    FROM orders 
    WHERE order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    TO_CHAR(sales_month, 'YYYY-MM') AS calendar_month,
    net_sales,
    ROUND(LAG(net_sales, 1) OVER (ORDER BY sales_month), 2) AS previous_month_sales,
    ROUND(((net_sales - LAG(net_sales, 1) OVER (ORDER BY sales_month)) * 100.0) / 
          NULLIF(LAG(net_sales, 1) OVER (ORDER BY sales_month), 0), 2) AS mom_growth_pct
FROM monthly_revenue;

	-- Q02: Cohort Retention Analysis
	-- Identifies the percentage of acquired customers who make repeat purchases over time.
	WITH cohort_baseline AS (
		SELECT customer_id, DATE_TRUNC('month', signup_date) AS cohort_month FROM customers
	),
	activity_delta AS (
		SELECT 
			o.customer_id, c.cohort_month,
			EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', o.order_date), c.cohort_month)) * 12 +
			EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.order_date), c.cohort_month)) AS months_elapsed
		FROM orders o 
		JOIN cohort_baseline c ON o.customer_id = c.customer_id
		WHERE o.order_status = 'Delivered'
	)
	SELECT 
		TO_CHAR(cohort_month, 'YYYY-MM') AS cohort_group,
		COUNT(DISTINCT customer_id) AS cohort_size,
		COUNT(DISTINCT CASE WHEN months_elapsed = 1 THEN customer_id END) AS month_1_retained,
		COUNT(DISTINCT CASE WHEN months_elapsed = 2 THEN customer_id END) AS month_2_retained
	FROM activity_delta 
	GROUP BY cohort_month 
	ORDER BY cohort_month;

-- Q03: Customer Lifetime Value (CLV) & Velocity Tracking
-- Computes the running total spend per user and tracks days between consecutive orders.
SELECT 
    order_id, customer_id, order_date, gross_amount,
    SUM(gross_amount) OVER(PARTITION BY customer_id ORDER BY order_date) AS cumulative_spend_to_date,
    COALESCE(order_date - LAG(order_date, 1) OVER(PARTITION BY customer_id ORDER BY order_date), 0) AS days_since_last_order
FROM orders 
WHERE order_status = 'Delivered';

-- Q04: First-Touch Channel Value Conversion
-- Measures total net revenue and average order value (AOV) driven by marketing channels.
SELECT 
    m.channel_source,
    COUNT(DISTINCT m.customer_id) AS conversions,
    ROUND(SUM(o.gross_amount - o.discount_applied), 2) AS total_attributed_revenue,
    ROUND(AVG(o.gross_amount - o.discount_applied), 2) AS average_order_value
FROM marketing_attribution m 
JOIN orders o ON m.customer_id = o.customer_id
WHERE m.conversion_flag = 1 AND o.order_status = 'Delivered'
GROUP BY m.channel_source 
ORDER BY total_attributed_revenue DESC;	

-- Q05: Category Performance Pareto Matrix
-- Ranks and counts top-performing products within each merchandise category.
SELECT 
    p.category, p.product_name, SUM(i.quantity) AS units_sold,
    ROUND(SUM(i.quantity * i.purchase_price), 2) AS total_sales_revenue,
    DENSE_RANK() OVER(PARTITION BY p.category ORDER BY SUM(i.quantity * i.purchase_price) DESC) AS ranking_in_category
FROM order_items i 
JOIN products p ON i.product_id	 = p.product_id
JOIN orders o ON i.order_id = o.order_id 
WHERE o.order_status = 'Delivered'
GROUP BY p.category, p.product_name;

-- Q06: Average Order Value (AOV) Sizing Analysis
-- Tracks the average transaction metric per month across completed orders.
SELECT 
    TO_CHAR(order_date, 'YYYY-MM') AS fiscal_month, 
    COUNT(order_id) AS total_completed_orders,
    ROUND(SUM(gross_amount - discount_applied), 2) AS net_sales,
    ROUND(AVG(gross_amount - discount_applied), 2) AS dynamic_aov
FROM orders 
WHERE order_status = 'Delivered' 
GROUP BY TO_CHAR(order_date, 'YYYY-MM');

-- Q07: Repeat Purchase Frequency Profile
-- Groups and categorizes customers based on transaction volume counts.
SELECT 
    customer_id, COUNT(order_id) AS purchases,
    CASE WHEN COUNT(order_id) >= 3 THEN 'Power_User' WHEN COUNT(order_id) = 2 THEN 'Repeat_Buyer' ELSE 'Single_Buyer' END AS customer_tier
FROM orders 
WHERE order_status = 'Delivered' 
GROUP BY customer_id;

-- Q08: Payment Gateway Failure & Leakage Analysis
-- Identifies transactional drop-off and lost transaction values across payment methods.
SELECT 
    p.payment_method, COUNT(p.order_id) AS total_attempts,
    ROUND(SUM(CASE WHEN p.gateway_status = 'Failed' THEN o.gross_amount ELSE 0 END), 2) AS revenue_failed,
    ROUND((SUM(CASE WHEN p.gateway_status = 'Failed' THEN 1 ELSE 0 END) * 100.0) / COUNT(p.order_id), 2) AS failure_rate_pct
FROM payment_ledger p 
JOIN orders o ON p.order_id = o.order_id
GROUP BY p.payment_method;

-- Q09: High-Exposure Returns Isolation
-- Identifies the specific products generating the highest count of processing return claims.
SELECT 
    p.product_name, COUNT(o.order_id) AS return_count,
    ROUND(SUM(o.gross_amount), 2) AS total_returned_value
FROM orders o 
JOIN order_items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
WHERE o.order_status = 'Returned' 
GROUP BY p.product_name;

-- Q10: Promo Discount Impact & Margin Erosion Check
-- Tracks promotional discount write-offs against gross sales metrics to analyze margins.
SELECT 
    TO_CHAR(order_date, 'YYYY-MM') AS sales_period, 
    SUM(gross_amount) AS gross_sales,
    SUM(discount_applied) AS total_discounts,
    ROUND((SUM(discount_applied) * 100.0) / SUM(gross_amount), 2) AS erosion_pct
FROM orders 
WHERE order_status = 'Delivered' 
GROUP BY TO_CHAR(order_date, 'YYYY-MM');

-- Q11: RFM Recency Elapsed Calculations
-- Measures exactly how many days have elapsed since a customer's final active order.
SELECT 
    customer_id, MAX(order_date) AS final_purchase_date,
    CAST('2026-04-01' AS DATE) - MAX(order_date) AS days_since_active
FROM orders 
WHERE order_status = 'Delivered' 
GROUP BY customer_id;

-- Q12: Top Lifetime Value VIP Customers
-- Isolates our top three highest revenue-contributing customer profiles.
SELECT 
    customer_id, ROUND(SUM(gross_amount - discount_applied), 2) AS net_lifetime_value,
    ROW_NUMBER() OVER (ORDER BY SUM(gross_amount - discount_applied) DESC) AS vip_rank
FROM orders 
WHERE order_status = 'Delivered'
GROUP BY customer_id 
LIMIT 3;

-- ==============================================================================
-- BUSINESS REPORTING SUITE (PART 2: QUERIES 13-25)
-- ==============================================================================

-- Q13: Moving Average Customer Order Revenue Trends
-- Calculates the 3-order rolling average spend to smooth out variations in lifetime purchase cycles.
SELECT 
    order_id, customer_id, order_date,
    gross_amount - discount_applied AS net_amount,
    ROUND(AVG(gross_amount - discount_applied) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3_order_avg
FROM orders WHERE order_status = 'Delivered';

-- Q14: Marketing Medium Pipeline Conversion Drop-offs
-- Calculates conversion and leakage rates across active customer interaction loops.
SELECT 
    channel_source,
    COUNT(interaction_id) AS total_clicks,
    SUM(conversion_flag) AS conversions,
    ROUND((SUM(CASE WHEN conversion_flag = 0 THEN 1 ELSE 0 END) * 100.0) / 
          NULLIF(COUNT(interaction_id), 0), 2) AS drop_off_pct
FROM marketing_attribution GROUP BY channel_source;

-- Q15: Cart Quantity Sizing Impact Matrix
-- Evaluates if multi-item checkouts result in statistically higher transactional basket sizes.
WITH item_counts AS (
    SELECT order_id, SUM(quantity) AS cart_items 
    FROM order_items GROUP BY order_id
)
SELECT 
    c.cart_items, COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.gross_amount), 2) AS gross_sales,
    ROUND(AVG(o.gross_amount), 2) AS average_basket_value
FROM orders o JOIN item_counts c ON o.order_id = c.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.cart_items ORDER BY c.cart_items;

-- Q16: High-Value Revenue Segment Contribution Tracker
-- Measures portfolio revenue dependency on high-value orders above the ₹5,000 threshold.
WITH segments AS (
    SELECT order_id, gross_amount,
        CASE WHEN gross_amount > 5000.00 THEN 'Premium_Ticket' ELSE 'Standard_Ticket' END AS order_tier
    FROM orders WHERE order_status = 'Delivered'
)
SELECT order_tier, COUNT(order_id) AS total_orders, ROUND(SUM(gross_amount), 2) AS total_sales,
    ROUND((SUM(gross_amount) * 100.0) / (SELECT SUM(gross_amount) FROM orders WHERE order_status = 'Delivered'), 2) AS portfolio_contribution_pct
FROM segments GROUP BY order_tier;

-- Q17: Days-of-Week Sales Concentration Mapping
-- Uncovers seasonal conversion spikes across standard operational calendar weeks.
SELECT 
    EXTRACT(DOW FROM order_date) AS day_index,
    TO_CHAR(order_date, 'Day') AS weekday_name,
    COUNT(order_id) AS transaction_count,
    ROUND(SUM(gross_amount - discount_applied), 2) AS net_revenue
FROM orders WHERE order_status = 'Delivered'
GROUP BY EXTRACT(DOW FROM order_date), TO_CHAR(order_date, 'Day') ORDER BY net_revenue DESC;

-- Q18: Gateway Acquiring Cost Revenue Leakage Log
-- Audits merchant processing transactional fees drained through clearing aggregators.
SELECT 
    payment_method,
    COUNT(order_id) AS successful_charges,
    ROUND(SUM(processing_fee), 2) AS total_fees_paid,
    ROUND(AVG(processing_fee), 2) AS average_processing_fee
FROM payment_ledger WHERE gateway_status = 'Success' GROUP BY payment_method;

-- Q19: High-Value Churn Risk Mitigation Log
-- Highlights customers marked as churned who still hold an elite historical lifetime value.
SELECT 
    c.customer_id, c.customer_email, c.acquisition_channel,
    ROUND(SUM(o.gross_amount - o.discount_applied), 2) AS lost_lifetime_value
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
WHERE c.account_status = 'Churned' AND o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_email, c.acquisition_channel HAVING SUM(o.gross_amount) > 3000.00;

-- Q20: Max Applied Promotional Order Record
-- Flags the maximum single coupon write-off allowed on a successfully processed order.
SELECT order_id, customer_id, discount_applied 
FROM orders WHERE discount_applied = (SELECT MAX(discount_applied) FROM orders WHERE order_status = 'Delivered');

-- Q21: Sequential Revenue Variance Gap
-- Tracks the variance gap between a customer's current order value and their previous order values.
SELECT 
    order_id, customer_id, order_date, gross_amount,
    ROUND(MAX(gross_amount) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 2) AS previous_peak,
    ROUND(gross_amount - COALESCE(MAX(gross_amount) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), gross_amount), 2) AS revenue_variance
FROM orders WHERE order_status = 'Delivered';

-- Q22: Acquisition Channel Marketing Efficiency
-- Measures lifetime revenue volume generation across intake networks.
SELECT 
    c.acquisition_channel, COUNT(DISTINCT c.customer_id) AS users_acquired,
    COUNT(o.order_id) AS completed_orders,
    ROUND(SUM(o.gross_amount - o.discount_applied), 2) AS net_sales_volume
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered' GROUP BY c.acquisition_channel;

-- Q23: Category Fulfillment Volume Distribution
-- Tracks individual item line quantities shipped across product segments.
SELECT 
    p.category, COUNT(DISTINCT l.order_id) AS orders_penetrated,
    SUM(l.quantity) AS total_units_shipped
FROM order_items l JOIN products p ON l.product_id = p.product_id
GROUP BY p.category ORDER BY total_units_shipped DESC;

-- Q24: Stagnant Pipeline Value Identification
-- Quantifies operational liquidity locked within active 'Processing' pipelines.
SELECT 
    order_status, COUNT(order_id) AS pipeline_count,
    ROUND(SUM(gross_amount), 2) AS total_stagnant_value
FROM orders GROUP BY order_status;

-- Q25: Signup-to-First-Purchase Velocity Speed
-- Calculates the interval in days between a customer profile creation date and their first purchase.
WITH first_purchases AS (
    SELECT order_id, customer_id, order_date,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS order_sequence
    FROM orders WHERE order_status = 'Delivered'
)
SELECT 
    c.customer_id, c.signup_date, f.order_date AS purchase_date,
    (f.order_date - c.signup_date) AS conversion_delay_days
FROM customers c JOIN first_purchases f ON c.customer_id = f.customer_id
WHERE f.order_sequence = 1;

-- ==============================================================================
-- END OF BUSINESS ANALYTICS QUERY SUITE
-- ==============================================================================
