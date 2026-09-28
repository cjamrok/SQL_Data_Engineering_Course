https://youtu.be/ol9_NnC9-cc?si=LXLR4p7gEvn9Utv2&t=48631

![alt text](<../Images/Project 2 - Data Warehouse/Screenshot 2026-09-27 201158.png>)

![alt text](<../Images/Project 2 - Data Warehouse/Screenshot 2026-09-27 192835.png>)

![alt text](<../Images/Project 2 - Data Warehouse/Screenshot 2026-09-28 084356.png>)

![alt text](<../Images/Project 2 - Data Warehouse/Screenshot 2026-09-28 084412.png>)

![alt text](<../Images/Project 2 - Data Warehouse/Next Batch/Screenshot 2026-09-28 085033.png>)

## 03_create_flat_mart.sql is great use case for CTA! No Constraints needed, because all of the keys are managed on the data model side of things
![alt text](<../Images/Project 2 - Data Warehouse/Next Batch/Screenshot 2026-09-28 090256.png>)

![alt text](<../Images/Project 2 - Data Warehouse/Next Batch/Screenshot 2026-09-28 090415.png>)

[03_create_flat_mart.sql](03_create_flat_mart.sql)

![alt text](<../Images/Project 2 - Data Warehouse/Screenshot 2026-09-27 192909.png>)

![alt text](<../Images/Project 2 - Data Warehouse/Screenshot 2026-09-27 194104.png>)

## We'll start with creating our git branch setup:

![alt text](<../Images/Project 2 - Data Warehouse/Screenshot 2026-09-27 194154.png>)

![alt text](<../Images/Project 2 - Data Warehouse/Screenshot 2026-09-27 202415.png>)

## screenshot showing the git work after building out 01_ and 02_ and build_ sql files:
-- we commit our changes to the feature branch (working branch i would call it), then merge those (fast forward merge) to the develop/project-2 branch. Then, since we're finished with the feature/data-warehouse work and therefore the branch itself, we delete the branch. Develop project-2 is now ahead of the main branch. 

-- one line of code you can't see above the screenshot (switch to the higher tier branch that you're merging to, switching off of the branch that you're merging from) =  git switch develop/project-2
![alt text](<../Images/Project 2 - Data Warehouse/Screenshot 2026-09-27 213630.png>)

# Skills Demand Mart
--unlike the "denormalized" flat/wide table from 03_create_flat_mart.sql, this is a normalized star schema mart with one fact table and two dim tables

![alt text](<../Images/Project 2 - Data Warehouse/Next Batch/Screenshot 2026-09-28 092850.png>)

Our fact table will be an aggregation of the data warehouse, aggregated monthly by skill/by job_title_short. From there we get counts of job postings and other measures. 

Will help us answers questions such as - what is the top/highest demand skill in the market for each quarter? 

![alt text](<../Images/Project 2 - Data Warehouse/Next Batch/Screenshot 2026-09-28 093136.png>)

[04_create_skills_mart.sql](04_create_skills_mart.sql)

## Priority Mart - for batch loading / incremental loading, using merge
![alt text](<../Images/Project 2 - Data Warehouse/Next Batch/prio mart.png>)
--why build this priority mart? 




