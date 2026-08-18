SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'job_postings_fact';

--use cast to change data type
--"casting is going to save your but in data pipelines. Have code in place
--to enforce the data type that you want regardless of user input."
SELECT CAST(123 AS VARCHAR);

--casting a boolean as an int returns zeros (false) and ones (trues)
SELECT
    job_id, -- "more" unique identifier
    CONCAT(CAST(company_id AS varchar),'-',CAST(job_id AS varchar)),
    CAST(job_work_from_home AS INT) AS job_work_from_home, -- from boolean to numeric value
    CAST(job_posted_date AS DATE) AS job_posted_date, -- from timestamp to date only
    CAST(salary_year_avg AS DECIMAL(10, 0))-- from double to no decimal places
FROM
    job_postings_fact
WHERE salary_year_avg is not null;

/*
┌───────────────────┬───────────────────────┬───────────┐
│    table_name     │      column_name      │ data_type │
│      varchar      │        varchar        │  varchar  │
├───────────────────┼───────────────────────┼───────────┤
│ job_postings_fact │ job_id                │ INTEGER   │
│ job_postings_fact │ company_id            │ INTEGER   │
│ job_postings_fact │ job_title_short       │ VARCHAR   │
│ job_postings_fact │ job_title             │ VARCHAR   │
│ job_postings_fact │ job_location          │ VARCHAR   │
│ job_postings_fact │ job_via               │ VARCHAR   │
│ job_postings_fact │ job_schedule_type     │ VARCHAR   │
│ job_postings_fact │ job_work_from_home    │ BOOLEAN   │
│ job_postings_fact │ search_location       │ VARCHAR   │
│ job_postings_fact │ job_posted_date       │ TIMESTAMP │
│ job_postings_fact │ job_no_degree_mention │ BOOLEAN   │
│ job_postings_fact │ job_health_insurance  │ BOOLEAN   │
│ job_postings_fact │ job_country           │ VARCHAR   │
│ job_postings_fact │ salary_rate           │ VARCHAR   │
│ job_postings_fact │ salary_year_avg       │ DOUBLE    │
│ job_postings_fact │ salary_hour_avg       │ DOUBLE    │
└───────────────────┴───────────────────────┴───────────┘
*/

