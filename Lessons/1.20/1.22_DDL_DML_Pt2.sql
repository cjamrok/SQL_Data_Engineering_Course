--CTAs

SELECT jpf.*, cd.*
FROM data_jobs.job_postings_fact as jpf
LEFT JOIN data_jobs.company_dim as cd
    ON jpf.company_id = cd.company_id
    LIMIT 10;

CREATE OR REPLACE TABLE staging.job_postings_flat AS --Flat is coder speak for CTA in this case
--, because it won't regularly update like a view does
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name,
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id;


SELECT * FROM staging.job_postings_flat
LIMIT 10;

CREATE OR REPLACE VIEW staging.priority_jobs_flat_view AS
SELECT * FROM staging.job_postings_flat as jpf
JOIN staging.priority_roles as r
    ON jpf.job_title_short = r.role_name
    WHERE r.priority_lvl = 1;

SELECT 
    job_title_short,
    COUNT(*) AS job_count
FROM staging.priority_jobs_flat_view
GROUP BY job_title_short
order by job_title_short desc;

--Temp Tables
--No schema listed, Temp Tables don't live in schemas. 

CREATE TEMPORARY TABLE senior_jobs_flat_temp AS
SELECT * FROM staging.priority_jobs_flat_view
WHERE job_title_short = 'Senior Data Engineer';

SELECT * FROM senior_jobs_flat_temp;

--Delete/Truncate/Drop

SELECT COUNT(*) FROM staging.job_postings_flat;
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;
SELECT COUNT(*) FROM senior_jobs_flat_temp;

DELETE FROM staging.job_postings_flat
WHERE job_posted_date < '2024-01-01';

SELECT COUNT(*) FROM staging.job_postings_flat;
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;
SELECT COUNT(*) FROM senior_jobs_flat_temp;

--You can see the row counts changed for everything except the temp table
--, which was a snapshot that wasn't updated in the Delete script

TRUNCATE TABLE staging.job_postings_flat;

SELECT * FROM staging.job_postings_flat;

INSERT INTO staging.job_postings_flat
SELECT  jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name,
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE job_posted_date >= '2024-01-01';


--Subqueries and CTEs

SELECT * FROM 
(
    SELECT * FROM job_postings_fact
    WHERE salary_year_avg is not null 
    OR salary_hour_avg is not null 
) as my_subquery_alias
LIMIT 10;

--CTEs

WITH valid_salaries AS (
    SELECT * FROM job_postings_fact
    WHERE salary_year_avg is not null 
    OR salary_hour_avg is not null 
)

SELECT * FROM valid_salaries;



-- Scenario 1 – Subquery in `SELECT`
-- Show each job’s salary next to the overall market median:

SELECT job_title_short, salary_year_avg,
(SELECT median(salary_year_avg) FROM job_postings_fact
) as Median_Salary_Market
FROM job_postings_fact
WHERE salary_year_avg is not null;

-- Scenario 2 – Subquery in FROM
-- Stage only jobs that are remote before aggregating:
SELECT job_title_short, median(salary_year_avg) as median_salary,
    (SELECT median(salary_year_avg) FROM job_postings_fact
    WHERE job_work_from_home = TRUE) AS market_remote_median_salary
FROM job_postings_fact
WHERE job_work_from_home = TRUE and salary_year_avg is not null
GROUP BY job_title_short
limit 10;

-- Scenario 3 – Subquery in `HAVING`
-- Keep only job titles whose median salary is above the overall median:
SELECT job_title_short, median(salary_year_avg) as median_salary,
    (SELECT median(salary_year_avg) FROM job_postings_fact
    WHERE job_work_from_home = TRUE) AS market_remote_median_salary
FROM job_postings_fact
WHERE job_work_from_home = TRUE and salary_year_avg is not null
GROUP BY job_title_short

HAVING median(salary_year_avg) > 
    (SELECT median(salary_year_avg) FROM job_postings_fact
    WHERE job_work_from_home = TRUE)

limit 10;

--CTEs
-- Compare how much more (or less) remote roles pay compared to onsite roles for each job title.
-- Use a CTE to calculate the median salary by title and work arrangement, then compare those medians.


--so what's happening here is you select a CTE that shows median salary by job title with duplicates for each job title - one for remove and one for office
--then you query that CTE and filter to only show the remote jobs
--THEN you join that query result with the same CTE table once again, this time filtering just for office jobs. The result is below, one median salary column
--for remote, and another for office. Then you can add the gap row level calc in the main query for a 3rd column as well
--see "remove" and "office" aliases below in the join for further clarification
WITH CTE AS (
SELECT job_title_short, job_work_from_home, CAST(MEDIAN(salary_year_avg) AS Integer) as median_salary
FROM job_postings_fact
WHERE job_country = 'United States'
GROUP BY job_title_short, job_work_from_home
)

SELECT remote.job_title_short, remote.median_salary AS remote_median_salary, office.median_salary AS office_median_salary,
(remote.median_salary - office.median_salary) AS remote_premium
FROM CTE AS remote
inner join CTE AS office
    ON remote.job_title_short = office.job_title_short
    WHERE remote.job_work_from_home = TRUE
        AND office.job_work_from_home = FALSE;


/*
┌───────────────────────────┬───────────────┬───────────────┬────────────────┐
│      job_title_short      │ median_salary │ median_salary │ remote_premium │
│          varchar          │     int32     │     int32     │     int32      │
├───────────────────────────┼───────────────┼───────────────┼────────────────┤
│ Data Scientist            │        135000 │        127266 │           7734 │
│ Senior Data Analyst       │        107913 │        110400 │          -2487 │
│ Cloud Engineer            │         51250 │        135000 │         -83750 │
│ Business Analyst          │         90000 │         95160 │          -5160 │
│ Data Analyst              │         90000 │         90000 │              0 │
│ Software Engineer         │        122500 │        150000 │         -27500 │
│ Data Engineer             │        135000 │        130000 │           5000 │
│ Senior Data Scientist     │        160000 │        157500 │           2500 │
│ Machine Learning Engineer │        168500 │        151250 │          17250 │
│ Senior Data Engineer      │        145000 │        150000 │          -5000 │
└───────────────────────────┴───────────────┴───────────────┴────────────────┘
*/


--Existence Filters: Source and Target Tables (Where Exists, Where Not Exists)
--normal syntax uses a simple "1" value to start the "Where Exists" filter, see below:
-- uses a subquery

SELECT * FROM range(3) AS src(key);

SELECT * FROM range(2) AS tgt(key);

SELECT * FROM range(3) AS src(key)
WHERE NOT EXISTS (
    SELECT 1
    FROM range(2) as tgt(key)
    WHERE tgt.key = src.key
);


--identify job posting that have no associated skills 
--if you wanted to return job posting that ONLY DO have associated skills, swap from WHERE NOT EXISTS to WHERE EXISTS

SELECT *
FROM job_postings_fact as tgt
WHERE NOT EXISTS (
    SELECT 1 /*or even * or 2 or * or whatever */
    FROM skills_job_dim as src
    WHERE tgt.job_id = src.job_id
)
ORDER BY job_id;


--Merge = use one statement to perform an insert, update and delete in one fell swoop

