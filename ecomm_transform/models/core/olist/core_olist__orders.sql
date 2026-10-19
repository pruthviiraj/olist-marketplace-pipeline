WITH orders AS (

    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date
    FROM {{ ref('stg_olist__orders') }}

),

item_summary AS (

    SELECT
        order_id,
        COUNT(*) AS order_item_count,
        SUM(item_price) AS item_subtotal,
        SUM(freight_value) AS freight_total
    FROM {{ ref('stg_olist__order_items') }}
    GROUP BY order_id

),

payment_summary AS (

    SELECT
        order_id,
        COUNT(*) AS payment_count,
        SUM(payment_value) AS payment_total
    FROM {{ ref('stg_olist__order_payments') }}
    GROUP BY order_id

),

review_summary AS (

    SELECT
        order_id,
        COUNT(*) AS review_count,
        AVG(review_score) AS average_review_score
    FROM {{ ref('stg_olist__reviews') }}
    GROUP BY order_id

)

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    DATEDIFF(
        'day',
        o.order_purchase_timestamp,
        o.order_delivered_customer_date
    ) AS delivery_days,

    CASE
        WHEN o.order_delivered_customer_date IS NULL
            OR o.order_estimated_delivery_date IS NULL
                THEN NULL
        WHEN o.order_delivered_customer_date
            > o.order_estimated_delivery_date
                THEN TRUE
        ELSE FALSE
    END AS is_late_delivery,

    i.order_item_count,
    i.item_subtotal,
    i.freight_total,

    p.payment_count,
    p.payment_total,

    r.review_count,
    r.average_review_score

FROM orders AS o
LEFT JOIN item_summary AS i
    ON o.order_id = i.order_id
LEFT JOIN payment_summary AS p
    ON o.order_id = p.order_id
LEFT JOIN review_summary AS r
    ON o.order_id = r.order_id