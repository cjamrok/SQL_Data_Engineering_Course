# SQL for Data Analytics – Intermediate Course + Project

🔗 **Course Link**  
[SQL for Data Analytics – Intermediate Course + Project](https://www.youtube.com/watch?v=QKIGsShyEsQ)

---

# What You Should Already Know From His Last Course

---

# Section #1

## Intro

We're using Microsoft's **Contoso** database and **Google Colab** for Jupyter Notebook / SQL execution.

### Notes

- `%%sql` allows SQL commands to be executed directly inside a Python Jupyter Notebook.
- **Contoso Database** sounds invaluable for practice.
	- Based on real-world business data.
	- Uses a classic **Star Schema**.
	- Contains:
		- One Fact Table
		- Multiple Dimension Tables

### Colab Setup Notebook

🔗 [Blank_SQL_Notebook.ipynb](https://colab.research.google.com/github/lukebarousse/Int_SQL_Data_Analytics_Course/blob/main/Resources/Blank_SQL_Notebook.ipynb#scrollTo=PyH_3RRYR5Je)

Open this notebook and run all Python cells.

The provided code:

- Sets up the Jupyter Notebook environment
- Installs required packages
- Loads the Contoso database
- Prepares the notebook for SQL execution

### Google Colab

🔗 [Google Colab](https://colab.research.google.com/)

### Contoso

Contoso =

---

## My Colab Copy

Couldn't get GitHub to cooperate so I am saving my Colab notebook here for future reference:

🔗 [Copy of Blank_SQL_Notebook.ipynb](https://colab.research.google.com/drive/1ulCFLpOX5KTFvRSL2jevNV_e7rnHCExT)

---

# Summary of What Was Covered
*(AI output based on your Google Colab code)*

---

# First Half of Course

---

## 1) Setup & Exploration

Use `information_schema` to discover tables and columns and understand the schema.

**Tip:** Keep dataset exploration queries handy. They are your bearings in a new database.

```sql
-- List user tables
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_schema, table_name;

-- Inspect columns in a table
SELECT *
FROM information_schema.columns
WHERE table_name = 'customer';
```

---

## 2) Select & Filter Basics

Preview data, then narrow with filters.

Casting dates can simplify comparisons.

```sql
-- Quick preview
SELECT * FROM sales
LIMIT 10;

-- Filter by date
SELECT orderdate,
       (netprice * quantity) AS net_revenue
FROM sales
WHERE orderdate::date >= '2020-01-01'
LIMIT 10;
```

---

## 3) Calculated Columns

Derive business metrics inline with expressions and aliases for clarity.

```sql
SELECT orderdate,
       netprice,
       quantity,
       (netprice * quantity) AS net_revenue
FROM sales
LIMIT 10;
```

---

## 4) Joins

Use `LEFT JOIN` to enrich facts with dimensions.

Use `customer.*` when you only want all columns from one side.

```sql
-- Enrich sales with customer details
SELECT s.orderdate,
       (s.netprice * s.quantity) AS net_revenue,
       c.*
FROM sales s
LEFT JOIN customer c
    ON c.customerkey = s.customerkey
WHERE s.orderdate::date >= '2020-01-01'
LIMIT 10;
```

```sql
-- Add product details
SELECT s.orderdate,
       (s.netprice * s.quantity) AS net_revenue,
       c.customerkey,
       p.productkey,
       p.productname,
       p.categoryname
FROM sales s
LEFT JOIN customer c
    ON c.customerkey = s.customerkey
LEFT JOIN product p
    ON p.productkey = s.productkey
WHERE s.orderdate::date >= '2020-01-01'
LIMIT 10;
```

---

## 5) Conditional Logic (CASE)

Bucket or label records for segmentation.

```sql
-- Revenue band
SELECT s.orderdate,
       (s.netprice * s.quantity) AS net_revenue,
       CASE
           WHEN (s.netprice * s.quantity) > 1000 THEN 'high'
           ELSE 'low'
       END AS revenue_band
FROM sales
ORDER BY net_revenue DESC
LIMIT 100;
```

```sql
-- Order type classification
SELECT orderdate,
       quantity,
       netprice,
       CASE
           WHEN quantity >= 2 AND netprice >= 100 THEN 'Multiple High Value Order'
           WHEN quantity = 1 AND netprice >= 100 THEN 'Single High Value Order'
           WHEN quantity >= 2 THEN 'Multiple Standard Order'
           ELSE 'Single Standard Order'
       END AS order_type
FROM sales
LIMIT 1000;
```

---

## 6) Aggregations & Grouping

Summarize with:

- `SUM()`
- `AVG()`
- `MIN()`
- `MAX()`
- `COUNT(DISTINCT)`

```sql
-- Unique customers per day
SELECT s.orderdate,
       COUNT(DISTINCT s.customerkey) AS total_customers
FROM sales s
WHERE s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY s.orderdate
ORDER BY s.orderdate;
```

---

## 7) Pivoting With CASE

Turn rows into columns by conditionally aggregating values.

```sql
SELECT s.orderdate,
       COUNT(DISTINCT s.customerkey) AS total_customers,
       COUNT(DISTINCT CASE WHEN c.continent = 'Europe' THEN s.customerkey END) AS eu_customers,
       COUNT(DISTINCT CASE WHEN c.continent = 'North America' THEN s.customerkey END) AS na_customers
FROM sales s
LEFT JOIN customer c
    ON s.customerkey = c.customerkey
WHERE s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY s.orderdate
ORDER BY s.orderdate;
```

---

## 8) Percentiles & Medians

Use `PERCENTILE_CONT()` for medians and quartiles.

```sql
-- Overall median
SELECT PERCENTILE_CONT(0.50)
       WITHIN GROUP (ORDER BY (netprice * quantity * exchangerate)) AS median_revenue
FROM sales;
```

```sql
-- Median by category
SELECT p.categoryname,
       PERCENTILE_CONT(0.50)
       WITHIN GROUP (ORDER BY (s.netprice * s.quantity * s.exchangerate)) AS median_revenue
FROM sales s
LEFT JOIN product p
    ON p.productkey = s.productkey
GROUP BY p.categoryname;
```

---

## 9) Common Table Expressions (CTEs)

Stage intermediate logic for readability.

```sql
WITH my_median AS (
    SELECT PERCENTILE_CONT(0.50)
           WITHIN GROUP (ORDER BY (s.netprice * s.quantity * s.exchangerate)) AS median
    FROM sales s
)
SELECT p.categoryname,
       SUM(CASE
               WHEN (s.netprice * s.quantity * s.exchangerate) > my_median.median
               THEN (s.netprice * s.quantity * s.exchangerate)
           END) AS high_revenue
FROM sales s
LEFT JOIN product p
    ON p.productkey = s.productkey,
    my_median
GROUP BY p.categoryname;
```

---

## 10) Date & Time Functions

Truncate and format for reporting.

Compute intervals for SLAs.

```sql
-- Month bucket
SELECT DATE_TRUNC('month', orderdate)::date AS month_start,
       TO_CHAR(orderdate, 'YYYY-MM') AS month_label,
       COUNT(DISTINCT customerkey) AS unique_customers
FROM sales
GROUP BY month_start, month_label
ORDER BY month_start;
```

```sql
-- Rolling 5 years
SELECT CURRENT_DATE,
       s.orderdate
FROM sales s
WHERE s.orderdate >= CURRENT_DATE - INTERVAL '5 years';
```

---

## 11) Window Functions

Compute peer-aware metrics without collapsing rows.

```sql
SELECT customerkey,
       AVG(quantity * netprice * exchangerate) OVER() AS avg_all,
       AVG(quantity * netprice * exchangerate) OVER (PARTITION BY customerkey) AS avg_per_customer
FROM sales
LIMIT 10;
```

---

## 12) Cohort Analysis

Define cohorts by first purchase year.

```sql
SELECT DISTINCT customerkey,
       EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM sales;
```

---

## 13) Ranking

Use:

- `ROW_NUMBER()` for unique sequence
- `RANK()` when ties should introduce gaps

```sql
SELECT customerkey,
       COUNT(*) AS total_orders,
       ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rn,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM sales
GROUP BY customerkey
LIMIT 10;
```

---

## 14) Lag / Lead & MoM Growth

Access prior or next rows to calculate change over time.

```sql
WITH monthly_revenue AS (
    SELECT TO_CHAR(orderdate, 'YYYY-MM') AS month,
           SUM(quantity * netprice * exchangerate) AS net_revenue
    FROM sales
    WHERE EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY month
)
SELECT month,
       net_revenue,
       LAG(net_revenue) OVER (ORDER BY month) AS prev_month,
       ROUND((net_revenue - LAG(net_revenue) OVER (ORDER BY month)) /
             NULLIF(LAG(net_revenue) OVER (ORDER BY month), 0) * 100, 2) AS mom_growth_pct
FROM monthly_revenue;
```

---

## 15) Frame Clauses

Control how much of the window is included in moving calculations.

```sql
WITH monthly_sales AS (
    SELECT TO_CHAR(orderdate, 'YYYY-MM') AS month,
           SUM(quantity * netprice * exchangerate) AS net_revenue
    FROM sales
    WHERE EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY month
)
SELECT month,
       net_revenue,
       AVG(net_revenue) OVER (
           ORDER BY month
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS mov_avg_3m
FROM monthly_sales;
```

---

## Tips & Gotchas

- Mixing `GROUP BY` with window functions?
	- Aggregate in a subquery or CTE first.
- PostgreSQL vs SQL Server:
	- `EXTRACT` vs `DATEPART`
	- `::cast` vs `CAST()`
	- `INTERVAL` syntax differs
- Prefer CTEs for readability and modular logic.

---

# Second Half of Course

Started by installing:

- PostgreSQL
- DBeaver

on my local machine.

Luke pointed to a PostgreSQL `.sql` database file which we loaded into PGAdmin with a single script:

```sql
\i 'Users/uia09337/Desktop/Desktop/SQL/PostGreSQL/Microsoft Contoso DB for Practice/contoso_100k.sql'
```

### Notes

- Would like to replicate this process and use the same Contoso database but load it into SSMS for practice/testing.
- Once this script executes, the Contoso database is loaded onto a local PostgreSQL server instance.
- DBeaver can then connect to it, which we did.

---

## Project Repository

This folder contains:

- All 3 project SQL queries
- Test scripts
- Throwaway scripts written during learning
- First GitHub repository

```text
C:\Users\uia09337\AppData\Roaming\DBeaverData\workspace6\Luke_Barousse_Intermediate_SQL_Training_Course
```

🔗 [GitHub Repository](https://github.com/cjamrok/Luke_Barousse_Intermediate_SQL_Training_Course)

---

# Second Half AI Output Summary

---

## Window Functions

Window functions are like calculating a variable for future calculations and storing it in its own column for convenient usage.

### Important

If you want to mix:

- Window Functions
- Aggregations

You generally need a CTE.

**Word to the wise:** use a CTE if you want to mix window functions with aggregation.

### Execution Order

When using a window function:

```sql
WHERE
```

is executed **before** the window function calculation.

If you want filtering applied afterward, use a CTE to control timing.

---

## Frame Clauses Inside Window Functions

Notes and examples here.

---

## Data Cleaning in SQL

### NULL Handling

#### COALESCE

If value is NULL, return another value instead.

#### NULLIF

If value equals X, return NULL instead.

---

## Text Cleaning

Notes and examples here.

---

## Query Optimization

### Explain Plans

SSMS:

```text
Ctrl + L
```

Generates an execution plan.

### DBeaver

Used:

```sql
EXPLAIN ANALYZE
```

to generate execution plans.

### Notes

- He said advanced techniques should generally be left to Database Administrators.
- "Ask AI to optimize your queries/views."

---

## Intermediate Query Optimization

### General Rules

Limit the number of columns used in:

- GROUP BY
- JOIN
- ORDER BY

when possible.

### Join Performance

Generally:

```text
INNER JOIN
```

is the most optimized join type.

### Reduce Usage Of

- GROUP BY
- JOIN
- ORDER BY

when possible.

Basically, don't use all your new SQL skills lol.

---

### Personal Observation

Based on a query he wrote:

I think if you're smart, you can use window functions to avoid GROUP BYs.

Which I assume are more optimized than the GROUP BY that I did to pull:

```sql
MAX(OrderDate)
```

---

### Cool Trick

Try to limit your GROUP BY columns whenever possible.

Originally:

```sql
SELECT
    Country,
    Age,
    GivenName,
    Surname
```

were all included in the GROUP BY.

Instead:

- Apply `MAX()` to those fields in the SELECT statement.
- Remove them from the GROUP BY.
- They can still appear in the final output.

---

# GitHub

If you publish to GitHub:

- A local repository is automatically initialized.
- You cannot have a central repository without a corresponding local repository.

### Initialize Repository

Equivalent to:

```bash
git init
```

Creates hidden `.git` files and begins version control.

---

## Unhide Hidden Local Repository Files

Notes here.

---

## Core Git Concepts

### Pull

If changes exist on GitHub:

- Created by you
- Created by collaborators

You can pull them into your local repository.

Your local files will update accordingly.

### Push

The reverse of Pull.

Pushes local commits to GitHub.

### Commit

Commits save changes to your **local repository only**.

After committing:

- Choose **Sync Changes** in VS Code
- Push changes to GitHub
- Update the central repository

---

## Repository States

### 1. Everything In Sync

- No local changes
- No remote changes

### 2. File Added Locally

- File exists in folder
- Not added to repository

### 3. File Added To Repository

- Added
- Not committed

#### Next Step

1. Commit the changes (hello world file addition)

Check Git status again.

Local branch/repository is ahead of remote repository.

Need to push the commit to GitHub.

Now in sync.

---

# Other Notes, Tips & Tricks

## VS Code Multi-Cursor

### Shortcut

```text
Ctrl + Shift + L
```

### What It Does

Select every instance of a highlighted string of code and edit all occurrences simultaneously.

Really cool. 🚀
