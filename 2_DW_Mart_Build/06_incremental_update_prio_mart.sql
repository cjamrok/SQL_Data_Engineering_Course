-- Step 6: Mart - Update priority roles mart

-- Update Data Engineer to Priority 1
UPDATE priority_mart.priority_roles
SET priority_lvl = 1
WHERE role_name = 'Data Engineer';

-- Add Data Scientist as Priority 3
INSERT INTO priority_mart.priority_roles (role_id,role_name,priority_lvl)
VALUES (4,'Data Scientist', 3);

SELECT * FROM priority_mart.priority_roles;

--Once again stole this from a batch update merge query from lesson 1.24 as a start, 
--then refactored it:

SELECT '=== Creating Temp Source Table for Priority Mart ===' AS info;
CREATE OR REPLACE TEMPORARY TABLE src_priority_jobs AS (
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM job_postings_fact as jpf
    LEFT JOIN company_dim as cd
        ON jpf.company_id = cd.company_id
    INNER JOIN priority_mart.priority_roles as r
        ON r.role_name = jpf.job_title_short
);

SELECT '=== Batch Updating priority_jobs_snapshot for Priority Mart ===' AS info;
MERGE INTO priority_mart.priority_jobs_snapshot AS tgt
USING src_priority_jobs as src
ON tgt.job_id = src.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN 
    UPDATE SET
        priority_lvl = src.priority_lvl,
        updated_at = src.updated_at

WHEN NOT MATCHED THEN 
    INSERT (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
VALUES ( 
    src.job_id,
    src.job_title_short,
    src.company_name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at
)

WHEN NOT MATCHED BY SOURCE THEN DELETE;


--Final Check Query
--View Update Results when we run the script in terminal:
SELECT job_title_short,
COUNT(*) as job_count,
MIN(priority_lvl) as priority_lvl,
MIN(updated_at) as updated_at
FROM priority_mart.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count desc;