select * from categorydim;
select * from branchdim;
select * from staff;
select * from timedim;
select * from EQUIPMENT;
select * from CATEGORY;
select * from CUSTOMERs;
select * from SALES;



-- Create scale dimension table
CREATE TABLE scaledim (
	Scale VARCHAR2(10)
);

INSERT INTO scaledim (scale) VALUES ('Low');
INSERT INTO scaledim (scale) VALUES ('Medium');
INSERT INTO scaledim (scale) VALUES ('High');

SELECT * FROM scaledim;


create table sales2 as select * from sales;
select * from sales2;
-- Add scale column to sales table
ALTER TABLE sales2 ADD (scale VARCHAR2(10));

-- Update scale values based on total_sales_price
UPDATE sales2
SET scale = CASE
	WHEN total_sales_price < 5000 THEN 'Low'
	WHEN total_sales_price >= 5000 AND total_sales_price <= 10000 THEN 'Medium'
	WHEN total_sales_price > 10000 THEN 'High'
	ELSE NULL
END;

--create temp sales fact table
create table tempsalesfact as
select 
    e.category_id,
    TO_CHAR(s2.sales_date, 'MMYYYY') AS timeID, 
    s.COMPANY_BRANCH,
    cust.CUSTOMER_TYPE_ID,
    s2.scale,
    s2.TOTAL_sales_PRICE,
    s2.QUANTITY
from 
    sales2 s2,
    equipment e, 
    staff s,
    customers cust
WHERE
    s2.EQUIPMENT_ID = e.EQUIPMENT_ID
    AND s2.STAFF_ID = s.STAFF_ID
    AND s2.CUSTOMER_ID = cust.CUSTOMER_ID;

drop table tempsalesfact;
select * from tempsalesfact;

--create sales fact table
create table salesfact as
select 
    CATEGORY_ID,
    timeid,
    COMPANY_BRANCH,
    CUSTOMER_TYPE_ID,
    SCALE,
    sum(tOTAL_sales_PRICE) as TOTAL_sales_revenue,
    sum(QUANTITY) as TOTAL_QUANTITY,
    count(*) as TOTAL_SALE_TRANSACTIONS
from tempsalesfact
GROUP BY
    CATEGORY_ID,
    timeid,
    COMPANY_BRANCH,
    CUSTOMER_TYPE_ID,
    SCALE;

drop table salesfact;
select * from salesfact;

--aggregate sales fact by scale
SELECT 
    scaledim.SCALE,
    SUM(TOTAL_sales_revenue) AS TOTAL_sales_revenue,
    SUM(TOTAL_QUANTITY) AS TOTAL_QUANTITY,
    SUM(TOTAL_SALE_TRANSACTIONS) AS TOTAL_TRANSACTIONS
from 
    salesfact,
    scaledim
WHERE 
    salesfact.SCALE = scaledim.SCALE
group BY
    scaledim.SCALE;

--check salesfact table structure
SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'SALESFACT';