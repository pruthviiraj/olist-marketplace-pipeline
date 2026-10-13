WITH source AS (
    SELECT * FROM {{ source('olist_bronze', 'products') }}
),
renamed as (
    SELECT
        product_id,
        nullif(trim(product_category_name), '') as product_category_name_pt,
        cast(product_name_lenght as integer) as product_name_length,
        cast(product_description_lenght as integer) as product_description_length,
        cast(product_photos_qty as integer) as product_photos_count,
        cast(product_weight_g as integer) as product_weight_g,
        cast(product_length_cm as integer) as product_length_cm,
        cast(product_height_cm as integer) as product_height_cm,
        cast(product_width_cm as integer) as product_width_cm
    FROM source
)

SELECT * FROM renamed