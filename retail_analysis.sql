-- ============================================================
-- Retail Sales & Inventory Analysis
-- Author: Oguz Tuncel
-- Description: SQL scripts for analysing sales performance,
--              inventory management, supplier KPIs, and
--              product category trends
-- ============================================================

-- ============================================================
-- 1. DATABASE SETUP
-- ============================================================

CREATE TABLE IF NOT EXISTS products (
    product_id      VARCHAR(10) PRIMARY KEY,
    product_name    VARCHAR(100),
    category        VARCHAR(50),
    supplier_id     VARCHAR(10),
    cost_price      DECIMAL(10,2),
    sell_price      DECIMAL(10,2),
    margin_pct      DECIMAL(5,1),
    reorder_point   INT,
    reorder_qty     INT
);

CREATE TABLE IF NOT EXISTS stores (
    store_id        VARCHAR(10) PRIMARY KEY,
    store_name      VARCHAR(100),
    city            VARCHAR(50),
    country         VARCHAR(50),
    store_type      VARCHAR(20),
    size_sqm        INT
);

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id         VARCHAR(10) PRIMARY KEY,
    supplier_name       VARCHAR(100),
    country             VARCHAR(50),
    lead_time_days      INT,
    reliability_score   INT
);

CREATE TABLE IF NOT EXISTS sales (
    sale_id         VARCHAR(10) PRIMARY KEY,
    product_id      VARCHAR(10) REFERENCES products(product_id),
    store_id        VARCHAR(10) REFERENCES stores(store_id),
    sale_date       DATE,
    quantity        INT,
    unit_price      DECIMAL(10,2),
    discount_pct    DECIMAL(5,1),
    revenue         DECIMAL(12,2),
    cost            DECIMAL(12,2),
    profit          DECIMAL(12,2),
    month           VARCHAR(15),
    quarter         VARCHAR(5),
    year            INT,
    season          VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS inventory (
    product_id      VARCHAR(10) REFERENCES products(product_id),
    store_id        VARCHAR(10) REFERENCES stores(store_id),
    current_stock   INT,
    units_sold      INT,
    reorder_point   INT,
    below_reorder   SMALLINT,
    days_of_stock   DECIMAL(10,1)
);

CREATE TABLE IF NOT EXISTS purchase_orders (
    order_id        VARCHAR(10) PRIMARY KEY,
    product_id      VARCHAR(10) REFERENCES products(product_id),
    supplier_id     VARCHAR(10) REFERENCES suppliers(supplier_id),
    order_date      DATE,
    expected_date   DATE,
    actual_date     DATE,
    quantity        INT,
    unit_cost       DECIMAL(10,2),
    total_cost      DECIMAL(12,2),
    delay_days      INT,
    on_time         SMALLINT
);

-- ============================================================
-- 2. SALES KPI OVERVIEW
-- ============================================================

SELECT
    COUNT(sale_id)                          AS total_transactions,
    SUM(quantity)                           AS total_units_sold,
    ROUND(SUM(revenue), 2)                  AS total_revenue,
    ROUND(SUM(profit), 2)                   AS total_profit,
    ROUND(AVG(revenue), 2)                  AS avg_order_value,
    ROUND(SUM(profit)/SUM(revenue)*100, 1)  AS overall_margin_pct
FROM sales;

-- ============================================================
-- 3. REVENUE BY CATEGORY
-- ============================================================

SELECT
    p.category,
    COUNT(s.sale_id)                            AS transactions,
    SUM(s.quantity)                             AS units_sold,
    ROUND(SUM(s.revenue), 2)                    AS total_revenue,
    ROUND(SUM(s.profit), 2)                     AS total_profit,
    ROUND(SUM(s.profit)/SUM(s.revenue)*100, 1)  AS margin_pct,
    ROUND(SUM(s.revenue)*100.0/
          SUM(SUM(s.revenue)) OVER(), 1)        AS pct_of_total
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- ============================================================
-- 4. STORE PERFORMANCE
-- ============================================================

SELECT
    st.store_name,
    st.city,
    st.country,
    st.store_type,
    COUNT(s.sale_id)                            AS transactions,
    ROUND(SUM(s.revenue), 2)                    AS total_revenue,
    ROUND(SUM(s.profit), 2)                     AS total_profit,
    ROUND(SUM(s.profit)/SUM(s.revenue)*100, 1)  AS margin_pct,
    ROUND(SUM(s.revenue)/st.size_sqm, 2)        AS revenue_per_sqm
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY st.store_name, st.city, st.country, st.store_type, st.size_sqm
ORDER BY total_revenue DESC;

-- ============================================================
-- 5. MONTHLY SALES TREND
-- ============================================================

SELECT
    year,
    month,
    quarter,
    COUNT(sale_id)          AS transactions,
    SUM(quantity)           AS units_sold,
    ROUND(SUM(revenue), 2)  AS total_revenue,
    ROUND(SUM(profit), 2)   AS total_profit,
    ROUND(AVG(revenue), 2)  AS avg_order_value
FROM sales
GROUP BY year, month, quarter
ORDER BY year, MIN(sale_date);

-- ============================================================
-- 6. SEASONAL ANALYSIS
-- ============================================================

SELECT
    season,
    COUNT(sale_id)                              AS transactions,
    SUM(quantity)                               AS units_sold,
    ROUND(SUM(revenue), 2)                      AS total_revenue,
    ROUND(AVG(discount_pct), 1)                 AS avg_discount_pct,
    ROUND(SUM(profit)/SUM(revenue)*100, 1)      AS margin_pct
FROM sales
GROUP BY season
ORDER BY total_revenue DESC;

-- ============================================================
-- 7. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    p.product_name,
    p.category,
    p.margin_pct                                AS target_margin,
    COUNT(s.sale_id)                            AS transactions,
    SUM(s.quantity)                             AS units_sold,
    ROUND(SUM(s.revenue), 2)                    AS total_revenue,
    ROUND(SUM(s.profit)/SUM(s.revenue)*100, 1)  AS actual_margin_pct
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name, p.category, p.margin_pct
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================================
-- 8. SUPPLIER PERFORMANCE
-- ============================================================

SELECT
    sup.supplier_name,
    sup.country,
    sup.lead_time_days,
    sup.reliability_score,
    COUNT(po.order_id)                          AS total_orders,
    ROUND(SUM(po.total_cost), 2)                AS total_spend,
    ROUND(AVG(po.delay_days), 1)                AS avg_delay_days,
    ROUND(SUM(po.on_time)*100.0/
          COUNT(po.order_id), 1)                AS on_time_pct
FROM suppliers sup
LEFT JOIN purchase_orders po ON sup.supplier_id = po.supplier_id
GROUP BY sup.supplier_name, sup.country, sup.lead_time_days, sup.reliability_score
ORDER BY total_spend DESC;

-- ============================================================
-- 9. INVENTORY HEALTH CHECK
-- ============================================================

-- Items below reorder point
SELECT
    p.product_name,
    p.category,
    st.store_name,
    i.current_stock,
    i.reorder_point,
    i.days_of_stock,
    i.units_sold,
    p.reorder_qty       AS suggested_order_qty
FROM inventory i
JOIN products p  ON i.product_id = p.product_id
JOIN stores st   ON i.store_id   = st.store_id
WHERE i.below_reorder = 1
ORDER BY i.days_of_stock ASC;

-- Stock coverage summary by category
SELECT
    p.category,
    COUNT(*)                            AS sku_store_combinations,
    SUM(i.below_reorder)                AS items_below_reorder,
    ROUND(AVG(i.days_of_stock), 0)      AS avg_days_of_stock,
    SUM(i.current_stock)                AS total_stock_units
FROM inventory i
JOIN products p ON i.product_id = p.product_id
GROUP BY p.category
ORDER BY items_below_reorder DESC;

-- ============================================================
-- 10. DISCOUNT IMPACT ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN discount_pct = 0   THEN 'No Discount'
        WHEN discount_pct <= 10 THEN '1-10%'
        WHEN discount_pct <= 20 THEN '11-20%'
        ELSE '21%+'
    END                                         AS discount_band,
    COUNT(sale_id)                              AS transactions,
    SUM(quantity)                               AS units_sold,
    ROUND(SUM(revenue), 2)                      AS total_revenue,
    ROUND(AVG(revenue), 2)                      AS avg_order_value,
    ROUND(SUM(profit)/SUM(revenue)*100, 1)      AS margin_pct
FROM sales
GROUP BY discount_band
ORDER BY MIN(discount_pct);

-- ============================================================
-- 11. DEMAND FORECASTING BASE
-- ============================================================

-- Monthly sales velocity per product for forecasting
SELECT
    p.product_id,
    p.product_name,
    p.category,
    s.month,
    s.year,
    SUM(s.quantity)                             AS units_sold,
    ROUND(AVG(s.quantity), 1)                   AS avg_units_per_transaction,
    LAG(SUM(s.quantity)) OVER (
        PARTITION BY p.product_id
        ORDER BY s.year, MIN(s.sale_date)
    )                                           AS prev_month_units,
    ROUND((SUM(s.quantity) - LAG(SUM(s.quantity)) OVER (
        PARTITION BY p.product_id
        ORDER BY s.year, MIN(s.sale_date)
    )) * 100.0 / NULLIF(LAG(SUM(s.quantity)) OVER (
        PARTITION BY p.product_id
        ORDER BY s.year, MIN(s.sale_date)
    ), 0), 1)                                   AS mom_growth_pct
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, s.month, s.year
ORDER BY p.product_id, s.year, MIN(s.sale_date);

-- ============================================================
-- 12. DATA QUALITY CHECKS
-- ============================================================

-- Negative profit transactions
SELECT COUNT(*) AS negative_profit_count
FROM sales WHERE profit < 0;

-- Products with no sales
SELECT p.product_id, p.product_name, p.category
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
WHERE s.sale_id IS NULL;

-- Inventory items with zero stock
SELECT COUNT(*) AS zero_stock_items
FROM inventory WHERE current_stock = 0;
