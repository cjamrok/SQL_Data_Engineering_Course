SELECT * FROM information_schema.schemata;

CREATE SCHEMA IF NOT EXISTS jobs_mart.staging;

--DROP SCHEMA IF EXISTS jobs_mart.staging;

USE jobs_mart;

CREATE TABLE IF NOT EXISTS staging.preferred_roles (
    role_id INTEGER,
    role_name VARCHAR
);

SELECT * FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';

--DROP TABLE if exists main.preferred_roles;

--idempotent = error control where a script runs with a bunch of IF NOT EXISTS and IFERRORS
--and if empty knime node switches etc. so it won't break when executed



