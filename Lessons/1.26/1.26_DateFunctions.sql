SELECT
    job_posted_date,
    job_posted_date::DATE AS date,
    job_posted_date::TIME AS time,
    job_posted_date::TIMESTAMP AS timestamp,
    job_posted_date::TIMESTAMPTZ AS timestamptz
FROM data_jobs.job_postings_fact
LIMIT 10;

--remember that "::" is the postgres casting operator

SELECT 
job_posted_date,
EXTRACT(YEAR FROM job_posted_date) as job_posted_year,
EXTRACT(DAY FROM job_posted_date) as job_posted_day,
FROM data_jobs.job_postings_fact;

SELECT
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year,
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count
FROM data_jobs.job_postings_fact
WHERE job_title_short = 'Data Engineer'
GROUP BY
    EXTRACT(YEAR FROM job_posted_date),
    EXTRACT(MONTH FROM job_posted_date)
ORDER BY COUNT(job_id) desc;


--Round a date field to level of detail of your choosing. Round to the first date of the month, to the hour, whatever
SELECT
job_posted_date,
DATE_TRUNC('month',job_posted_date)
FROM data_jobs.job_postings_fact
ORDER BY RANDOM()
LIMIT 10;

--Round a date field to level of detail of your choosing. Round to the first date of the month, to the hour, whatever
SELECT
    job_posted_date,
    DATE_TRUNC('year', job_posted_date) AS truncated_year,
    DATE_TRUNC('quarter', job_posted_date) AS truncated_quarter,
    DATE_TRUNC('month', job_posted_date) AS truncated_month,
    DATE_TRUNC('week', job_posted_date) AS truncated_week,
    DATE_TRUNC('day', job_posted_date) AS truncated_day,
    DATE_TRUNC('hour', job_posted_date) AS truncated_hour
FROM data_jobs.job_postings_fact
ORDER BY RANDOM()
LIMIT 10;

--for SSMS (copilot results)
--DATEADD(month, DATEDIFF(month, 0, job_posted_date), 0)

--our column is formatted as timestamp not timestamptz, so this won't work. 
SELECT
    '2026-01-01 00:00+00'::TIMESTAMPTZ AT TIME ZONE 'EST';


--solution is to use "AT TIME ZONE". This will convert the data type. From there you can use "AT TIME ZONE" again to convert it to the time zone of your choosing. But YOU HAVE TO CONVERT TO UTC FIRST AS A BASELINE (+0 prime meridian time)
SELECT
    job_posted_date AT TIME ZONE 'UTC'
    FROM data_jobs.job_postings_fact;

SELECT
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    FROM data_jobs.job_postings_fact;


