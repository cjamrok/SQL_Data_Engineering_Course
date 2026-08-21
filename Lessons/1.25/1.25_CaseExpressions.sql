USE data_jobs;

SELECT
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg IS NULL THEN 'Missing'
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
LIMIT 10;

SELECT
    job_title,
    CASE
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Analyst%' THEN 'Data Analyst'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Engineer%' THEN 'Data Engineer'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Scientist%' THEN 'Data Scientist'
        ELSE 'Other'
    END AS job_title_category,
    job_title_short
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 20;

SELECT
    job_title_short,
    COUNT(*) AS total_postings,
    MEDIAN(
        CASE
            WHEN salary_year_avg < 100000 THEN salary_year_avg
        END
    ) AS median_low_salary,
    MEDIAN(
        CASE
            WHEN salary_year_avg >= 100000 THEN salary_year_avg
        END
    ) AS median_high_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short;


WITH CTE AS (
SELECT
    job_title_short,
    salary_hour_avg,
    salary_year_avg,
    CASE
        WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
        WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
    END AS standardized_salary
FROM
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
  OR salary_hour_avg IS NOT NULL
)

SELECT CTE.*,
CASE 
    WHEN standardized_salary < 75_000 THEN 'Low'
    WHEN standardized_salary < 150_000 THEN 'Medium'
    ELSE 'High'
END AS salary_bucket
FROM CTE
ORDER BY standardized_salary desc
LIMIT 10;