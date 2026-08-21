--CREATE TEMP Table (has our query that creates our temporary src table, so 
--it can be referenced in other statements below)

CREATE OR REPLACE TEMPORARY TABLE src_priority_jobs AS (
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM data_jobs.job_postings_fact as jpf
    LEFT JOIN data_jobs.company_dim as cd
        ON jpf.company_id = cd.company_id
    INNER JOIN staging.priority_roles as r
        ON r.role_name = jpf.job_title_short
);

--Update Statement (capture matched rows (middle of venn diagram) that may have
--changed between source and target table)
--in this case we would be updating any rows that had a priority level changed
--in the staging.priority_roles, key table changed by the business users
UPDATE main.priority_jobs_snapshot as tgt
SET
    priority_lvl = src.priority_lvl,
    updated_at = src.updated_at
FROM src_priority_jobs as src
WHERE tgt.job_id = src.job_id
AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl;
-- "IS DISTINCT FROM" is used to check row by row if priority_lvl in this
-- case actually changed. If you left this out, everything would update
-- which is ok in theory, but your updated_at timestamps will all get overwritten


/* Priority levels updated based on latest priority_roles changes, and timestamps
for the two impacted priority_lvl roles changed as well, all w/ Update query
┌──────────────────────┬───────────┬──────────────┬────────────────────────────┐
│   job_title_short    │ job_count │ priority_lvl │         updated_at         │
│       varchar        │   int64   │    int32     │         timestamp          │
├──────────────────────┼───────────┼──────────────┼────────────────────────────┤
│ Data Engineer        │    391957 │            2 │ 2026-08-21 12:41:56.741975 │
│ Software Engineer    │     92271 │            3 │ 2026-08-21 12:41:56.741975 │
│ Senior Data Engineer │     91295 │            1 │ 2026-08-21 12:22:48.977323 │
└──────────────────────┴───────────┴──────────────┴────────────────────────────┘
*/

--INSERT Statement - unmatched/incoming rows. Insert any new jobs that may
--have been added by business into priority_roles table, and get them into tgt
INSERT INTO main.priority_jobs_snapshot (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
SELECT 
    src.job_id,
    src.job_title_short,
    src.company_name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at
FROM src_priority_jobs AS src --our temporary table from step 1
    WHERE NOT EXISTS (
        SELECT 1
        FROM main.priority_jobs_snapshot AS tgt
        WHERE src.job_id = tgt.job_id
    );

--DELETE Statement (delete unmatched rows that exist in target table but not src)

DELETE FROM main.priority_jobs_snapshot as tgt
    WHERE NOT EXISTS (
        SELECT 1
        FROM src_priority_jobs AS src
        WHERE src.job_id = tgt.job_id
    );



--Final Check Query
--View Update Results when we run the script in terminal:
SELECT job_title_short,
COUNT(*) as job_count,
MIN(priority_lvl) as priority_lvl,
MIN(updated_at) as updated_at
FROM priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count desc;