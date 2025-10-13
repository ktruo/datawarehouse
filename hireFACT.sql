--create hire fact table
select * from hire;
select * from categorydim;
select * from branchdim;
select * from staff;
select * from timedim;
select * from EQUIPMENT;
select * from CATEGORY;
select * from CUSTOMERs;


create table temphirefact as
select 
    e.category_id,
    TO_CHAR(H.start_date, 'MMYYYY') AS timeID, 
    s.COMPANY_BRANCH,
    cust.CUSTOMER_TYPE_ID,
    h.TOTAL_HIRE_PRICE,
    h.QUANTITY
from 
    hire h,
    equipment e, 
    staff s,
    customers cust
WHERE
    h.EQUIPMENT_ID = e.EQUIPMENT_ID
    AND h.STAFF_ID = s.STAFF_ID
    AND h.CUSTOMER_ID = cust.CUSTOMER_ID;

select * from temphirefact;

--create hire fact table
create table hirefact as
select 
    CATEGORY_ID,
    timeid,
    COMPANY_BRANCH,
    CUSTOMER_TYPE_ID,
    sum(tOTAL_HIRE_PRICE) as TOTAL_HIRE_PRICE,
    sum(QUANTITY) as TOTAL_QUANTITY,
    count(*) as TOTAL_TRANSACTIONS
from temphirefact
GROUP BY
    CATEGORY_ID,
    timeid,
    COMPANY_BRANCH,
    CUSTOMER_TYPE_ID;

select * from hirefact;

--aggregate hire fact by season
SELECT 
    timedim.SEASON,
    SUM(TOTAL_HIRE_PRICE) AS TOTAL_HIRE_PRICE,
    SUM(TOTAL_QUANTITY) AS TOTAL_QUANTITY,
    SUM(TOTAL_TRANSACTIONS) AS TOTAL_TRANSACTIONS
from 
    hirefact,
    timedim
WHERE
    hirefact.timeid = timedim.timeid
group BY
    timedim.SEASON;

