SELECT [1,1,1,2];

SELECT UNNEST([1,1,1,2])
UNION
SELECT UNNEST([1,1,3]);

SELECT UNNEST([1,1,1,2])
UNION ALL
SELECT UNNEST([1,1,3]);

SELECT UNNEST([1,1,1,2])
INTERSECT
SELECT UNNEST([1,1,3]);

SELECT UNNEST([1,1,1,2])
INTERSECT ALL
SELECT UNNEST([1,1,3]);

--return rows in A, but only values that don't exist in table B
SELECT UNNEST([1,1,1,2])
EXCEPT
SELECT UNNEST([1,1,3]);

--same as above, but will keep all values in Table A whether they show up in B or not. 
--But will remove duplicates 
SELECT UNNEST([1,1,1,2])
EXCEPT ALL
SELECT UNNEST([1,1,3]);

--Final Example of using set operators in the real world. 

CREATE OR REPLACE TEMP TABLE jobs_2023 AS
SELECT * EXCLUDE (job_id, job_posted_date)
FROM data_jobs.job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2023;

CREATE OR REPLACE TEMP TABLE jobs_2024 AS
SELECT * EXCLUDE (job_id, job_posted_date)
FROM data_jobs.job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2024;

SELECT COUNT(*) FROM jobs_2024;

--1) Which unique job postings appeared in either 2023 or 2024?
SELECT * FROM jobs_2023
UNION
SELECT * FROM jobs_2024;

SELECT
    'jobs_2023' AS table_name,
    COUNT(*) AS record_count
FROM jobs_2023
UNION
SELECT
    'jobs_2024' AS table_name,
    COUNT(*) AS record_count
FROM jobs_2024;

--2) Which job postings appeared across both years, counting duplicates?
--same as above but union all

--3) Which job postings appeared in both 2023 and 2024?
SELECT
    'jobs_2023' AS table_name,
    COUNT(*) AS record_count
FROM jobs_2023
INTERSECT
SELECT
    'jobs_2024' AS table_name,
    COUNT(*) AS record_count
FROM jobs_2024;

--4) Which job postings appeared in both years, preserving duplicate counts?
--INTERSECT ALL

--5) Which job postings appeared in 2023 but not in 2024?
SELECT
    'jobs_2023' AS table_name,
    COUNT(*) AS record_count
FROM jobs_2023
EXCEPT
SELECT
    'jobs_2024' AS table_name,
    COUNT(*) AS record_count
FROM jobs_2024;

--6) Which job postings appeared more times in 2023 than 2024, one-for-one?
SELECT
    'jobs_2023' AS table_name,
    COUNT(*) AS record_count
FROM jobs_2023
EXCEPT ALL
SELECT
    'jobs_2024' AS table_name,
    COUNT(*) AS record_count
FROM jobs_2024;
