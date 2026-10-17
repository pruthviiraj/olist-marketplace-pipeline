WITH source AS (
    SELECT *
    FROM {{ source('olist_bronze', 'order_items') }}
),

renamed AS (

    SELECT
        concat(order_id, '-', order_item_id) AS order_item_key,
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        cast(price AS number(18, 2)) AS item_price,
        cast(freight_value AS number(18, 2)) AS freight_value
    FROM source
)

SELECT * FROM renamed
