WITH source AS (
    SELECT *
    FROM {{ source('olist_bronze', 'order_reviews') }}
),

renamed AS (

    SELECT
        concat(review_id, '-', order_id) AS review_key,
        review_id,
        order_id,
        cast(review_score AS INTEGER) AS review_score,
        nullif(trim(review_comment_title), '') AS review_comment_title,
        nullif(trim(review_comment_message), '') AS review_comment_message,
        review_creation_date,
        review_answer_timestamp
    FROM source
)

SELECT * FROM renamed