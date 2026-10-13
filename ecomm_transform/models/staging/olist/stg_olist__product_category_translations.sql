WITH source AS (
    SELECT * FROM {{ source('olist_bronze', 'product_category_name_translation') }}
),

renamed AS (
    SELECT
        NULLIF(trim(product_category_name), '') AS product_category_name_pt,
        NULLIF(trim(product_category_name_english), '') AS product_category_name_en
    FROM source
)

SELECT * FROM renamed