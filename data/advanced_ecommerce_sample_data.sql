-- ==============================================================================
-- ADVANCED SQL PORTFOLIO: E-COMMERCE ANALYTICS ENGINE
-- DATA LAYER: SAMPLE DATA (DML)
-- ==============================================================================

-- Seed Customers Dataset
INSERT INTO customers VALUES 
(101, 'customer101@example.com', '2026-01-10', 'Meta_Ads', 'Active'),
(102, 'customer102@example.com', '2026-01-15', 'Google_SEO', 'Active'),
(103, 'customer103@example.com', '2026-02-01', 'Direct_Traffic', 'Active'),
(104, 'customer104@example.com', '2026-02-12', 'Meta_Ads', 'Churned'),
(105, 'customer105@example.com', '2026-03-01', 'Affiliate', 'Active'),
(106, 'customer106@example.com', '2026-01-20', 'Google_SEO', 'Active'),
(107, 'customer107@example.com', '2026-02-15', 'Meta_Ads', 'Active'),
(108, 'customer108@example.com', '2026-03-10', 'Direct_Traffic', 'Active');

-- Seed Products Dataset
INSERT INTO products VALUES
(2001, 'Wireless Noise-Cancelling Earbuds X1', 'Electronics', 4500.00, 150),
(2002, 'Performance Breathable Running Shoes', 'Fitness_Gear', 3200.00, 80),
(2003, 'Premium Cotton Slim-Fit Blazer', 'Apparel', 5500.00, 45),
(2004, 'Smart Ergonomic Induction Cooktop', 'Home_Appliances', 8900.00, 30),
(2005, 'Smart Fitness Watch Pro', 'Electronics', 6500.00, 100),
(2006, 'Adjustable Resistance Training Kit', 'Fitness_Gear', 2800.00, 70),
(2007, 'Lightweight Performance Jacket', 'Apparel', 4800.00, 60),
(2008, 'Compact Air Fryer Pro', 'Home_Appliances', 7200.00, 40);

-- Seed Orders Dataset
INSERT INTO orders VALUES 
(4001, 101, '2026-01-11', 4500.00, 200.00, 'Delivered'),
(4002, 101, '2026-02-14', 9000.00, 0.00, 'Delivered'),
(4003, 101, '2026-03-20', 3200.00, 50.00, 'Delivered'),
(4004, 102, '2026-01-16', 8900.00, 500.00, 'Delivered'),
(4005, 102, '2026-03-05', 4500.00, 0.00, 'Delivered'),
(4006, 103, '2026-02-02', 3200.00, 0.00, 'Delivered'),
(4007, 104, '2026-02-20', 5500.00, 600.00, 'Returned'),
(4008, 105, '2026-03-02', 13400.00, 400.00, 'Delivered'),
(4009, 106, '2026-01-22', 4500.00, 0.00, 'Delivered'),
(4010, 106, '2026-02-25', 5500.00, 100.00, 'Delivered'),
(4011, 107, '2026-02-18', 8900.00, 0.00, 'Delivered'),
(4012, 107, '2026-03-22', 3200.00, 0.00, 'Cancelled'),
(4013, 108, '2026-03-12', 13400.00, 500.00, 'Delivered'),
(4014, 104, '2026-02-13', 5600.00, 200.00, 'Delivered'),
(4015, 103, '2026-03-04', 6500.00, 300.00, 'Delivered'),
(4016, 105, '2026-03-18', 9300.00, 300.00, 'Delivered'),
(4017, 108, '2026-03-20', 7200.00, 200.00, 'Processing'),
(4018, 102, '2026-03-26', 8300.00, 300.00, 'Processing'),
(4019, 106, '2026-03-29', 12000.00, 500.00, 'Returned'),
(4020, 108, '2026-03-30', 6500.00, 200.00, 'Cancelled');


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
(15, 4013, 2004, 1, 8900.00),
(16, 4014, 2006, 2, 2800.00),
(17, 4015, 2005, 1, 6500.00),
(18, 4016, 2005, 1, 6500.00),
(19, 4016, 2006, 1, 2800.00),
(20, 4017, 2008, 1, 7200.00),
(21, 4018, 2006, 1, 2800.00),
(22, 4018, 2003, 1, 5500.00),
(23, 4019, 2007, 1, 4800.00),
(24, 4019, 2008, 1, 7200.00),
(25, 4020, 2005, 1, 6500.00);

  
-- Seed Payments Dataset
INSERT INTO payment_ledger VALUES
('PAY-1001A', 4001, 'UPI_GPay', 'Success', 10.00),
('PAY-1002B', 4002, 'Credit_Card', 'Success', 180.00),
('PAY-1003C', 4003, 'UPI_GPay', 'Success', 10.00),
('PAY-1004D', 4004, 'Net_Banking', 'Success', 45.00),
('PAY-1005E', 4005, 'Credit_Card', 'Success', 90.00),
('PAY-1006F', 4006, 'COD', 'Success', 0.00),
('PAY-1007G', 4007, 'UPI_GPay', 'Success', 11.00),
('PAY-1008H', 4008, 'Credit_Card', 'Success', 268.00),
('PAY-1009I', 4009, 'UPI_GPay', 'Success', 10.00),
('PAY-1010J', 4010, 'Credit_Card', 'Success', 110.00),
('PAY-1011K', 4011, 'Net_Banking', 'Success', 45.00),
('PAY-1012L', 4012, 'UPI_GPay', 'Risk_Decline', 0.00),
('PAY-1013M', 4013, 'Credit_Card', 'Success', 268.00),
('PAY-1014N', 4014, 'COD', 'Success', 0.00),
('PAY-1015O', 4015, 'UPI_GPay', 'Success', 15.00),
('PAY-1016P', 4016, 'Credit_Card', 'Success', 186.00),
('PAY-1017Q', 4017, 'UPI_GPay', 'Success', 14.00),
('PAY-1018R', 4018, 'Credit_Card', 'Success', 166.00),
('PAY-1019S', 4019, 'Net_Banking', 'Success', 35.00),
('PAY-1020T', 4020, 'UPI_GPay', 'Failed', 0.00);

-- Seed Marketing Attribution Dataset
INSERT INTO marketing_attribution VALUES
(70001, 101, '2026-01-10 08:30:00', 'Meta_Paid_Ad', 1, 0),
(70002, 101, '2026-01-11 10:15:00', 'Google_Brand_Search', 2, 1),
(70003, 102, '2026-01-15 14:00:00', 'Google_Organic_Link', 1, 1),
(70004, 104, '2026-02-12 19:22:00', 'Instagram_Influencer_Post', 1, 0),
(70005, 104, '2026-02-13 11:05:00', 'Meta_Retargeting_Ad', 2, 1),
(70006, 106, '2026-01-20 15:40:00', 'Google_SEO_Link', 1, 1),
(70007, 107, '2026-02-15 11:20:00', 'Meta_Paid_Ad', 1, 1),
(70008, 103, '2026-02-01 09:00:00', 'Direct_Website_Visit', 1, 0),
(70009, 103, '2026-02-02 08:45:00', 'Google_Brand_Search', 2, 1),
(70010, 105, '2026-03-01 12:00:00', 'Affiliate_Partner_Link', 1, 0),
(70011, 105, '2026-03-02 09:15:00', 'Meta_Retargeting_Ad', 2, 1);

-- ==============================================================================
-- END OF SAMPLE DATA
-- ==============================================================================
