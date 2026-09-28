--Step 1: DW - Create star schema tables

DROP TABLE IF EXISTS skills_job_dim;
DROP TABLE IF EXISTS job_posting_fact;
DROP TABLE IF EXISTS skills_dim;
DROP TABLE IF EXISTS company_dim;
--because of data model relationships and primary/foreign keys, the order in which you drop these tables matters! 
--drop the skills_job_dim table first E.G. because it references other tables, but other tables dont reference it
--Catalog Error:
--Could not drop the table because this table is main key table of the table "job_postings_fact"

CREATE TABLE company_dim (
    company_id  INTEGER PRIMARY KEY,
    name        VARCHAR
);

CREATE TABLE skills_dim (
    skill_id    INTEGER PRIMARY KEY,
    skill       VARCHAR,
    type        VARCHAR
);

CREATE TABLE job_posting_fact (
    job_id              INTEGER     PRIMARY KEY,
    company_id          INTEGER,
    job_title_short     VARCHAR,
    job_title     VARCHAR,
    job_location        VARCHAR,
    job_via             VARCHAR,
    job_schedule_type   VARCHAR,
    job_work_from_home  BOOLEAN,
    search_location     VARCHAR,
    job_posted_date     TIMESTAMP,
    job_no_degree_mention   BOOLEAN,
    job_health_insurance    BOOLEAN,
    job_country             VARCHAR,
    salary_rate             VARCHAR,
    salary_year_avg         DOUBLE,
    salary_hour_avg         DOUBLE,
    FOREIGN KEY (company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE skills_job_dim(
    skill_id         INTEGER,
    job_id           INTEGER,
    PRIMARY KEY (skill_id, job_id),
    FOREIGN KEY (skill_id) REFERENCES skills_dim(skill_id),
    FOREIGN KEY (job_id)   REFERENCES job_posting_fact(job_id)    
);

--data validation/make sure tables were created properly at the end here:
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'main';

--we entered terminal after this and ran:
--duckdb dw_marts.duckdb -c ".read 01_create_tables_dw.sql"\
--to create a new, local database. Literally, a .duckdb file populated in our 2_DW_Mart_build folder

