--duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"

--this file will run all of the individual sql scripts in sequence, 
--allowing us to build out the data mart with just one line of code! 

-- Step 1: DW - Create start schema tables
.read 01_create_tables_dw.sql

-- Step 2: DW - Load data from CSV files into tables
.read 02_load_schema_dw.sql

-- Step 3: Mart - Create flat mart
.read 03_create_flat_mart.sql

-- Step 4: Mart - Create skills demand mart
.read 04_create_skills_mart.sql

-- Step 5: Mart - Create priority mart
.read 05_create_priority_mart.sql

-- Step 6: Mart - Incrememental update priority mart, update and/or add any new rows based on 
--user updated priority_roles table
.read 06_incremental_update_prio_mart.sql
