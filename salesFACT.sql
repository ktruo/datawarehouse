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
	scale_value VARCHAR2(10)
);

INSERT INTO scaledim (scale_value) VALUES ('Low');
INSERT INTO scaledim (scale_value) VALUES ('Medium');
INSERT INTO scaledim (scale_value) VALUES ('High');

SELECT * FROM scaledim;


-- Add scale column to sales table
ALTER TABLE sales ADD (scale VARCHAR2(10));

-- Update scale values based on total_sales_price
UPDATE sales
SET scale = CASE
	WHEN total_sales_price < 5000 THEN 'Low'
	WHEN total_sales_price >= 5000 AND total_sales_price <= 10000 THEN 'Medium'
	WHEN total_sales_price > 10000 THEN 'High'
	ELSE NULL
END;

