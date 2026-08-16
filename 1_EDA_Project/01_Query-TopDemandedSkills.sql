/*
Question: What are the most in-demand skills for data engineers?
- Join job postings to inner join table similar to query 2
- Identify the top 10 in-demand skills for data engineers
- Focus on remote job postings
- Why? Retrieves the top 10 skills with the highest demand in the remote job market,
    providing insights into the most valuable skills for data engineers seeking remote work
*/

-- testing 123 :)

describe job_postings_fact;
describe skills_dim;
--job_id will get you the skills associated with each job

WITH CTE AS (
SELECT jpf.*, skz.*, sd.* FROM job_postings_fact jpf
left join skills_job_dim skz
    ON skz.job_id = jpf.job_id
inner join skills_dim sd
    ON sd.skill_id = skz.skill_id
WHERE job_work_from_home = TRUE
AND job_title_short = 'Data Engineer')

SELECT COUNT(job_id) as "Count", skills FROM CTE
GROUP BY skills
order by Count desc
LIMIT 10;

/*
┌───────┬────────────┐
│ Count │   skills   │
│ int64 │  varchar   │
├───────┼────────────┤
│ 29221 │ sql        │
│ 28776 │ python     │
│ 17823 │ aws        │
│ 14143 │ azure      │
│ 12799 │ spark      │
│  9996 │ airflow    │
│  8639 │ snowflake  │
│  8183 │ databricks │
│  7267 │ java       │
│  6446 │ gcp        │
└───────┴────────────┘
*/
