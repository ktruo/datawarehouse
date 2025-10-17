
-- Hire Fact: Branch Revenue Report
-- Purpose: Analyze total and average hire revenue by company branch.
-- Metrics:
-- - TOTAL_HIRE_REVENUE: Sum of hire revenue per branch
-- - AVG_HIRE_REVENUE_PER_TXN: Average revenue per hire transaction
-- - TOTAL_HIRE_TRANSACTIONS: Number of hire transactions
-- - REVENUE_SHARE_PCT: Branch share of overall hire revenue
-- - RANK_BY_TOTAL_REVENUE / RANK_BY_AVG_REVENUE: Rankings for quick comparison
-- Notes: Uses HIREFACT. Join to TIMEDIM or filter by TIMEID if period-specific reporting is needed.
WITH branch_agg AS (
  SELECT
    COMPANY_BRANCH,
    SUM(TOTAL_HIRE_REVENUE) AS TOTAL_HIRE_REVENUE,
    SUM(TOTAL_HIRE_TRANSACTIONS) AS TOTAL_HIRE_TRANSACTIONS
  FROM HIREFACT
  GROUP BY COMPANY_BRANCH
),
scored AS (
  SELECT
    COMPANY_BRANCH,
    TOTAL_HIRE_REVENUE,
    TOTAL_HIRE_TRANSACTIONS,
    CASE WHEN TOTAL_HIRE_TRANSACTIONS > 0
         THEN ROUND(TOTAL_HIRE_REVENUE / TOTAL_HIRE_TRANSACTIONS, 2)
         ELSE 0
    END AS AVG_HIRE_REVENUE_PER_TXN,
    ROUND(RATIO_TO_REPORT(TOTAL_HIRE_REVENUE) OVER () * 100, 2) AS REVENUE_SHARE_PCT,
    RANK() OVER (ORDER BY TOTAL_HIRE_REVENUE DESC) AS RANK_BY_TOTAL_REVENUE,
    RANK() OVER (
      ORDER BY CASE WHEN TOTAL_HIRE_TRANSACTIONS > 0
                    THEN TOTAL_HIRE_REVENUE / TOTAL_HIRE_TRANSACTIONS
                    ELSE 0 END DESC
    ) AS RANK_BY_AVG_REVENUE
  FROM branch_agg
)
SELECT
  COMPANY_BRANCH,
  TOTAL_HIRE_REVENUE,
  TOTAL_HIRE_TRANSACTIONS,
  AVG_HIRE_REVENUE_PER_TXN,
  REVENUE_SHARE_PCT,
  RANK_BY_TOTAL_REVENUE,
  RANK_BY_AVG_REVENUE
FROM scored
ORDER BY TOTAL_HIRE_REVENUE DESC;
-- Optional: Top 5 branches by average hire revenue
-- SELECT * FROM scored ORDER BY AVG_HIRE_REVENUE_PER_TXN DESC FETCH FIRST 5 ROWS ONLY;

-- Sales Fact: Customer Type Sales Analysis
-- Purpose: Evaluate sales performance by customer type.
-- Metrics:
-- - TOTAL_SALES_REVENUE: Sum of sales revenue per customer type
-- - AVG_SALES_REVENUE_PER_TXN: Average revenue per sales transaction
-- - TOTAL_SALES_TRANSACTIONS: Number of sales transactions
-- - REVENUE_SHARE_PCT: Customer type share of overall sales revenue
-- - RANK_BY_TOTAL_REVENUE / RANK_BY_AVG_REVENUE: Rankings for quick comparison
-- Notes: Uses SALESFACT. Join to TIMEDIM or filter by TIMEID if period-specific reporting is needed.
WITH custtype_agg AS (
  SELECT
    CUSTOMER_TYPE_ID,
    SUM(TOTAL_SALES_REVENUE) AS TOTAL_SALES_REVENUE,
    SUM(TOTAL_SALE_TRANSACTIONS) AS TOTAL_SALES_TRANSACTIONS
  FROM SALESFACT
  GROUP BY CUSTOMER_TYPE_ID
),
scored AS (
  SELECT
    CUSTOMER_TYPE_ID,
    TOTAL_SALES_REVENUE,
    TOTAL_SALES_TRANSACTIONS,
    CASE WHEN TOTAL_SALES_TRANSACTIONS > 0
         THEN ROUND(TOTAL_SALES_REVENUE / TOTAL_SALES_TRANSACTIONS, 2)
         ELSE 0
    END AS AVG_SALES_REVENUE_PER_TXN,
    ROUND(RATIO_TO_REPORT(TOTAL_SALES_REVENUE) OVER () * 100, 2) AS REVENUE_SHARE_PCT,
    RANK() OVER (ORDER BY TOTAL_SALES_REVENUE DESC) AS RANK_BY_TOTAL_REVENUE,
    RANK() OVER (
      ORDER BY CASE WHEN TOTAL_SALES_TRANSACTIONS > 0
                    THEN TOTAL_SALES_REVENUE / TOTAL_SALES_TRANSACTIONS
                    ELSE 0 END DESC
    ) AS RANK_BY_AVG_REVENUE
  FROM custtype_agg
)
SELECT
  CUSTOMER_TYPE_ID,
  TOTAL_SALES_REVENUE,
  TOTAL_SALES_TRANSACTIONS,
  AVG_SALES_REVENUE_PER_TXN,
  REVENUE_SHARE_PCT,
  RANK_BY_TOTAL_REVENUE,
  RANK_BY_AVG_REVENUE
FROM scored
ORDER BY TOTAL_SALES_REVENUE DESC;
-- Optional: Top 5 customer types by average sales revenue

--group hirefact by customer type and branch
SELECT
CUSTOMER_TYPE_ID,
 COMPANY_BRANCH,
 SUM(TOTAL_HIRE_REVENUE) AS TOTAL_HIRE_REVENUE,
 SUM(TOTAL_HIRE_TRANSACTIONS) AS TOTAL_HIRE_TRANSACTIONS,
CASE WHEN SUM(TOTAL_HIRE_TRANSACTIONS) > 0
 THEN ROUND(SUM(TOTAL_HIRE_REVENUE) / SUM(TOTAL_HIRE_TRANSACTIONS), 2)
    ELSE 0
END AS AVG_HIRE_REVENUE_PER_TXN
FROM hirefact
GROUP BY
 CUSTOMER_TYPE_ID,
 COMPANY_BRANCH
ORDER BY TOTAL_HIRE_REVENUE DESC;
-- Optional: Top 5 customer type and branch combinations by average hire revenue
--group salesfact by customer type and branch
SELECT
CUSTOMERtypedim.description as customer_type,
 COMPANY_BRANCH,
 SUM(TOTAL_SALES_REVENUE) AS TOTAL_SALES_REVENUE,
 SUM(TOTAL_SALE_TRANSACTIONS) AS TOTAL_SALES_TRANSACTIONS,
CASE WHEN SUM(TOTAL_SALE_TRANSACTIONS) > 0
 THEN ROUND(SUM(TOTAL_SALES_REVENUE) / SUM(TOTAL_SALE_TRANSACTIONS), 2)
    ELSE 0
END AS AVG_SALES_REVENUE_PER_TXN
FROM salesfact, customertypedim
WHERE salesfact.CUSTOMER_TYPE_ID = customertypedim.CUSTOMER_TYPE_ID
GROUP BY
 customertypedim.description,
 COMPANY_BRANCH
ORDER BY TOTAL_SALES_REVENUE DESC;

select * from CUSTOMERTYPEDIM;

--group hirefact by timeid and branch
SELECT
timedim.season as season,
 COMPANY_BRANCH,
 SUM(TOTAL_HIRE_REVENUE) AS TOTAL_HIRE_REVENUE,
 SUM(TOTAL_HIRE_TRANSACTIONS) AS TOTAL_HIRE_TRANSACTIONS
FROM hirefact, timedim
WHERE hirefact.timeid = timedim.timeid
GROUP BY
 timedim.season,
 COMPANY_BRANCH
ORDER BY TOTAL_HIRE_REVENUE DESC;

--aggregate hire fact by season and year
SELECT 
    timedim.SEASON,
    timedim.YEAR,
    SUM(TOTAL_HIRE_revenuE) AS TOTAL_HIRE_Revenue,
    SUM(TOTAL_HIRE_TRANSACTIONS) AS TOTAL_TRANSACTIONS,
    ROUND(SUM(TOTAL_HIRE_revenuE)/SUM(TOTAL_HIRE_TRANSACTIONS), 2) AS AVG_HIRE_REVENUE_PER_TXN
from 
    hirefact,
    timedim
WHERE
    hirefact.timeid = timedim.timeid
group BY
    timedim.SEASON,
    timedim.YEAR
ORDER BY 
    timedim.YEAR,
    CASE timedim.SEASON 
        WHEN 'Summer' THEN 1
        WHEN 'Autumn' THEN 2
        WHEN 'Winter' THEN 3
        WHEN 'Spring' THEN 4
    END;

select * from hirefact;
select * from TIMEDIM;

WITH season_map AS (
  SELECT
    timedim.SEASON,
    timedim.YEAR,
    SUM(TOTAL_HIRE_revenuE) AS TOTAL_HIRE_Revenue,
    -- Map season to a number
    (timedim.YEAR * 10) +
      CASE timedim.SEASON
        WHEN 'Summer' THEN 1
        WHEN 'Autumn' THEN 2
        WHEN 'Winter' THEN 3
        WHEN 'Spring' THEN 4
      END AS seasonyear
  FROM hirefact, timedim
  WHERE hirefact.timeid = timedim.timeid
  GROUP BY timedim.SEASON, timedim.YEAR
),
regression AS (
  SELECT
    REGR_SLOPE(TOTAL_HIRE_Revenue, seasonyear) AS slope,
    REGR_INTERCEPT(TOTAL_HIRE_Revenue, seasonyear) AS intercept
  FROM season_map
)
SELECT
  s.SEASON,
  s.YEAR,
  s.TOTAL_HIRE_Revenue,
  ROUND(r.slope * s.seasonyear + r.intercept, 2) AS predicted_hire_revenue
FROM season_map s, regression r
ORDER BY s.YEAR, s.SEASON;

--group salesfact by scale and customer type
SELECT
CUSTOMERtypedim.description as customer_type,
 SCALE,
 SUM(TOTAL_SALES_REVENUE) AS TOTAL_SALES_REVENUE,
 SUM(TOTAL_SALE_TRANSACTIONS) AS TOTAL_SALES_TRANSACTIONS,
CASE WHEN SUM(TOTAL_SALE_TRANSACTIONS) > 0
 THEN ROUND(SUM(TOTAL_SALES_REVENUE) / SUM(TOTAL_SALE_TRANSACTIONS), 2)
    ELSE 0
END AS AVG_SALES_REVENUE_PER_TXN
FROM salesfact, customertypedim
WHERE salesfact.CUSTOMER_TYPE_ID = customertypedim.CUSTOMER_TYPE_ID
GROUP BY
 CUSTOMERtypedim.description,
 SCALE
ORDER BY TOTAL_SALES_REVENUE DESC;

select * from SALESFACT;

--group salesfact by season and year
SELECT 
    timedim.SEASON,
    timedim.YEAR,
    SUM(TOTAL_SALES_REVENUE) AS TOTAL_SALES_Revenue,
    SUM(TOTAL_SALE_TRANSACTIONS) AS TOTAL_TRANSACTIONS,
    ROUND(SUM(TOTAL_SALES_REVENUE)/SUM(TOTAL_SALE_TRANSACTIONS), 2) AS AVG_SALES_REVENUE_PER_TXN
from 
    salesfact,
    timedim
WHERE
    salesfact.timeid = timedim.timeid
group BY
    timedim.SEASON,
    timedim.YEAR
ORDER BY 
    timedim.YEAR,
    CASE timedim.SEASON 
        WHEN 'Summer' THEN 1
        WHEN 'Autumn' THEN 2
        WHEN 'Winter' THEN 3
        WHEN 'Spring' THEN 4
    END;