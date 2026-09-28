-- Step 4: Mart - Create skills demand mart

DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA skills_mart;

--Create dimension tables first, because the fact table has foreign keys
--because keys are involved (unlike the denormalized wide table from 03_),
--we cannot use CTAs, we must create tables and insert rows

CREATE TABLE skills_mart.dim_skills (
   skill_id INTEGER PRIMARY KEY,
    skills  VARCHAR,
    type    VARCHAR
);

INSERT INTO skills_mart.dim_skills (
    skill_id,
    skills,
    type
)
SELECT 
    skill_id,
    skills,
    type
FROM skills_dim;

--Date dimension table

CREATE TABLE skills_mart.dim_date_month (
    month_start_date        DATE        PRIMARY KEY,
    year                    INTEGER,
    month                   INTEGER,
    quarter                 INTEGER,
    quarter_name            VARCHAR,
    year_quarter            VARCHAR
);
INSERT INTO skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
SELECT DISTINCT
    CAST(DATE_TRUNC('month',job_posted_date) AS DATE) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    CONCAT('Q-',CAST(EXTRACT(QUARTER FROM job_posted_date) AS VARCHAR)) AS quarter_name,
    CONCAT(CAST(EXTRACT(YEAR FROM job_posted_date) AS VARCHAR),'-',CONCAT('Q',CAST(EXTRACT(QUARTER FROM job_posted_date) AS VARCHAR))) AS year_quarter
FROM job_postings_fact
ORDER BY year_quarter;

--Last but not least, Fact table with foreign keys

CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id                              INTEGER,
    month_start_date                      DATE,
    job_title_short                       VARCHAR,
    postings_count                        INTEGER,
    remote_postings_count                 INTEGER,
    health_insurance_postings_count       INTEGER,
    no_degree_mention_postings_count      INTEGER,
    PRIMARY KEY(skill_id,month_start_date,job_title_short), -- Primary Key is a combination of these 3 fields
    FOREIGN KEY(skill_id) REFERENCES skills_mart.dim_skills(skill_id),
    FOREIGN KEY(month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
);
INSERT INTO skills_mart.fact_skill_demand_monthly(
    skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_mention_postings_count
)
WITH job_postings_prep AS (
SELECT 
    sjd.skill_id,
    DATE_TRUNC('month',jpf.job_posted_date) AS month_start_date,
    jpf.job_title_short,
    --convert boolean flags to 1s and 0s for aggregation count
    CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
    CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
    CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mentioned
FROM 
    job_postings_fact jpf
INNER JOIN  
    skills_job_dim sjd
    ON sjd.job_id = jpf.job_id
)
SELECT 
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS postings_count,
    SUM(is_remote) AS remote_postings_count,
    SUM(has_health_insurance) AS health_insurance_postings_count,
    SUM(no_degree_mentioned) AS no_degree_mention_postings_count
FROM 
    job_postings_prep
GROUP BY 
    skill_id,
    month_start_date,
    job_title_short
ORDER BY skill_id,
    month_start_date,
    job_title_short;

--Data Validation

SELECT 'Skill Dimension' AS table_name, COUNT(*) AS record_count
FROM skills_mart.dim_skills
UNION ALL
SELECT 'Date Month Dimension', COUNT(*)
FROM skills_mart.dim_date_month
UNION ALL
SELECT 'Skill Demand Fact', COUNT(*)
FROM skills_mart.fact_skill_demand_monthly;

SELECT '=== Skill Dimension Sample ===' AS info;
SELECT * FROM skills_mart.dim_skills LIMIT 5;

SELECT '=== Date Month Dimension Sample ===' AS info;
SELECT * FROM skills_mart.dim_date_month LIMIT 5;

SELECT '=== Skill Demand Fact Sample ===' AS info;
SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 5;


