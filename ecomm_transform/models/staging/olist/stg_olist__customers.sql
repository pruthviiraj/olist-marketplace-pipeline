WITH source AS (

    SELECT * FROM {{ source('olist_bronze', 'customers') }}

),

renamed AS (
    
    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    FROM source
)

SELECT * FROM renamed