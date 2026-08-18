SELECT * FROM information_schema.tables
WHERE table_catalog = 'data_jobs';

SELECT * FROM information_schema.columns
WHERE table_catalog = 'data_jobs';

SELECT * FROM information_schema.table_constraints
WHERE table_catalog = 'data_jobs';

SELECT * FROM information_schema.columns
WHERE table_catalog = 'data_jobs';

SELECT * FROM information_schema.schemata;

DESCRIBE job_postings_fact;