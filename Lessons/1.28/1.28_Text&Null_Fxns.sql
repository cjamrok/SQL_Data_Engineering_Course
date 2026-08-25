SELECT CONCAT('SQL', '-', 'Functions');

SELECT 'SQL' || '-' || 'Functions';

SELECT TRIM(' SQL ');

--REGEX_REPLACE
--he said to use chatgpt lol

SELECT REGEXP_REPLACE('data.nerd@gmail.com', '^.*(@)', '\1');

-- Final Example - Cleanup this using Text Functions
--"proper" I guess? =proper()

WITH title_lower AS (
    SELECT
        job_title,
        LOWER(TRIM(job_title)) AS job_title_clean
    FROM data_jobs.job_postings_fact
)
SELECT
    job_title,
    CASE
        WHEN job_title_clean LIKE '%data%'
            AND job_title_clean LIKE '%analyst%' THEN 'Data Analyst'
        WHEN job_title_clean LIKE '%data%'
            AND job_title_clean LIKE '%scientist%' THEN 'Data Scientist'
        WHEN job_title_clean LIKE '%data%'
            AND job_title_clean LIKE '%engineer%' THEN 'Data Engineer'
        ELSE 'Other'
    END AS job_title_category
FROM title_lower
ORDER BY RANDOM()
LIMIT 30;

--Null Functions

SELECT NULLIF(10,10);

SELECT NULLIF(10,9);

--Use Case = if field = 0 then null it out else show value
SELECT
    NULLIF(salary_year_avg, 0),
    NULLIF(salary_hour_avg, 0)
FROM
    data_jobs.job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;

--you can do a bunch of values in a coalesce as it turns out! :)

SELECT COALESCE(null,null,0,1);

SELECT
salary_year_avg,
salary_hour_avg,
COALESCE(salary_year_avg,salary_hour_avg*2080)
FROM data_jobs.job_postings_fact
WHERE salary_year_avg is not null or salary_hour_avg is not null
LIMIT 10;

--Final Example - same example from a previous CTE lesson, but simplied using Coalesce
SELECT
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg * 2080) AS standardized_salary,
    CASE
        WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) IS NULL THEN 'Missing'
        WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) < 75000 THEN 'Low'
        WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) < 150000 THEN 'Mid'
        ELSE 'High'
    END AS salary_bucket
FROM data_jobs.job_postings_fact
ORDER BY standardized_salary DESC;