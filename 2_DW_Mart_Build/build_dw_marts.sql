--duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"

--this file will run all of the individual sql scripts in sequence, 
--allowing us to build out the data mart with just one line of code! 

-- Step 1: DW - Create start schema tables
.read 01_create_tables_dw.sql

-- Step 2: DW - Load data from CSV files into tables
.read 02_load_schema_dw.sql

-- Step 3: Mart - Create flat mart
.read 03_create_flat_mart.sql
