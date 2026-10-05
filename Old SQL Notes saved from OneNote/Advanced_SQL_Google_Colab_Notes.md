# Google CoLab Backup

> **Sunday, January 4, 2026**  
> **7:12 PM**

*after completing 1st half of the advanced SQL Luke course*

---

## Google Colab / PostgreSQL Setup

```python
import sys
import pandas as pd
import matplotlib.pyplot as plt
%matplotlib inline

# If running in Google Colab, install PostgreSQL and restore the database
if 'google.colab' in sys.modules:
    # Update package installer
    !sudo apt-get update -qq > /dev/null 2>&1

    # Install PostgreSQL
    !sudo apt-get install postgresql -qq > /dev/null 2>&1

    # Start PostgreSQL service (suppress output)
    !sudo service postgresql start > /dev/null 2>&1

    # Set password for the 'postgres' user to avoid authentication errors (suppress output)
    !sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'password';" > /dev/null 2>&1

    # Create the 'colab_db' database (suppress output)
    !sudo -u postgres psql -c "CREATE DATABASE contoso_100k;" > /dev/null 2>&1

    # Download the PostgreSQL .sql dump
    !wget -q -O contoso_100k.sql https://github.com/lukebarousse/Int_SQL_Data_Analytics_Course/releases/download/v.0.0.0/contoso_100k.sql

    # Restore the dump file into the PostgreSQL database (suppress output)
    !sudo -u postgres psql contoso_100k < contoso_100k.sql > /dev/null 2>&1

    # Shift libraries from ipython-sql to jupysql
    !pip uninstall -y ipython-sql > /dev/null 2>&1
    !pip install jupysql > /dev/null 2>&1

# Load the sql extension for SQL magic
%load_ext sql

# Connect to the PostgreSQL database
%sql postgresql://postgres:password@localhost:5432/contoso_100k

# Enable automatic conversion of SQL results to pandas DataFrames
%config SqlMagic.autopandas = True

# Disable named parameters for SQL magic
%config SqlMagic.named_parameters = "disabled"

# Display pandas number to two decimal places
pd.options.display.float_format = '{:.2f}'.format
```

---

## SQL Practice Notes

```sql
%%sql
```

```sql
%%sql
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_schema, table_name;
```

> **Note**
>
> realizing that this is running PostGreSQL, when I would rather run SSMS. Lets see if Gemini can help:

> **Note**
>
> didn't work, but was worth a shot! We'll stick with PostGreSQL for this training, and I will have to adapt when it comes time to
> apply what I learned in SSMS.

```sql
%%sql

SELECT * FROM Sales
limit 10
```

```sql
%%sql
SELECT *
FROM information_schema.columns
WHERE table_name = 'customer'
```

### Calculate net revenue

```sql
%%sql

SELECT orderdate,netprice,quantity, (netprice * quantity) as net_revenue FROM sales
limit 10
```

```sql
%%sql

SELECT orderdate, (netprice * quantity) as net_revenue FROM sales
WHERE orderdate::date >= '2020-01-01'
limit 10
```

### join refresher

```sql
%%sql

SELECT orderdate, (netprice * quantity) as net_revenue, customer.customerkey, geoareakey, longitude, latitude FROM sales
left join customer
    ON customer.customerkey = sales.customerkey
WHERE orderdate::date >= '2020-01-01'

limit 10
```

> **Note**
>
> same as last cell but with new lesson learned, use c.* to specify that you want all of hte columns from your joined table,
> but not all of hte columns period!

```sql
%%sql

SELECT orderdate, (netprice * quantity) as net_revenue, customer.* FROM sales
left join customer
    ON customer.customerkey = sales.customerkey
WHERE orderdate::date >= '2020-01-01'

limit 10
```

```sql
%%sql

SELECT orderdate, (netprice * quantity) as net_revenue, customer.customerkey,
customer.continent,customer.givenname,customer.surname,customer.countryfull,
product.productkey, product.productname, product.categoryname, product.subcategoryname FROM sales
left join customer
    ON customer.customerkey = sales.customerkey
left join product
    ON product.productkey = sales.productkey
WHERE orderdate::date >= '2020-01-01'

limit 10
```

```sql
%%sql

SELECT orderdate, (netprice * quantity) as net_revenue, customer.customerkey,
customer.continent,customer.givenname,customer.surname,customer.countryfull,
product.productkey, product.productname, product.categoryname, product.subcategoryname,
case
  WHEN (netprice * quantity) > 1000 THEN 'high'
  ELSE 'low'
END as my_case

FROM sales
left join customer
    ON customer.customerkey = sales.customerkey
left join product
    ON product.productkey = sales.productkey
WHERE orderdate::date >= '2020-01-01'
ORDER BY (netprice * quantity) desc

limit 10000
```

### next chapter (pivoting)

```sql
%%sql
SELECT
    orderdate,
    COUNT(DISTINCT customerkey) AS total_customers
FROM
    sales
WHERE
    orderdate BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY
    orderdate
ORDER BY
    orderdate
```

```sql
%%sql
SELECT
    s.orderdate,
    COUNT(DISTINCT s.customerkey) AS total_customers,
    -- next line is where the pivot magic starts to happen
    COUNT(DISTINCT CASE WHEN c.continent = 'Europe'
    THEN s.customerkey END) as eu_pivot,
    COUNT(DISTINCT CASE WHEN c.continent = 'North America'
    THEN s.customerkey END) as na_pivot,
    COUNT(DISTINCT CASE WHEN c.continent = 'Australia'
    THEN s.customerkey END) as aus_pivot
FROM
    sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
WHERE
    s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY
    s.orderdate
ORDER BY
    s.orderdate
```

```sql
%%sql

SELECT p.categoryname,
-- SUM(s.exchangerate * s.netprice * s.quantity) as net_revenue
SUM(CASE WHEN s.orderdate BETWEEN '2022-01-01' and '2022-12-31' then s.quantity * s.netprice * s.exchangerate ELSE 0 END) as total_revenue_2022,
SUM(CASE WHEN s.orderdate BETWEEN '2023-01-01' and '2023-12-31' then s.quantity * s.netprice * s.exchangerate ELSE 0 END) as total_revenue_2023
FROM sales as s
  left join product as p
    ON p.productkey = s.productkey
 group by p.categoryname

order by p.categoryname
```

### Practicing pivot casing one more time

```sql
%%sql

SELECT p.categoryname,
SUM(CASE WHEN s.orderdate between '2022-01-01' and '2022-12-31' then (s.quantity
* s.netprice * s.exchangerate) else 0 end) as revenue_2022,
SUM(CASE WHEN s.orderdate between '2023-01-01' and '2023-12-31' then (s.quantity
* s.netprice * s.exchangerate) else 0 end) as revenue_2023
FROM sales as s
  left join product as p
    ON p.productkey = s.productkey
GROUP BY p.categoryname
```

### using Gemini to add in min and max for me, per Lukes instructions

```sql
%%sql

SELECT p.categoryname,
AVG(CASE WHEN s.orderdate between '2022-01-01' and '2022-12-31' then (s.quantity
* s.netprice * s.exchangerate) else 0 end) as avg_revenue_2022,
MIN(CASE WHEN s.orderdate between '2022-01-01' and '2022-12-31' then (s.quantity
* s.netprice * s.exchangerate) else 0 end) as min_revenue_2022,
MAX(CASE WHEN s.orderdate between '2022-01-01' and '2022-12-31' then (s.quantity
* s.netprice * s.exchangerate) else 0 end) as max_revenue_2022,
AVG(CASE WHEN s.orderdate between '2023-01-01' and '2023-12-31' then (s.quantity
* s.netprice * s.exchangerate) else 0 end) as avg_revenue_2023,
MIN(CASE WHEN s.orderdate between '2023-01-01' and '2023-12-31' then (s.quantity
* s.netprice * s.exchangerate) else 0 end) as min_revenue_2023,
MAX(CASE WHEN s.orderdate between '2023-01-01' and '2023-12-31' then (s.quantity
* s.netprice * s.exchangerate) else 0 end) as max_revenue_2023
FROM sales as s
  left join product as p
    ON p.productkey = s.productkey
GROUP BY p.categoryname
ORDER BY p.categoryname
```

### just some practice to validate the max revenue results in the cell above

```sql
%%sql

SELECT s.*, s.netprice * s.quantity * s.exchangerate as netrevenue, p.categoryname
FROM sales s
left join product as p
  on p.productkey = s.productkey
WHERE p.categoryname = 'Audio'
ORDER BY (s.netprice * s.quantity * s.exchangerate) desc
limit 10
```

> **Note**
>
> median
> what this is doing is taking all of the netprice numbers from the table
> and ranking/ordering them, then finding the value in the middle (.50)

```sql
%%sql
SELECT
    PERCENTILE_CONT(.50) WITHIN GROUP (ORDER BY netprice) AS median_price
FROM
    sales
```

### median sales by category

```sql
%%sql

SELECT p.categoryname,
PERCENTILE_CONT(0.5) WITHIN GROUP
  (ORDER BY s.netprice * s.quantity * s.exchangerate)
as median_price
FROM sales s
left join product as p
  ON p.productkey = s.productkey
GROUP BY p.categoryname
ORDER BY p.categoryname
```

### median sales by category, 2022 vs 2023

```sql
%%sql

SELECT p.categoryname,
PERCENTILE_CONT(.5) WITHIN GROUP
  (ORDER BY (CASE WHEN s.orderdate between '2022-01-01' and '2022-12-31'
  then (s.netprice * s.quantity * s.exchangerate) end))
as median_price_2022,
PERCENTILE_CONT(.5) WITHIN GROUP
  (ORDER BY (CASE WHEN s.orderdate between '2023-01-01' and '2023-12-31'
  then (s.netprice * s.quantity * s.exchangerate) end))
as median_price_2023
FROM sales s
left join product as p
  ON p.productkey = s.productkey
GROUP BY p.categoryname
ORDER BY p.categoryname
```

```sql
%%sql

SELECT orderdate, quantity, netprice,
CASE
  WHEN quantity >=2 and netprice >= 100 then 'Multiple High Value Order'
  WHEN quantity = 1 and netprice >= 100 then 'Single High Value Order'
  WHEN quantity >=2 then 'Multiple Standard Order'
  ELSE 'Single Standard Order'
END as order_type
FROM Sales
limit 1000
```

> **Note**
>
> using CTE to calculate median value and essentially using it as a variable for our pivoting/CASE Whens

```sql
%%sql

WITH my_median as (
SELECT
PERCENTILE_CONT(0.50) WITHIN GROUP
  (ORDER BY (s.netprice * s.quantity * s.exchangerate))
  as median

FROM sales as s
  left join product as p on p.productkey = s.productkey

WHERE orderdate between '2022-01-01' and '2023-12-31'
)

select p.categoryname,
    SUM(CASE WHEN
        s.orderdate between '2022-01-01' and '2022-12-31' and
        (s.netprice * s.quantity * s.exchangerate) > my_median.median
        THEN (s.netprice * s.quantity * s.exchangerate) end) as highrevenue_2022,
    SUM(CASE WHEN
        s.orderdate between '2022-01-01' and '2022-12-31' and
        (s.netprice * s.quantity * s.exchangerate) <= my_median.median
        THEN (s.netprice * s.quantity * s.exchangerate) end) as lowrevenue_2022,
    SUM(CASE WHEN
        s.orderdate between '2023-01-01' and '2023-12-31' and
        (s.netprice * s.quantity * s.exchangerate) > my_median.median
        THEN (s.netprice * s.quantity * s.exchangerate) end) as highrevenue_2023,
    SUM(CASE WHEN
        s.orderdate between '2023-01-01' and '2023-12-31' and
        (s.netprice * s.quantity * s.exchangerate) <= my_median.median
        THEN (s.netprice * s.quantity * s.exchangerate) end) as lowrevenue_2023

FROM sales as s
  left join product as p ON s.productkey = p.productkey,
  my_median --I guess you include the name of the CTE in the FROM statement as a separate entry!

  group by p.categoryname
```

### quartiling!

```sql
%%sql

WITH percentile AS (
    SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP
      (ORDER BY (s.netprice * s.quantity * s.exchangerate))
      as revenue_25th_percentile,
    PERCENTILE_CONT(0.5) WITHIN GROUP
      (ORDER BY (s.netprice * s.quantity * s.exchangerate))
      as revenue_median,
    PERCENTILE_CONT(0.75) WITHIN GROUP
      (ORDER BY (s.netprice * s.quantity * s.exchangerate))
      as revenue_75th_percentile

    FROM sales as s
      left join product as p on p.productkey = s.productkey

    WHERE orderdate between '2022-01-01' and '2023-12-31'
)

 select p.categoryname,
   SUM((s.netprice * s.quantity * s.exchangerate)) as total_revenue,
    CASE
    WHEN
       -- s.orderdate between '2022-01-01' and '2022-12-31' and
        (s.netprice * s.quantity * s.exchangerate) <= percentile.revenue_25th_percentile
        THEN 'LOW'
    WHEN (s.netprice * s.quantity * s.exchangerate) > percentile.revenue_75th_percentile
        THEN 'HIGH'
    ELSE 'MID'
        END as revenue_tier

FROM sales as s
  left join product as p ON s.productkey = p.productkey,
  percentile

  group by p.categoryname, revenue_tier
```

### now getting to date funcations

```sql
%%sql

SELECT orderdate
FROM sales
order by random()
limit 10
```

### now getting to date funcations

```sql
%%sql

SELECT
DATE_TRUNC('month',orderdate) as month_timestamp,
DATE_TRUNC('month',orderdate)::date as month_only, --using cast operator to change format to date to clean it up. in SSMS it's a CAST( fxn
count(distinct customerkey) as unique_customers
FROM sales
group by month_only, month_timestamp
--
```

```sql
%%sql
SELECT
    orderdate,
    TO_CHAR(orderdate, 'YYYY-MM')
FROM sales
ORDER BY RANDOM()
LIMIT 10
```

```sql
%%sql

SELECT
DATE_TRUNC('month',orderdate) as month_timestamp,
DATE_TRUNC('month',orderdate)::date as month_only, --using cast operator to change format to date to clean it up. in SSMS it's a CAST( fxn
TO_CHAR(orderdate,'YYYY-MM') as even_easier_way,
count(distinct customerkey) as unique_customers
FROM sales
group by month_only, month_timestamp,even_easier_way
```

> **Note**
>
> he likes to use the extract function, but not available in SSMS. Use DATEPART
> or YEAR() MONT() DAY()

```sql
%%sql
SELECT
    orderdate,
    EXTRACT(YEAR FROM orderdate) AS extract_year,
    EXTRACT(MONTH FROM orderdate) AS extract_month,
    EXTRACT(DAY FROM orderdate) AS extract_day
FROM sales
ORDER BY RANDOM()
LIMIT 10
```

### rolling time filter, any data in Y-5

```sql
%%sql
SELECT
    CURRENT_DATE, -- variable built into PostGreSQL that can be called
    s.orderdate,
    p.categoryname,
    SUM(s.quantity * s.netprice * s.exchangerate) AS net_revenue
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
WHERE
    EXTRACT(YEAR FROM orderdate) >= EXTRACT(YEAR FROM CURRENT_DATE) - 5
GROUP BY
    s.orderdate,
    p.categoryname
ORDER BY
    s.orderdate,
    p.categoryname
```

> **Note**
>
> rolling time filter, any data in the last five years, five years and one day excluded

```sql
%%sql
SELECT
    CURRENT_DATE,
    s.orderdate
FROM sales s
WHERE orderdate >= CURRENT_DATE - INTERVAL '5 years'
```

### age and time intervals

```sql
%%sql

SELECT orderdate,
deliverydate,
date_part('year', orderdate) as order_year,
AGE(deliverydate,orderdate) as processing_time
--AGE data type is interval, not integer. Need to convert before averaging.
FROM sales
ORDER BY random()
limit 100
```

### age and time intervals

```sql
%%sql

SELECT
CAST(date_part('year', orderdate) AS INTEGER) as order_year,
ROUND(AVG(EXTRACT(DAY FROM AGE(deliverydate,orderdate))),2) as avg_processing_time
FROM sales
GROUP BY order_year
ORDER BY order_year
```

### Window functions sound SUPER useful

```sql
%%sql

SELECT
    customerkey,
    orderkey,
    linenumber,
    (quantity * netprice * exchangerate) as net_revenue,
    AVG(quantity * netprice * exchangerate) OVER() as avg_net_revenue_all_orders,
    AVG(quantity * netprice * exchangerate) OVER(PARTITION BY customerkey)
    as avg_net_revenue_this_customer
FROM sales
ORDER BY customerkey
LIMIT 10
```

> **Note**
>
> window function inside of a subquery
> subquery makes it clean b/c you can define all of the inputs you'll need
> in the subquery, and then build formulas based off of them in the outlying query

```sql
%%sql
SELECT *,
    100 * net_revenue / daily_net_revenue AS pct_daily_revenue
FROM (
    SELECT
        orderdate,
        orderkey * 10 + linenumber AS order_line_item,
        (quantity * netprice * exchangerate) AS net_revenue,
        SUM(quantity * netprice * exchangerate) OVER(PARTITION BY orderdate) AS daily_net_revenue
    FROM sales
) AS revenue_by_day
```

### Cohorts, another word for segmentation

### show first year each customer placed their very first order

```sql
%%sql
SELECT DISTINCT
    customerkey,
    EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM sales
```

> **Note**
>
> CTE with windows function.
> I guess you define the cohort year by customer in the CTE, and then join that with
> the sales data? I think if you had done it all inside one query (no CTE) then
> you would have had duplicate rows. But the CTE has no duplicates, and then you
> basically load all the sales data but pull in the cohort min year with lookup

```sql
%%sql
WITH yearly_cohort AS (
    SELECT DISTINCT
        customerkey,
        EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
    FROM sales
)
SELECT *
FROM sales s
LEFT JOIN yearly_cohort y ON s.customerkey = y.customerkey
limit 10
```

> **Note**
>
> practicing here, this wasnt as easy as I thought I needed AI's help here.
> was trying to use the windows function to display median price in one column and
> then each customer's specific median price in the other

```sql
%%sql

WITH overall_median AS (
  SELECT PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY (netprice * quantity * exchangerate)) as median_price_all
  FROM Sales
),
customer_medians AS (
  SELECT
    s.customerkey,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY (s.netprice * s.quantity * s.exchangerate)) as median_price_per_customer
  FROM Sales s
  GROUP BY s.customerkey
)

SELECT
  cm.customerkey,
  cm.median_price_per_customer,
  om.median_price_all
FROM customer_medians cm
CROSS JOIN overall_median om;
```

```sql
%%sql

SELECT
    s.customerkey,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY (s.netprice * s.quantity * s.exchangerate)) as median_price_per_customer
  FROM Sales s
  GROUP BY s.customerkey
```

> **Note**
>
> practicing something simpler
> lets try displaying total revenue across all customers alongside total revenue per cust

```sql
%%sql
/*
SELECT
SUM((s.netprice*s.quantity*s.exchangerate)) as net_revenue,
s.customerkey,
SUM()
FROM sales s
group by s.customerkey
*/

SELECT
customerkey,
sum((s.netprice*s.quantity*s.exchangerate)) OVER(PARTITION BY orderdate) as net_revenue_daily_total,
sum((s.netprice*s.quantity*s.exchangerate)) OVER(PARTITION BY customerkey, orderdate) as net_revenue_by_customer
FROM sales s
-- group by customerkey - it won't work with groupbys, it messes up the net_revenue_total
limit 100
```

### cohort practice, window functions are kinda tricky

```sql
%%sql

WITH cohort AS (
SELECT distinct customerkey,
EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) as cohort_year
FROM sales)

SELECT
cohort.cohort_year,
SUM((s.netprice*s.quantity*s.exchangerate)) as net_revenue,
EXTRACT(YEAR FROM orderdate) as purchase_year
FROM sales s
left join cohort
  ON cohort.customerkey = s.customerkey
GROUP BY cohort_year, EXTRACT(YEAR FROM orderdate)
```

> **Note**
>
> aggregation with windows functions
> number of unique customers / year

```sql
%%sql

WITH yearly_cohort AS (
SELECT
  distinct customerkey,
  EXTRACT(YEAR FROM min(orderdate) over(partition by customerkey)) as cohort_year,
  EXTRACT(YEAR FROM orderdate) as purchase_year
FROM sales)

SELECT distinct cohort_year,
purchase_year,
COUNT(customerkey) OVER (PARTITION BY purchase_year, cohort_year)
FROM yearly_cohort
-- unique count of customers that made a purcahse in year purchase_year AND have a cohort year = to cohort_year
ORDER BY cohort_year,
purchase_year
```

```sql
%%sql

WITH customer_orders AS (
    SELECT
        customerkey,
        quantity * netprice * exchangerate AS order_value,
        COUNT(*) OVER(PARTITION BY customerkey) AS total_orders
    FROM sales
)
SELECT
    customerkey,
    total_orders,
    AVG(order_value) AS avg_net_revenue_per_order,
    SUM(order_value) as sum_net_revenue
FROM customer_orders
GROUP BY
    customerkey,
    total_orders
```

> **Note**
>
> find customerkey, their cohort_year, the total revenue over their lifetime (customer LTV or "Lifetime value"), and a window function of avg_LTV_per_cohort for basis of comparison

```sql
%%sql

WITH COHORTS AS (
SELECT distinct customerkey,
EXTRACT(YEAR FROM MIN(orderdate) OVER(PARTITION BY customerkey)) as cohort_year
FROM sales)

SELECT
  COHORTS.customerkey,
  cohort_year,
  SUM(netprice*quantity*exchangerate) as customer_ltv,
  AVG(SUM(netprice*quantity*exchangerate)) OVER(PARTITION BY cohort_year) as avg_LTV_per_cohort
FROM sales
left join COHORTS on COHORTS.customerkey = sales.customerkey
GROUP BY COHORTS.customerkey,cohort_year
```

> **Note**
>
> exact same query results as above cell, but arranged differently. Best practice is this cell here, where only the window function is done outside of the CTE to avoid the group by conflict
> in the last cell I put the window function AND the customer_ltv outside the CTE, but the net result was the same

```sql
%%sql

WITH yearly_cohort AS (
    SELECT
        customerkey,
        EXTRACT(YEAR FROM MIN(orderdate)) AS cohort_year,
        SUM(quantity * netprice * exchangerate) AS customer_ltv
    FROM
        sales
    GROUP BY
        customerkey
)
SELECT *,
  AVG(customer_ltv) OVER (PARTITION BY cohort_year) as avg_LTV_per_cohort
FROM
    yearly_cohort
```

### how to use order by in a window function, can be used inside

```sql
%%sql

SELECT
customerkey,
orderdate,
quantity * netprice * exchangerate as net_revenue,
COUNT(orderdate) OVER(
  PARTITION BY customerkey
  ORDER BY orderdate -- order by becomes part of hte partition by criteria too! Look at customerkey # 180 in the output. its a running count with the order by included,
                      -- but its just a total count if you comment out the order by and re-execute
) as running_order_count,
AVG(quantity * netprice * exchangerate) OVER(
  PARTITION BY customerkey
  ORDER BY orderdate
) as avg_running_order_revenue
FROM sales
```

### Rank window functions - rownumber

```sql
%%sql

SELECT
ROW_NUMBER() OVER(
  ORDER BY orderdate,orderkey,linenumber
) as row_num
,*
FROM sales
limit 10
```

### same as above but rownumber restarts each day (Partition By)

```sql
%%sql

SELECT
ROW_NUMBER() OVER(
  PARTITION BY orderdate
  ORDER BY orderdate,orderkey,linenumber
) as row_num
,*
FROM sales
limit 100
```

> **Note**
>
> i guess mixing a group by and window fxn works here because it's just a row_number() and not a SUM or AVG or anything. For a SUM to work here you would have to pull all of th
> inputs for that sum fxn into the group by, which effectively cancels out the group by since they're at the grain Level of Detail.
> but according to AI, the row_number() works because it can perform the groupby first, and then count the number of rows / group by. Can't do that with the netprice/quantity/exchangerate LOD.

```sql
%%sql
SELECT
    customerkey,
    COUNT(*) AS total_orders,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS total_orders_row_num
FROM sales
GROUP BY customerkey
LIMIT 10
```

### row_number vs rank - look at customerkey 459519

```sql
%%sql
SELECT
    customerkey,
    COUNT(*) AS total_orders,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS total_orders_row_num,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS total_orders_rank,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS total_orders_dense_rank
FROM sales
GROUP BY customerkey
LIMIT 10
```

> **Note**
>
> lag and lead - look at rows above or below, not just the row you're currently on
> MoM growth for example!

```sql
%%sql

WITH monthly_revenue AS (
    SELECT
        TO_CHAR(orderdate, 'YYYY-MM') AS month,
        SUM(quantity * netprice * exchangerate) AS net_revenue
    FROM sales
    WHERE EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY month
    ORDER BY month
)
SELECT
    *,
    FIRST_VALUE(net_revenue) OVER (ORDER BY month) AS first_month_revenue,
    LAST_VALUE(net_revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_month_revenue,
      --for some reason last_value needs a bunch of additional details or it returns weird results. He didn't really explain why, will cover in next lesson (start and end frames).
    NTH_VALUE(net_revenue, 3) OVER (ORDER BY month) as third_month_revenue,
    lag(net_revenue) OVER (ORDER BY month) as m_minus_1_value,
    lag(net_revenue,2) OVER (ORDER BY month) as m_minus_2_value,
    lead(net_revenue) OVER (ORDER BY month) as next_month_value,
    lead(net_revenue,2) OVER (ORDER BY month) as month_after_next_value
FROM monthly_revenue
```

### MoM calculations

```sql
%%sql

WITH monthly_revenue AS (
    SELECT
        TO_CHAR(orderdate, 'YYYY-MM') AS month,
        SUM(quantity * netprice * exchangerate) AS net_revenue
    FROM sales
    WHERE EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY month
    ORDER BY month
)
SELECT
    *,
    lag(net_revenue) OVER (ORDER BY month) as m_minus_1_revenue,
    ((net_revenue - lag(net_revenue) OVER (ORDER BY month)) / lag(net_revenue) OVER (ORDER BY month)) * 100 as rev_growth_MoM_Percent
FROM monthly_revenue
```

> **Note**
>
> frame clauses for window fxns
> helps control what amount of data will be put into a window fxn
> running averages/smoothing MoM data!

```sql
%%sql
WITH monthly_sales AS (
    SELECT
        TO_CHAR(orderdate, 'YYYY-MM') as month,
        SUM(quantity * netprice * exchangerate) as net_revenue
    FROM sales
    WHERE EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY month
    ORDER BY month
)

SELECT
    month,
    net_revenue,
    AVG(net_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW -- this is the frame clause part, see OneNote screenshot for definitions
    ) as net_revenue_preceding_1,

    AVG(net_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as net_revenue_preceding_2,

    AVG(net_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) as net_revenue_preceding_3,

    AVG(net_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING -- this is the frame clause part, see OneNote screenshot for definitions
    ) as net_revenue_3month_moving_avg_plus_or_minus_one_month

FROM monthly_sales;
```

### unbounded example, use all of the available rows from start to finish

```sql
%%sql
WITH monthly_sales AS (
    SELECT
        TO_CHAR(orderdate, 'YYYY-MM') as month,
        SUM(quantity * netprice * exchangerate) as net_revenue
    FROM sales
    WHERE EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY month
    ORDER BY month
)

SELECT
    month,
    net_revenue,
    AVG(net_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- this is the frame clause part, see OneNote screenshot for definitions
    ) as net_revenue_unbounded_avg

FROM monthly_sales;
```
