-- Create a lightweight compute engine to process data
CREATE OR REPLACE WAREHOUSE ecomm_wh
    WITH WAREHOUSE_SIZE = "XSMALL"
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

-- Create main database
CREATE OR REPLACE DATABASE ecomm_db;

-- Create a schema to store raw, uncleaned data (bronze)
CREATE OR REPLACE SCHEMA ecomm_db.bronze;

-- Switch to administrative role
USE ROLE ACCOUNTADMIN;

-- Create secure connection object
CREATE OR REPLACE STORAGE INTEGRATION azure_blob_int
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = "AZURE"
    ENABLED = TRUE
    AZURE_TENANT_ID = 'c0358d51-f543-49bf-acad-94c0f4d70f9a'
    STORAGE_ALLOWED_LOCATIONS = ('azure://stecommusc001.blob.core.windows.net/ecommerce-raw/');

DESC STORAGE INTEGRATION azure_blob_int;
