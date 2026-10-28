-- ================================================================================
-- BRONZE LAYER RECONCILIATION
-- PURPOSE: Compare expected source-file row counts with loaded Snowflake raw tables.
-- GRAIN: One row per dataset.
-- ================================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ecomm_wh;
USE DATABASE ecomm_db;
USE SCHEMA bronze;

WITH  expected_counts AS (

    SELECT
        column1::STRING AS dataset_name,
        column2::NUMBER AS expected_rows
    FROM VALUES
        ('orders', 99441),
        ('order_items', 112650),
        ('customers', 99441),
        ('products', 32951),
        ('sellers', 3095),
        ('order_payments', 103886),
        ('order_reviews', 99224),
        ('order_reviews_ai_enrichment_sample', 50),
        ('geolocation', 1000163),
        ('product_category_name_translation', 71)

),

loaded_counts AS (

    SELECT 'orders' AS dataset_name, COUNT(*) AS loaded_rows
    FROM orders

    UNION ALL

    SELECT 'order_items', COUNT(*)
    FROM order_items

    UNION ALL

    SELECT 'customers', COUNT(*)
    FROM customers

    UNION ALL

    SELECT 'products', COUNT(*)
    FROM products

    UNION ALL

    SELECT 'sellers', COUNT(*)
    FROM sellers

    UNION ALL

    SELECT 'order_payments', COUNT(*)
    FROM order_payments

    UNION ALL

    SELECT 'order_reviews', COUNT(*)
    FROM order_reviews

    UNION ALL

    SELECT 'order_reviews_ai_enrichment_sample', COUNT(*)
    FROM order_reviews_ai_enrichment_sample

    UNION ALL

    SELECT 'geolocation', COUNT(*)
    FROM geolocation

    UNION ALL

    SELECT 'product_category_name_translation', COUNT(*)
    FROM product_category_name_translation

),

reconciliation AS (

    SELECT
        expected.dataset_name,
        expected.expected_rows,
        COALESCE(loaded.loaded_rows, 0) AS loaded_rows
    FROM expected_counts AS expected
    LEFT JOIN loaded_counts AS loaded
        ON expected.dataset_name = loaded.dataset_name

)

SELECT
    dataset_name,
    expected_rows,
    loaded_rows,
    loaded_rows - expected_rows AS row_difference,
    CASE
        WHEN loaded_rows = expected_rows THEN 'PASS'
        ELSE 'FAIL'
    END AS reconciliation_status
FROM reconciliation
ORDER BY dataset_name