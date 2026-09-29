# Advanced PostgreSQL E-Commerce Analytics Engine

A business-oriented PostgreSQL analytics project that models an e-commerce transaction environment and uses 25 analytical queries to investigate revenue performance, customer behavior, retention, marketing attribution, product performance, payment risk, and order operations.

---

## Project Overview

This project simulates a small direct-to-consumer (D2C) e-commerce business with interconnected customer, product, order, payment, and marketing data.

The project was built to demonstrate how raw transactional data can be transformed into business-focused analysis using PostgreSQL, supported by Excel analysis and a Tableau dashboard.

Rather than focusing only on SQL syntax, the project focuses on translating business questions into analytical logic, handling edge cases, and producing metrics that can support commercial, marketing, customer, and operational decisions.

---

## Business Context

An e-commerce business needs to understand more than total sales.

Typical business questions include:

- How is revenue changing month over month?
- Which customer cohorts continue to purchase?
- Which customers generate the highest historical revenue?
- Which marketing touchpoints are associated with delivered revenue?
- Which products and categories contribute most to sales?
- Where are payment failures and risk declines occurring?
- How much business value is associated with returned orders?
- What is the current order pipeline by status?
- How quickly do newly acquired customers make their first purchase?
- How frequently do customers return to purchase?

This project converts these questions into a structured PostgreSQL analytics layer.

---

## Repository

- [PostgreSQL Schema](./schema/schema/schema/advanced_ecommerce_schema.sql)
- [Excel Dataset](./advanced_ecommerce_analytics_dataset.xlsx..xlsx)
- [Tableau Dashboard](./Dashboard.png)
- [Query Result 1](./Query.result-1.png)
- [Query Result 2](./Query.result-2.png)
- [Data & SQL Files](./data/)

---

## What I Built

The project consists of four connected layers:

**Relational Data Model → PostgreSQL Analytics → Excel Supporting Analysis → Tableau Dashboard**

### 1. Relational Data Model

Designed a six-table relational schema covering:

- Customers
- Products
- Orders
- Order Items
- Payment Ledger
- Marketing Attribution

The model uses primary keys, foreign keys, constraints, and controlled status/channel values to maintain data consistency.

### 2. Synthetic Business Dataset

Created an illustrative dataset containing:

- 8 customers
- 8 products
- 20 orders
- 25 order line items
- 20 payment records
- 11 marketing touchpoint records

The dataset intentionally contains different business scenarios including delivered, returned, processing, and cancelled orders, as well as successful payments, failures, and risk declines.

### 3. PostgreSQL Analytics Suite

Developed and validated **25 business-focused analytical queries** covering revenue, customer behavior, marketing, product performance, payments, and operational analysis.

### 4. Reporting Layer

Used Excel as a supporting analysis/data layer and Tableau to create a dashboard covering revenue, customer, acquisition, and product-category performance.

---

## Data Model

| Table | Purpose |
|---|---|
| `customers` | Customer profile, signup date, acquisition channel, and account status |
| `products` | Product catalogue, category, pricing, and stock information |
| `orders` | Order-level transactions, status, gross amount, and discounts |
| `order_items` | Product-level quantity and purchase-price details for each order |
| `payment_ledger` | Payment attempts, gateway outcomes, and processing fees |
| `marketing_attribution` | Customer marketing touchpoints, source, sequence, and conversion information |

### Key Relationships

```text
customers
    │
    ├── orders
    │      │
    │      ├── order_items ─── products
    │      │
    │      └── payment_ledger
    │
    └── marketing_attribution
