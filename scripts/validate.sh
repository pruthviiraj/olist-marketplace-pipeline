#!/usr/bin/env bash

set -euo pipefail

echo "1/4 Checking Python syntax..."
uv run python -m compileall -q src

echo "2/4 Parsing dbt project..."
uv run dbt parse \
  --project-dir ecomm_transform \
  --profiles-dir .dbt-ci

echo "3/4 Checking working-tree whitespace..."
git diff --check

echo "4/4 Checking staged whitespace..."
git diff --cached --check

echo "Validation passed."