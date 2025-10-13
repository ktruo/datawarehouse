select * from MONEQUIP.address;
select * from MONEQUIP.CUSTOMER_TYPE;
select * from MONEQUIP.EQUIPMENT;
select * from MONEQUIP.CATEGORY;
select * from MONEQUIP.CUstomer;
select * from MONEQUIP.staff;
select * from monequip.hire;
select * from monequip.SALES;

select * from MONEQUIP.HIRE h
where h.EQUIPMENT_ID = 15;

select * from MONEQUIP.HIRE h
where h.EQUIPMENT_ID = 158;

select * from MONEQUIP.sales s
where s.EQUIPMENT_ID = 158;

--customer_type duplicate values
select CUSTOMER_TYPE_ID, count(*)
from MONEQUIP.CUSTOMER_TYPE
group by CUSTOMER_TYPE_ID
having count(*) > 1;

--customer duplicate values
select CUSTOMER_ID, count(*)
from MONEQUIP.CUSTOMER
group by CUSTOMER_id
having count(*) > 1;


select distinct DESCRIPTION from MONEQUIP.CUSTOMER_TYPE;

--customer_type table created
create table customer_type AS
select * from MONEQUIP.CUSTOMER_TYPE
where DESCRIPTION = 'Business'
or DESCRIPTION = 'Individual';

select * from customer_type;

--category table created
create table CATEGORY AS
select * from MONEQUIP.CATEGORY
where category_DESCRIPTION != 'null';

drop table category;
select * from CATEGORY;

select * from MONEQUIP.EQUIPMENT;

select EQUIPMENT_NAME, count(*)
from MONEQUIP.EQUIPMENT
group by EQUIPMENT_NAME
having count(*) > 1;

select * from MONEQUIP.EQUIPMENT
where EQUIPMENT_NAME = 'EXCAVATOR - POST HOLE ATTACHMENT SUIT 3.5T';

select * from MONEQUIP.EQUIPMENT
where EQUIPMENT_NAME = 'CHIPPER - 150MM DIESEL';

select * from MONEQUIP.EQUIPMENT
where EQUIPMENT_NAME = 'DRAIN CLEANER 6IN JETTER 4000PSI';

select * from MONEQUIP.EQUIPMENT
where CATEGORY_Id=15;

--checking for relationship errors after deletion of category 15
select * from MONEQUIP.SALES
where SALES.EQUIPMENT_ID = 158;

select * from MONEQUIP.HIRE
where hire.EQUIPMENT_ID = 158;

--create equipment table
create table equipment as
select * from MONEQUIP.EQUIPMENT
where CATEGORY_ID != 15;

select * from EQUIPMENT;

--customer table created
create table customers AS
select distinct * from MONEQUIP.CUSTOMER
order by CUSTOMER_ID asc;

UPDATE customers
SET gender = CASE
    WHEN gender = 'M' THEN 'Male'
    WHEN gender = 'F' THEN 'Female'
    ELSE gender
END;

select * from CUSTOMERS;
drop table customers;

--create hire table
create table hire AS
select * from MONEQUIP.hire;

select * from hire;
-- Update total_hire_price with correct calculation
UPDATE hire
SET total_hire_price = 
    CASE 
        WHEN start_date = end_date THEN 0.5 * unit_hire_price*quantity
        ELSE (end_date - start_date) * unit_hire_price * quantity
    END;
--delete rows with end_date earlier than start_date
DELETE FROM hire
WHERE end_date < start_date;

--Remove rows from monequip.hire where start_date or end_date are not in the range April 2018 to December 2020
DELETE FROM hire
WHERE start_date < DATE '2018-04-01'
    OR end_date > DATE '2020-12-31';

--create sales table
create table sales as
select * from monequip.sales 
WHERE quantity > 0;

--create staff table
create table staff as
select * from monequip.staff;

SELECT * FROM staff;

--create address table
create table address as
SELECT * from MONEQUIP.address;

select * from address;

--create category dimension table
drop table categorydim;
create table categorydim as
select * from category;
select * from CATEGORYDIM;

--create time dimension table
drop table timedim;

CREATE TABLE timedim (
    timeID VARCHAR2(6), -- MMYYYY
    month NUMBER(2),
    year NUMBER(4),
    season VARCHAR2(10)
);

-- Insert distinct time periods from hire.start_date
INSERT INTO timedim(timeID, month, year, season)
SELECT 
    TO_CHAR(start_date, 'MMYYYY') AS timeID,
    TO_CHAR(start_date, 'MM') AS month,
    TO_CHAR(start_date, 'YYYY') AS year,
    CASE 
        WHEN TO_CHAR(start_date, 'MM') IN ('12', '01', '02') THEN 'Summer'
        WHEN TO_CHAR(start_date, 'MM') IN ('03', '04', '05') THEN 'Autumn'
        WHEN TO_CHAR(start_date, 'MM') IN ('06', '07', '08') THEN 'Winter'
        WHEN TO_CHAR(start_date, 'MM') IN ('09', '10', '11') THEN 'Spring'
        ELSE 'Unknown'
    END AS season
FROM (
    SELECT DISTINCT start_date FROM hire
);

select distinct start_date from hire;