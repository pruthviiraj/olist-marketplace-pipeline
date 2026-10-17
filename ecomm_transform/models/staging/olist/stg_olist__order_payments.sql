WITH source AS (
    SELECT *
    FROM {{ source('olist_bronze', 'order_payments') }}
),

renamed AS (

    SELECT
        concat(order_id, '-', payment_sequential) AS payment_key,
        order_id,
        payment_sequential,
        nullif(lower(trim(payment_type)), '') AS payment_type,
        cast(payment_installments AS integer) AS payment_installments,
        cast(payment_value AS number(18, 2)) AS payment_value
    FROM source
)

SELECT * FROM renamed