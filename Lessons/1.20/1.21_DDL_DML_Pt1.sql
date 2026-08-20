SELECT * FROM information_schema.schemata;

CREATE SCHEMA IF NOT EXISTS jobs_mart.staging;

--DROP SCHEMA IF EXISTS jobs_mart.staging;

USE jobs_mart;

CREATE TABLE IF NOT EXISTS staging.preferred_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR
);

SELECT * FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';

--DROP TABLE if exists main.preferred_roles;

--idempotent = error control where a script runs with a bunch of IF NOT EXISTS and IFERRORS
--and if empty knime node switches etc. so it won't break when executed

INSERT INTO staging.preferred_roles (role_id, role_name)
VALUES 
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer'),
    (3, 'Software Engineer'),
    (4, 'Testing duplicate insertion');

SELECT * FROM staging.priority_roles;

ALTER TABLE staging.priority_roles
ADD COLUMN preferred_role BOOLEAN;

ALTER TABLE staging.priority_roles
DROP COLUMN preferred_role;

UPDATE staging.priority_roles
SET preferred_role = FALSE
WHERE role_id = 3;

/*
│  int32  │       varchar        │    boolean     │
├─────────┼──────────────────────┼────────────────┤
│       1 │ Data Engineer        │ true           │
│       2 │ Senior Data Engineer │ true           │
│       3 │ Software Engineer    │ false          │
└─────────┴──────────────────────┴────────────────┘
*/

ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;

ALTER TABLE staging.priority_roles
RENAME COLUMN preferred_role TO priority_lvl;

ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER;

UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id = 3;

SELECT * FROM staging.priority_roles;


