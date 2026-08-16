# HEADING 1
## HEADING 2
### HEADING 3

Normal Text  
**Bold Text**  
*Italics*  
`This is code`  
- Bullet 1
- Bullet 2

1. numba 1
2. number 2

[Link Text](https://google.com)

![Alt Text](../1_EDA_Project\1_1_Project1_EDA.png)

```sql
SELECT 
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS median_salary,
    COUNT(jpf.salary_year_avg) AS demand_count,
    round((MEDIAN(jpf.salary_year_avg) * ln(count(jpf.salary_year_avg))/ 1_000_000), 2) AS optimal_score_v2,
    round(ln(count(jpf.salary_year_avg)), 1) AS log_demand_count
FROM job_postings_fact jpf
INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE
    jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = True
GROUP BY
    sd.skills
HAVING
    COUNT(sd.skills) >= 100
    AND demand_count > 0
ORDER BY
    optimal_score_v2 DESC
LIMIT 25;
```



