-- ================================================================================
-- RAW LAYER (BRONZE) INGESTION SCRIPT
-- SOURCE: Azure Data Lake Gen2 (ecommerce-raw)
-- PURPOSE: Create schema-on-write tables and execute ELT load from external stage
-- ================================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ecomm_wh;
USE DATABASE ecomm_db;
USE SCHEMA bronze;

-- 1. Define how to read the CSV
CREATE OR REPLACE FILE FORMAT csv_raw_format
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL', 'null')
    EMPTY_FIELD_AS_NULL = TRUE;

-- 2. Create the Stage
CREATE OR REPLACE STAGE my_azure_stage
    STORAGE_INTEGRATION = azure_blob_int
    URL = 'azure://stecommusc001.blob.core.windows.net/ecommerce-raw/'
    FILE_FORMAT = csv_raw_format;

-- Test bridge
LIST @my_azure_stage;


-- ===========================================
-- 1. ORDERS TABLE
-- The central fact table for transaction timestamps
-- ===========================================
CREATE OR REPLACE TABLE orders (
    order_id STRING,
    customer_id STRING,
    order_status STRING,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

COPY INTO orders
FROM @my_azure_stage/olist_orders_dataset.csv
FILE_FORMAT = csv_raw_format
ON_ERROR = 'CONTINUE';


-- ============================================
-- 2. ORDER ITEMS TABLE
-- Line-item details mapping orders to products and sellers
-- ============================================
CREATE OR REPLACE TABLE order_items (
    order_id STRING,
    order_item_id INTEGER,
    product_id STRING,
    seller_id STRING,
    shipping_limit_date TIMESTAMP,
    price FLOAT,
    freight_value FLOAT
);

COPY INTO order_items
FROM @my_azure_stage/olist_order_items_dataset.csv
FILE_FORMAT = csv_raw_format
ON_ERROR = 'CONTINUE';


-- ==========================================
-- 3. CUSTOMERS TABLE
-- Dimension table for customer demographics
-- ==========================================
CREATE OR REPLACE TABLE customers (
    customer_id STRING,
    customer_unique_id STRING,
    customer_zip_code_prefix STRING,
    customer_city STRING,
    customer_state STRING
);

COPY INTO customers
FROM @my_azure_stage/olist_customers_dataset.csv
FILE_FORMAT = csv_raw_format
ON_ERROR = 'CONTINUE';


-- ==========================================
-- 4. PRODUCTS TABLE
-- Dimension table for product attributes
-- ==========================================
CREATE OR REPLACE TABLE products (
    product_id STRING,
    product_category_name STRING,
    product_name_lenght FLOAT,
    product_description_lenght FLOAT,
    product_photos_qty FLOAT,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);

COPY INTO products
FROM @my_azure_stage/olist_products_dataset.csv
FILE_FORMAT = csv_raw_format
ON_ERROR = 'CONTINUE';


-- ==========================================
-- 5. SELLERS TABLE
-- Dimension table for vendor locations
-- ==========================================
CREATE OR REPLACE TABLE sellers (
    seller_id STRING,
    seller_zip_code_prefix STRING,
    seller_city STRING,
    seller_state STRING
);

COPY INTO sellers
FROM @my_azure_stage/olist_sellers_dataset.csv
FILE_FORMAT = csv_raw_format
ON_ERROR = 'CONTINUE';


-- ==========================================
-- 6. ORDER PAYMENTS TABLE
-- Transaction financial details and installment counts
-- ==========================================
CREATE OR REPLACE TABLE order_payments (
    order_id STRING,
    payment_sequential INTEGER,
    payment_type STRING,
    payment_installments INTEGER,
    payment_value FLOAT
);

COPY INTO order_payments
FROM @my_azure_stage/olist_order_payments_dataset.csv
FILE_FORMAT = csv_raw_format
ON_ERROR = 'CONTINUE';


-- ==========================================
-- 7. ORDER REVIEWS TABLE
-- Complete raw customer-satisfaction dataset from Kaggle. The original file has 7 columns.
-- ==========================================
CREATE OR REPLACE TABLE order_reviews (
    review_id STRING,
    order_id STRING,
    review_score INTEGER,
    review_comment_title STRING,
    review_comment_message STRING,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

COPY INTO order_reviews
FROM @my_azure_stage/olist_order_reviews_dataset.csv
FILE_FORMAT = csv_raw_format
ON_ERROR = 'ABORT_STATEMENT';

-- AI-enriched sample: original review fields plus English translation
CREATE OR REPLACE TABLE order_reviews_ai_enrichment_sample (
    review_id STRING,
    order_id STRING,
    review_score INTEGER,
    review_comment_title STRING,
    review_comment_message STRING,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    english_translation STRING
);

COPY INTO order_reviews_ai_enrichment_sample
FROM @my_azure_stage/olist_order_reviews_enriched_sample.csv
FILE_FORMAT = csv_raw_format
ON_ERROR = 'ABORT_STATEMENT';

-- ==========================================
-- 8. GEOLOCATION TABLE
-- Spatial dimension for map-based visualizations
-- ==========================================
CREATE OR REPLACE TABLE geolocation (
    geolocation_zip_code_prefix STRING,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city STRING,
    geolocation_state STRING
);

COPY INTO geolocation
FROM @my_azure_stage/olist_geolocation_dataset.csv
FILE_FORMAT = csv_raw_format
ON_ERROR = 'CONTINUE';


-- ==========================================
-- 9. PRODUCT CATEGORY TRANSLATION TABLE
-- Mapping Portuguese categories to English
-- ==========================================
CREATE OR REPLACE TABLE product_category_name_translation (
    product_category_name STRING,
    product_category_name_english STRING
);

COPY INTO product_category_name_translation
FROM @my_azure_stage/product_category_name_translation.csv
FILE_FORMAT = csv_raw_format
ON_ERROR = 'CONTINUE';


SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM products;
