# Olist Marketplace Data Pipeline — dbt Transformations

This folder contains the Snowflake transformation layer for the **Olist Marketplace Data Pipeline**. It prepares raw marketplace tables for future fulfillment, seller-performance, and customer-experience reporting.

For the business problem, ingestion architecture, setup prerequisites, and overall roadmap, see the [main project README](../README.md).

## Current scope

The dbt project and connection profile are named `ecomm_transform`. The `olist_bronze` source references raw tables in `ecomm_db.bronze`. Staging models are configured as views; their output schema is determined by the active dbt profile.

Five staging models and their documentation and test definitions are present. Core models and Data Marts are planned. Test definitions do not establish that warehouse tests have passed.

| Model | Purpose | Row represents |
| --- | --- | --- |
| `stg_olist__orders` | Order lifecycle timestamps and standardized order status | One order |
| `stg_olist__customers` | Customer identifiers and delivery locations | One `customer_id` record; a customer can have multiple records |
| `stg_olist__sellers` | Seller identifiers and locations | One seller |
| `stg_olist__products` | Product attributes with consistent names and integer casts | One product |
| `stg_olist__product_category_translations` | Portuguese-to-English category mapping provided by Olist | One category mapping |

Product-category translations come from the source dataset. The AI customer-review translation prototype lives in the Python ingestion code and is not yet integrated into dbt models.

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
        └── stg_olist__product_category_translations.sql
```

`_olist__sources.yml` declares raw tables and source tests. `_olist__models.yml` describes staging models and their tests. Staging SQL reads raw tables through `source()`; downstream models will reference dbt models through `ref()`.

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

Build the staging views:

```bash
uv run dbt run --project-dir ecomm_transform --select "path:models/staging/olist"
```

Run the declared staging-model tests:

```bash
uv run dbt test --project-dir ecomm_transform --select "path:models/staging/olist"
```

Run the declared raw-source tests separately:

```bash
uv run dbt test --project-dir ecomm_transform --select "source:olist_bronze"
```

`dbt run` creates or updates warehouse models; `dbt test` checks warehouse data. A successful parse is not evidence of a successful warehouse run or passing data tests.

## Next development steps

1. Correct source metadata, confirm connectivity, and verify the existing models and tests.
2. Profile and stage the remaining order-item, payment, review, and geolocation data.
3. Build Core models with documented row definitions and controlled joins.
4. Build Data Marts with defined fulfillment, seller-performance, and customer-experience metrics.

Record actual validation results alongside future changes. See the [overall completion roadmap](../README.md#completion-roadmap) for review enrichment, pipeline reliability, automation, and dashboard work.
