WITH seller_items AS (
    SELECT
        i.seller_id,
        i.order_id,
        i.order_item_key,
        i.item_price,
        i.freight_value,
        o.delivery_days,
        o.is_late_delivery
    FROM {{ ref('stg_olist__order_items') }} AS i
    INNER JOIN {{ ref('core_olist__orders') }} AS o
        ON o.order_id = i.order_id
)

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS seller_order_count,
    COUNT(*) AS seller_item_count,
    SUM(item_price) AS item_subtotal,
    SUM(freight_value) AS freight_total,

    COUNT(DISTINCT CASE
        WHEN delivery_days IS NOT NULL THEN order_id
    END) AS delivered_order_count,

    COUNT(DISTINCT CASE
        WHEN is_late_delivery = TRUE THEN order_id
    END) AS late_order_count,

    AVG(delivery_days) AS average_delivery_days

FROM seller_items
GROUP BY seller_id