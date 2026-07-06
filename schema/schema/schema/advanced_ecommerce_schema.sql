-- ==============================================================================
-- ADVANCED SQL PORTFOLIO: E-COMMERCE ANALYTICS ENGINE
-- DATABASE LAYER: RELATIONAL SCHEMA (DDL)
-- DATABASE: PostgreSQL
-- ==============================================================================

DROP TABLE IF EXISTS marketing_attribution;
DROP TABLE IF EXISTS payment_ledger;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 1. Customers Master Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_email VARCHAR(100) NOT NULL UNIQUE,
    signup_date DATE NOT NULL,
    acquisition_channel VARCHAR(30) NOT NULL 
        CHECK (acquisition_channel IN ('Google_SEO', 'Meta_Ads', 'Direct_Traffic', 'Affiliate')),
    account_status VARCHAR(20) DEFAULT 'Active' 
        CHECK (account_status IN ('Active', 'Churned', 'Suspended'))
);

-- 2. Products Master Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL 
        CHECK (category IN ('Electronics', 'Apparel', 'Home_Appliances', 'Fitness_Gear')),
    unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price > 0),
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0)
);

-- 3. Orders Transaction Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    gross_amount DECIMAL(12,2) NOT NULL CHECK (gross_amount > 0),
    discount_applied DECIMAL(10,2) DEFAULT 0.00 CHECK (discount_applied >= 0),
    order_status VARCHAR(20) NOT NULL 
        CHECK (order_status IN ('Delivered', 'Returned', 'Cancelled', 'Processing')),
    
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- 4. Order Line-Items Table
CREATE TABLE order_items (
    line_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    purchase_price DECIMAL(12,2) NOT NULL CHECK (purchase_price > 0),
    
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 5. Payments Transaction Table
CREATE TABLE payment_ledger (
    payment_id VARCHAR(50) PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(30) NOT NULL 
        CHECK (payment_method IN ('UPI_GPay', 'Credit_Card', 'Net_Banking', 'COD')),
    gateway_status VARCHAR(20) NOT NULL 
        CHECK (gateway_status IN ('Success', 'Failed', 'Risk_Decline')),
    processing_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

-- 6. Marketing Interactions Log
CREATE TABLE marketing_attribution (
    interaction_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    interaction_time TIMESTAMP NOT NULL,
    channel_source VARCHAR(50) NOT NULL,
    touchpoint_rank INT NOT NULL CHECK (touchpoint_rank > 0),
    conversion_flag INT NOT NULL CHECK (conversion_flag IN (0, 1)),
    
    CONSTRAINT fk_attribution_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- ==============================================================================
-- END OF DATABASE SCHEMA
-- ==============================================================================

