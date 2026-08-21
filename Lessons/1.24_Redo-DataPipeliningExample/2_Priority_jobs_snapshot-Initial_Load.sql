--Initial Load Script, one time only.

CREATE OR REPLACE TABLE main.priority_jobs_snapshot (
    job_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR,
    company_name VARCHAR,
    job_posted_date TIMESTAMP,
    salary_year_avg DOUBLE,
    priority_lvl INTEGER,
    updated_at TIMESTAMP
);

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
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP
FROM data_jobs.job_postings_fact as jpf
    LEFT JOIN data_jobs.company_dim as cd
        ON jpf.company_id = cd.company_id
    INNER JOIN staging.priority_roles as r
        ON r.role_name = jpf.job_title_short;

SELECT job_title_short,
COUNT(*) as job_count,
MIN(priority_lvl) as priority_lvl,
MIN(updated_at) as updated_at
FROM priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count desc;

/*
┌──────────────────────┬───────────┬──────────────┬────────────────────────────┐
│   job_title_short    │ job_count │ priority_lvl │         updated_at         │
│       varchar        │   int64   │    int32     │         timestamp          │
├──────────────────────┼───────────┼──────────────┼────────────────────────────┤
│ Data Engineer        │    391957 │            1 │ 2026-08-21 12:22:48.977323 │
│ Software Engineer    │     92271 │            1 │ 2026-08-21 12:22:48.977323 │
│ Senior Data Engineer │     91295 │            1 │ 2026-08-21 12:22:48.977323 │
└──────────────────────┴───────────┴──────────────┴────────────────────────────┘
*/

--Initial Load Script, one time only END


