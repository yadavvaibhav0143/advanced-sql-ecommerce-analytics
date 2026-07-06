-- ==============================================================================
-- ADVANCED SQL PORTFOLIO: E-COMMERCE ANALYTICS ENGINE
-- DATA LAYER: SAMPLE DATA (DML)
-- ==============================================================================

-- Seed Customers Dataset
INSERT INTO customers VALUES 
(101, 'amit.sharma@gmail.com', '2026-01-10', 'Meta_Ads', 'Active'),
(102, 'priya.patil@yahoo.com', '2026-01-15', 'Google_SEO', 'Active'),
(103, 'rohit.joshi@outlook.com', '2026-02-01', 'Direct_Traffic', 'Active'),
(104, 'sneha.kulkarni@gmail.com', '2026-02-12', 'Meta_Ads', 'Churned'),
(105, 'vikram.singh@hotmail.com', '2026-03-01', 'Affiliate', 'Active'),
(106, 'ananya.deshmukh@gmail.com', '2026-01-20', 'Google_SEO', 'Active'),
(107, 'rahul.nair@yahoo.com', '2026-02-15', 'Meta_Ads', 'Active'),
(108, 'pooja.rao@gmail.com', '2026-03-10', 'Direct_Traffic', 'Active');

-- Seed Products Dataset
INSERT INTO products VALUES
(2001, 'Wireless Noise-Cancelling Earbuds X1', 'Electronics', 4500.00, 150),
(2002, 'Performance Breathable Running Shoes', 'Fitness_Gear', 3200.00, 80),
(2003, 'Premium Cotton Slim-Fit Blazer', 'Apparel', 5500.00, 45),
(2004, 'Smart Ergonomic Induction Cooktop', 'Home_Appliances', 8900.00, 30);

-- Seed Orders Dataset
INSERT INTO orders VALUES 
(4001, 101, '2026-01-11', 4500.00, 200.00, 'Delivered'),
(4002, 101, '2026-02-14', 9000.00, 0.00, 'Delivered'),
(4003, 101, '2026-03-20', 3200.00, 50.00, 'Delivered'),
(4004, 102, '2026-01-16', 8900.00, 500.00, 'Delivered'),
(4005, 102, '2026-03-05', 4500.00, 0.00, 'Delivered'),
(4006, 103, '2026-02-02', 3200.00, 0.00, 'Delivered'),
(4007, 104, '2026-02-13', 5500.00, 600.00, 'Returned'),
(4008, 105, '2026-03-02', 13400.00, 400.00, 'Delivered'),
(4009, 106, '2026-01-22', 4500.00, 0.00, 'Delivered'),
(4010, 106, '2026-02-25', 5500.00, 100.00, 'Delivered'),
(4011, 107, '2026-02-18', 8900.00, 0.00, 'Delivered'),
(4012, 107, '2026-03-22', 3200.00, 0.00, 'Cancelled'),
(4013, 108, '2026-03-12', 13400.00, 500.00, 'Delivered');

-- Seed Order Line-Items Dataset
INSERT INTO order_items VALUES
(1, 4001, 2001, 1, 4500.00),
(2, 4002, 2001, 2, 4500.00),
(3, 4003, 2002, 1, 3200.00),
(4, 4004, 2004, 1, 8900.00),
(5, 4005, 2001, 1, 4500.00),
(6, 4006, 2002, 1, 3200.00),
(7, 4007, 2003, 1, 5500.00),
(8, 4008, 2001, 1, 4500.00),
(9, 4008, 2004, 1, 8900.00),
(10, 4009, 2001, 1, 4500.00),
(11, 4010, 2003, 1, 5500.00),
(12, 4011, 2004, 1, 8900.00),
(13, 4012, 2002, 1, 3200.00),
(14, 4013, 2001, 1, 4500.00),
(15, 4013, 2004, 1, 8900.00);

-- Seed Payments Dataset
INSERT INTO payment_ledger VALUES
('PAY-1001A', 4001, 'UPI_GPay', 'Success', 10.00),
('PAY-1002B', 4002, 'Credit_Card', 'Success', 180.00),
('PAY-1003C', 4003, 'UPI_GPay', 'Success', 10.00),
('PAY-1004D', 4004, 'Net_Banking', 'Success', 45.00),
('PAY-1005E', 4005, 'Credit_Card', 'Success', 90.00),
('PAY-1006F', 4006, 'COD', 'Success', 0.00),
('PAY-1007G', 4007, 'UPI_GPay', 'Failed', 0.00),
('PAY-1008H', 4008, 'Credit_Card', 'Success', 268.00),
('PAY-1009I', 4009, 'UPI_GPay', 'Success', 10.00),
('PAY-1010J', 4010, 'Credit_Card', 'Success', 110.00),
('PAY-1011K', 4011, 'Net_Banking', 'Success', 45.00),
('PAY-1012L', 4012, 'UPI_GPay', 'Risk_Decline', 0.00),
('PAY-1013M', 4013, 'Credit_Card', 'Success', 268.00);

-- Seed Marketing Attribution Dataset
INSERT INTO marketing_attribution VALUES
(70001, 101, '2026-01-10 08:30:00', 'Meta_Paid_Ad', 1, 0),
(70002, 101, '2026-01-11 10:15:00', 'Google_Brand_Search', 2, 1),
(70003, 102, '2026-01-15 14:00:00', 'Google_Organic_Link', 1, 1),
(70004, 104, '2026-02-12 19:22:00', 'Instagram_Influencer_Post', 1, 0),
(70005, 104, '2026-02-13 11:05:00', 'Meta_Retargeting_Ad', 2, 1),
(70006, 106, '2026-01-20 15:40:00', 'Google_SEO_Link', 1, 1),
(70007, 107, '2026-02-15 11:20:00', 'Meta_Paid_Ad', 1, 1);

-- ==============================================================================
-- END OF SAMPLE DATA
-- ==============================================================================
