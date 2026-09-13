--Build a flat skill table for co-workers to access job titles, salary info and skills, all in one table

--Starting Point
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    sd.skills
FROM job_postings_fact AS jpf 
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id 
LEFT JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id;
--WHERE jpf.job_title_short = 'Software Engineer';

--Create Array
CREATE OR REPLACE TEMP TABLE job_skills_array AS
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM job_postings_fact AS jpf 
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id 
LEFT JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
GROUP BY
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg;

--Now that you ahve their array table, query it to analyze median salary per skill
--this query returns all of hte skills associated with each individual job_id
--UNNEST! 
SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skills_array) AS skill
FROM job_skills_array;

--Now analyze with CTE
--this gets us from "skills per job id" to "median salary per skill across all job ids"
WITH CTE AS ( 
SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skills_array) AS skill
FROM job_skills_array
)
SELECT 
    skill,
    median(salary_year_avg) as median_salary
FROM CTE
GROUP BY skill
ORDER BY median_salary desc;

--Final Final Example - Array of Structs
--Build a flat skill and type table to access job titles, salary, skills and type in one table

--Create Array

--Our starting point:
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM job_postings_fact AS jpf 
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id 
LEFT JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
WHERE jpf.job_id = 946424
GROUP BY
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg;

CREATE OR REPLACE TEMP TABLE job_skills_array_struct AS
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(
        STRUCT_PACK(
            skill_type := sd.type,
            skill_name := sd.skills
        )
    ) AS skills_type
FROM job_postings_fact AS jpf 
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id 
LEFT JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
--one single array of 4 structs as an example
WHERE jpf.job_id = 946424
--one single array of 4 structs as an example
GROUP BY
    ALL;

--analyze the median salary per type of skill

--break array of structs down into just structs, no array
SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skills_type)
FROM job_skills_array_struct;

--access the values inside the structs by specifying columns, rather than running the unnest wide open
--in other words, struct values broken down into their own distinct columns
SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skills_type).skill_type AS skill_types,
    UNNEST(skills_type).skill_name AS skill_names
FROM job_skills_array_struct;


    --analyze the median salary per type of skill, by unnesting in a CTE and then aggregating
WITH flat_skills AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_type).skill_type AS skill_type,
        UNNEST(skills_type).skill_name AS skill_name
    FROM
        job_skills_array_struct
)

SELECT
    skill_type,
    MEDIAN(salary_year_avg) AS median_salary
FROM flat_skills
GROUP BY skill_type;


