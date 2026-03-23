-- ============================================================
--  ANALYTICAL QUERIES — RETAIL DATA WAREHOUSE
--  Schema: fact_sales, dim_date, dim_store, dim_product
-- ============================================================


-- ============================================================
--  Q1: Total sales revenue by product category for each month
-- ============================================================

SELECT
    d.year,
    d.month,
    d.month_name,
    p.category,
    SUM(f.total_amount)  AS total_revenue,
    SUM(f.units_sold)    AS total_units
FROM   fact_sales    f
JOIN   dim_date      d ON d.date_key    = f.date_key
JOIN   dim_product   p ON p.product_key = f.product_key
GROUP  BY d.year, d.month, d.month_name, p.category
ORDER  BY d.year, d.month, total_revenue DESC;


-- ============================================================
--  Q2: Top 2 performing stores by total revenue
-- ============================================================

SELECT
    s.store_name,
    s.city,
    s.region,
    SUM(f.total_amount)  AS total_revenue,
    SUM(f.units_sold)    AS total_units,
    COUNT(f.sale_id)     AS transaction_count
FROM   fact_sales f
JOIN   dim_store  s ON s.store_key = f.store_key
GROUP  BY s.store_name, s.city, s.region
ORDER  BY total_revenue DESC
LIMIT  2;


-- ============================================================
--  Q3: Month-over-month sales trend across all stores
-- ============================================================

WITH monthly_sales AS (
    SELECT
        d.year,
        d.month,
        d.month_name,
        SUM(f.total_amount) AS monthly_revenue
    FROM   fact_sales f
    JOIN   dim_date   d ON d.date_key = f.date_key
    GROUP  BY d.year, d.month, d.month_name
)
SELECT
    year,
    month,
    month_name,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY year, month)  AS prev_month_revenue,
    ROUND(
        monthly_revenue
        - LAG(monthly_revenue) OVER (ORDER BY year, month),
        2
    )                                                  AS mom_change,
    ROUND(
        (monthly_revenue
         - LAG(monthly_revenue) OVER (ORDER BY year, month))
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY year, month), 0)
        * 100,
        2
    )                                                  AS mom_pct_change
FROM   monthly_sales
ORDER  BY year, month;
