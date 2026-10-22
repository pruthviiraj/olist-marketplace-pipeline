WITH review_base AS (

    SELECT
        r.review_key,
        r.review_id,
        r.order_id,
        r.review_score,
        r.review_comment_title,
        r.review_comment_message,
        r.review_creation_date,
        r.review_answer_timestamp,
        o.order_status,
        o.delivery_days,
        o.is_late_delivery
    FROM {{ ref('stg_olist__reviews') }} AS r
    INNER JOIN {{ ref('core_olist__orders') }} AS o
        ON r.order_id = o.order_id

),

enrichment AS (

    SELECT
        review_key,
        english_translation
    FROM {{ ref('stg_olist__review_enrichment') }}

)

SELECT
    r.*,
    e.english_translation
FROM review_base AS r
LEFT JOIN enrichment AS e
    ON r.review_key = e.review_key