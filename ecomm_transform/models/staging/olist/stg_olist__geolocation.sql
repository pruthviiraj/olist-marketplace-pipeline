WITH source AS (
    SELECT *
    FROM {{ source('olist_bronze', 'geolocation') }}
),

deduplicated AS (

    SELECT DISTINCT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state,
    FROM source
)

SELECT *
FROM deduplicated