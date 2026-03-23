-- ============================================================
--  DATA WAREHOUSE — RETAIL CHAIN STAR SCHEMA
--  Source: retail_transactions.csv
--
--  Data Quality Issues Addressed:
--    1. Inconsistent date formats (DD/MM/YYYY, DD-MM-YYYY, YYYY-MM-DD)
--       → All dates standardised to ISO 8601 (YYYY-MM-DD)
--    2. NULL values in store_city
--       → Imputed from the known store_name → city mapping
--    3. Inconsistent category casing / naming
--       ('electronics', 'Electronics', 'Grocery', 'Groceries')
--       → Normalised to: 'Electronics', 'Grocery', 'Clothing'
-- ============================================================


-- ============================================================
--  DIMENSION TABLE: dim_date
--  Natural key  : date_key  (INT, format YYYYMMDD)
--  Grain        : One row per calendar day that appears in the data
-- ============================================================

CREATE TABLE dim_date (
    date_key     INT          NOT NULL,   -- surrogate key (YYYYMMDD)
    full_date    DATE         NOT NULL,
    day          SMALLINT     NOT NULL,
    month        SMALLINT     NOT NULL,
    month_name   VARCHAR(10)  NOT NULL,
    year         SMALLINT     NOT NULL,
    quarter      SMALLINT     NOT NULL,   -- 1–4
    day_of_week  VARCHAR(10)  NOT NULL,   -- e.g. 'Monday'
    is_weekend   BOOLEAN      NOT NULL,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
);

-- ============================================================
--  DIMENSION TABLE: dim_store
--  Grain: One row per physical store location
-- ============================================================

CREATE TABLE dim_store (
    store_key    INT          NOT NULL,
    store_name   VARCHAR(50)  NOT NULL,
    city         VARCHAR(30)  NOT NULL,
    region       VARCHAR(30)  NOT NULL,   -- derived from city
    CONSTRAINT pk_dim_store PRIMARY KEY (store_key)
);

-- ============================================================
--  DIMENSION TABLE: dim_product
--  Grain: One row per distinct product SKU
-- ============================================================

CREATE TABLE dim_product (
    product_key    INT          NOT NULL,
    product_name   VARCHAR(60)  NOT NULL,
    category       VARCHAR(30)  NOT NULL,   -- Electronics | Grocery | Clothing
    CONSTRAINT pk_dim_product PRIMARY KEY (product_key)
);

-- ============================================================
--  FACT TABLE: fact_sales
--  Grain       : One row per individual retail transaction
--  Measures    : units_sold, unit_price, total_amount, discount_amount
--  Additive    : all measures are fully additive across all dimensions
-- ============================================================

CREATE TABLE fact_sales (
    sale_id         SERIAL       NOT NULL,
    transaction_id  VARCHAR(10)  NOT NULL,   -- source system natural key
    date_key        INT          NOT NULL,
    store_key       INT          NOT NULL,
    product_key     INT          NOT NULL,
    customer_id     VARCHAR(10)  NOT NULL,
    units_sold      INT          NOT NULL,
    unit_price      NUMERIC(12,2) NOT NULL,
    total_amount    NUMERIC(14,2) NOT NULL,   -- units_sold * unit_price
    CONSTRAINT pk_fact_sales   PRIMARY KEY (sale_id),
    CONSTRAINT fk_fs_date      FOREIGN KEY (date_key)    REFERENCES dim_date    (date_key),
    CONSTRAINT fk_fs_store     FOREIGN KEY (store_key)   REFERENCES dim_store   (store_key),
    CONSTRAINT fk_fs_product   FOREIGN KEY (product_key) REFERENCES dim_product (product_key)
);

-- ============================================================
--  LOAD: dim_date
--  15 distinct calendar days present in the cleaned sample
--  Columns: (date_key, full_date, day, month, month_name,
--             year, quarter, day_of_week, is_weekend)
-- ============================================================

INSERT INTO dim_date
    (date_key, full_date, day, month, month_name, year, quarter, day_of_week, is_weekend)
VALUES
    (20230115, '2023-01-15', 15,  1, 'January',   2023, 1, 'Sunday',    TRUE),
    (20230220, '2023-02-20', 20,  2, 'February',  2023, 1, 'Monday',    FALSE),
    (20230331, '2023-03-31', 31,  3, 'March',     2023, 1, 'Friday',    FALSE),
    (20230406, '2023-04-06',  6,  4, 'April',     2023, 2, 'Thursday',  FALSE),
    (20230428, '2023-04-28', 28,  4, 'April',     2023, 2, 'Friday',    FALSE),
    (20230502, '2023-05-02',  2,  5, 'May',       2023, 2, 'Tuesday',   FALSE),
    (20230521, '2023-05-21', 21,  5, 'May',       2023, 2, 'Sunday',    TRUE),
    (20230812, '2023-08-12', 12,  8, 'August',    2023, 3, 'Saturday',  TRUE),
    (20230815, '2023-08-15', 15,  8, 'August',    2023, 3, 'Tuesday',   FALSE),
    (20230829, '2023-08-29', 29,  8, 'August',    2023, 3, 'Tuesday',   FALSE),
    (20230908, '2023-09-08',  8,  9, 'September', 2023, 3, 'Friday',    FALSE),
    (20231020, '2023-10-20', 20, 10, 'October',   2023, 4, 'Friday',    FALSE),
    (20231026, '2023-10-26', 26, 10, 'October',   2023, 4, 'Thursday',  FALSE),
    (20231118, '2023-11-18', 18, 11, 'November',  2023, 4, 'Saturday',  TRUE),
    (20231212, '2023-12-12', 12, 12, 'December',  2023, 4, 'Tuesday',   FALSE);

-- ============================================================
--  LOAD: dim_store
--  5 unique store branches
--  Region derived from city geography
--  NULL store_city values (19 rows in source) imputed here
-- ============================================================

INSERT INTO dim_store (store_key, store_name, city, region)
VALUES
    (1, 'Chennai Anna',    'Chennai',   'South India'),
    (2, 'Delhi South',     'Delhi',     'North India'),
    (3, 'Bangalore MG',    'Bangalore', 'South India'),
    (4, 'Pune FC Road',    'Pune',      'West India'),
    (5, 'Mumbai Central',  'Mumbai',    'West India');

-- ============================================================
--  LOAD: dim_product
--  10 distinct SKUs referenced by the 15 sample fact rows
--  category normalised:
--    'electronics' / 'Electronics'  → 'Electronics'
--    'Grocery'     / 'Groceries'    → 'Grocery'
--    'Clothing'                     → 'Clothing'  (unchanged)
-- ============================================================

INSERT INTO dim_product (product_key, product_name, category)
VALUES
    (1,  'Speaker',     'Electronics'),
    (2,  'Tablet',      'Electronics'),
    (3,  'Phone',       'Electronics'),
    (4,  'Smartwatch',  'Electronics'),
    (5,  'Atta 10kg',   'Grocery'),
    (6,  'Jeans',       'Clothing'),
    (7,  'Biscuits',    'Grocery'),
    (8,  'Jacket',      'Clothing'),
    (9,  'Laptop',      'Electronics'),
    (10, 'Milk 1L',     'Grocery');

-- ============================================================
--  LOAD: fact_sales
--  15 rows — one per transaction (TXN5000 – TXN5014)
--
--  Data cleaning applied before loading:
--    • Dates parsed from mixed formats and stored as date_key (FK)
--    • store_city NULLs resolved through dim_store lookup
--    • category normalised and pushed to dim_product
--    • total_amount computed as units_sold × unit_price
-- ============================================================

INSERT INTO fact_sales
    (transaction_id, date_key, store_key, product_key, customer_id,
     units_sold, unit_price, total_amount)
VALUES
    -- TXN5000 | 2023-08-29 | Chennai Anna | Speaker      | 3 × 49262.78
    ('TXN5000', 20230829, 1, 1,  'CUST045',  3, 49262.78,  147788.34),

    -- TXN5001 | 2023-12-12 | Chennai Anna | Tablet       | 11 × 23226.12
    ('TXN5001', 20231212, 1, 2,  'CUST021', 11, 23226.12,  255487.32),

    -- TXN5002 | 2023-05-02 | Chennai Anna | Phone        | 20 × 48703.39
    ('TXN5002', 20230502, 1, 3,  'CUST019', 20, 48703.39,  974067.80),

    -- TXN5003 | 2023-02-20 | Delhi South  | Tablet       | 14 × 23226.12
    ('TXN5003', 20230220, 2, 2,  'CUST007', 14, 23226.12,  325165.68),

    -- TXN5004 | 2023-01-15 | Chennai Anna | Smartwatch   | 10 × 58851.01
    ('TXN5004', 20230115, 1, 4,  'CUST004', 10, 58851.01,  588510.10),

    -- TXN5005 | 2023-09-08 | Bangalore MG | Atta 10kg    | 12 × 52464.00
    ('TXN5005', 20230908, 3, 5,  'CUST027', 12, 52464.00,  629568.00),

    -- TXN5006 | 2023-03-31 | Pune FC Road | Smartwatch   | 6 × 58851.01
    ('TXN5006', 20230331, 4, 4,  'CUST025',  6, 58851.01,  353106.06),

    -- TXN5007 | 2023-10-26 | Pune FC Road | Jeans        | 16 × 2317.47
    ('TXN5007', 20231026, 4, 6,  'CUST041', 16,  2317.47,   37079.52),

    -- TXN5008 | 2023-08-12 | Bangalore MG | Biscuits     | 9 × 27469.99
    ('TXN5008', 20230812, 3, 7,  'CUST030',  9, 27469.99,  247229.91),

    -- TXN5009 | 2023-08-15 | Bangalore MG | Smartwatch   | 3 × 58851.01
    ('TXN5009', 20230815, 3, 4,  'CUST020',  3, 58851.01,  176553.03),

    -- TXN5010 | 2023-04-06 | Chennai Anna | Jacket       | 15 × 30187.24
    ('TXN5010', 20230406, 1, 8,  'CUST031', 15, 30187.24,  452808.60),

    -- TXN5011 | 2023-10-20 | Mumbai Central | Jeans      | 13 × 2317.47
    ('TXN5011', 20231020, 5, 6,  'CUST045', 13,  2317.47,   30127.11),

    -- TXN5012 | 2023-05-21 | Bangalore MG | Laptop       | 13 × 42343.15
    ('TXN5012', 20230521, 3, 9,  'CUST044', 13, 42343.15,  550460.95),

    -- TXN5013 | 2023-04-28 | Mumbai Central | Milk 1L    | 10 × 43374.39
    ('TXN5013', 20230428, 5, 10, 'CUST015', 10, 43374.39,  433743.90),

    -- TXN5014 | 2023-11-18 | Delhi South  | Jacket       | 5 × 30187.24
    ('TXN5014', 20231118, 2, 8,  'CUST042',  5, 30187.24,  150936.20);


