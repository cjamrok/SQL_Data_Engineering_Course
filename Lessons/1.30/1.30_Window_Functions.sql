SELECT * FROM job_postings_fact
LIMIT 1000;

--Normal aggregation/group by

SELECT COUNT(*) FROM job_postings_fact;

--now with windows function (Over is the signal that its a window fxn)

SELECT
    job_id,
    COUNT(*) OVER ()
FROM job_postings_fact;

--core syntax

SELECT 
    job_id,
    COUNT(*) OVER (PARTITION BY job_id)
FROM job_postings_fact;

SELECT 
    job_id,job_title_short,
    COUNT(*) OVER (PARTITION BY job_title_short)
FROM job_postings_fact;

SELECT 
    job_id,job_title_short,salary_hour_avg,
    AVG(salary_hour_avg) OVER (PARTITION BY job_title_short)
FROM job_postings_fact;

SELECT 
    job_id,job_title_short,salary_hour_avg, company_id,
    AVG(salary_hour_avg) OVER (PARTITION BY job_title_short, company_id)
FROM job_postings_fact;

--Order By with Window Fxns, most often used with a rank function

SELECT 
    job_id,job_title_short,salary_hour_avg,
    RANK() OVER (ORDER BY salary_hour_avg desc) AS rank_hourly_salary
FROM job_postings_fact
ORDER BY salary_hour_avg DESC; --best practice is to use an order by after the FROM clause as well

--Running average of average salary hourly by job posted date (partition by and order by)
--the order by is what actually makes it a running avg. If you exclude that from the OVER() 
--then you just get avg salary by job_title_short
SELECT 
   job_posted_date,job_title_short,salary_hour_avg,
   AVG(salary_hour_avg) OVER (PARTITION BY job_title_short ORDER BY job_posted_date )
        AS "running_avg_hourly_by_title"
FROM job_postings_fact
WHERE salary_hour_avg is not null AND job_title_short = 'Data Engineer'
ORDER BY job_title_short, job_posted_date; 


--ranking of avg salary by job ID posting
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    ) AS avg_avg_salary
FROM
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC,
    job_title_short
LIMIT 10;

--More Rank Functions, plus Row Functions

--quick lesson, rank vs dense_rank, look where rank 9 becomes rank 10 to compare the two
SELECT 
    job_id,job_title_short,salary_hour_avg,
    RANK() OVER (ORDER BY salary_hour_avg desc) AS rank_hourly_salary
FROM job_postings_fact
ORDER BY salary_hour_avg DESC
LIMIT 140;

SELECT 
    job_id,job_title_short,salary_hour_avg,
    DENSE_RANK() OVER (ORDER BY salary_hour_avg desc) AS rank_hourly_salary
FROM job_postings_fact
ORDER BY salary_hour_avg DESC
LIMIT 140;

--Row Number Iteration
SELECT *, ROW_NUMBER() OVER (ORDER BY job_posted_date) FROM job_postings_fact
LIMIT 10;

--Navigation Windows Functions, Lag() and Lead()
--look one row back or one row ahead
--time based comparisons, in this case, how is the company's salary postings changing over time? 

SELECT
job_id,
company_id,
job_title,
job_title_short,
job_posted_date,
salary_year_avg,
LEAD(salary_year_avg) OVER (
    PARTITION BY company_id
    ORDER BY job_posted_date
) AS "next_posting_salary_by_company",
LAG(salary_year_avg) OVER (
    PARTITION BY company_id
    ORDER BY job_posted_date
) AS "previous_posting_salary_by_company",
salary_year_avg - LAG(salary_year_avg) OVER (
    PARTITION BY company_id
    ORDER BY job_posted_date
) AS "salary_change"
FROM job_postings_fact
WHERE salary_year_avg is not null
ORDER BY company_id, job_posted_date
limit 60;



