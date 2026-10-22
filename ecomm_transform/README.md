# Olist Marketplace Data Pipeline — dbt Transformations

This folder contains the Snowflake transformation layer for the **Olist Marketplace Data Pipeline**. It prepares raw marketplace tables for future fulfillment, seller-performance, and customer-experience reporting.

For the business problem, ingestion architecture, setup prerequisites, and overall roadmap, see the [main project README](../README.md).

## Current scope

The dbt project and connection profile are named `ecomm_transform`. The `olist_bronze` source references raw tables in `ecomm_db.bronze`. Staging models are configured as views; their output schema is determined by the active dbt profile.

Ten staging models, one Core order model, and two reporting marts are implemented. The latest full `dbt build` completed with 135 passed checks, 0 warnings, and 0 errors.

| Model | Purpose | Row represents |
| --- | --- | --- |
| `stg_olist__orders` | Order lifecycle timestamps and standardized order status | One order |
| `stg_olist__customers` | Customer identifiers and delivery locations | One `customer_id` record; a customer can have multiple records |
| `stg_olist__sellers` | Seller identifiers and locations | One seller |
| `stg_olist__products` | Product attributes with consistent names and integer casts | One product |
| `stg_olist__product_category_translations` | Portuguese-to-English category mapping provided by Olist | One category mapping |
| `stg_olist__order_items` | Order-line prices, freight, and seller relationships | One order item |
| `stg_olist__order_payments` | Payment method, installments, and value | One order-payment sequence |
| `stg_olist__reviews` | Customer review scores and comments | One review-order pair |
| `stg_olist__review_enrichment` | Optional AI-generated English review translation | One review-order pair |
| `stg_olist__geolocation` | Deduplicated geographic coordinates and labels | One observed location row |
| `core_olist__orders` | One-row-per-order fulfillment and commercial metrics | One order |
| `mart_olist__seller_performance` | Seller order, item, value, and delivery metrics | One seller |
| `mart_olist__customer_experience` | Review scores, fulfillment context, and optional translation | One review-order pair |

Product-category translations come from the source dataset. The AI customer-review translation sample is loaded to Snowflake and joined into the customer-experience mart with a left join so the 50-row sample cannot remove the remaining reviews.

## Model organization

```text
models/
└── staging/
    └── olist/
        ├── _olist__sources.yml
        ├── _olist__models.yml
        ├── stg_olist__orders.sql
        ├── stg_olist__customers.sql
        ├── stg_olist__sellers.sql
        ├── stg_olist__products.sql
        ├── stg_olist__product_category_translations.sql
        ├── stg_olist__order_items.sql
        ├── stg_olist__order_payments.sql
        ├── stg_olist__reviews.sql
        ├── stg_olist__review_enrichment.sql
        └── stg_olist__geolocation.sql
├── core/
│   └── olist/
│       └── core_olist__orders.sql
└── marts/
    └── olist/
        ├── mart_olist__seller_performance.sql
        └── mart_olist__customer_experience.sql
```

`_olist__sources.yml` declares raw tables and source tests. `_olist__models.yml` describes staging models and their tests. Staging SQL reads raw tables through `source()`; Core and mart models reference upstream dbt models through `ref()`.

## Running the project

Run these commands from the **repository root**, the directory containing `pyproject.toml`. Install dependencies and configure your Snowflake profile as described in the [main README](../README.md). Keep connection credentials outside the repository.

Check configuration and Snowflake connectivity:

```bash
uv run dbt debug --project-dir ecomm_transform
```

Parse the project configuration without executing models in Snowflake:

```bash
uv run dbt parse --project-dir ecomm_transform
```

Build the full dbt graph:

```bash
uv run dbt build --project-dir ecomm_transform
```

Run a focused model and its upstream dependencies:

```bash
uv run dbt build --project-dir ecomm_transform --select "+core_olist__orders"
```

Run the declared raw-source tests separately:

```bash
uv run dbt test --project-dir ecomm_transform --select "source:olist_bronze"
```

`dbt run` creates or updates warehouse models; `dbt test` checks warehouse data. A successful parse is not evidence of a successful warehouse run or passing data tests.

## Next development steps

1. Add ingestion reconciliation, repeatable reruns, failure handling, and scheduling.
2. Add Git-based checks and CI using an appropriately restricted warehouse identity.
3. Publish a dashboard and a short case study linking business questions to validated metrics.

Record actual validation results alongside future changes. See the [overall completion roadmap](../README.md#completion-roadmap) for review enrichment, pipeline reliability, automation, and dashboard work.
