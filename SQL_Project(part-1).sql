/*
SQL - Capstone Project
*/
use capstone;

select * from amazon_data;
select count(*) from amazon_data;   /* to check number of rows in column*/

---- "to check details of the table"
DESCRIBE amazon_data;
SHOW CREATE TABLE amazon_data;

SET sql_safe_updates = 0;

---- "as the date column was in text, needed to convert it to date datatype"
UPDATE amazon_data
SET date_ = STR_TO_DATE(date_, '%d-%m-%Y');

---- "to extract the year from date column and creating a new year column"
ALTER TABLE amazon_data
ADD COLUMN year_date YEAR;
UPDATE amazon_data
SET year_date = YEAR(date_);

---- "same conversin for time column"
UPDATE amazon_data
SET time_ = STR_TO_DATE(time_, '%H:%i:%s');

---- "as our data columns were not cleaned like there datatypes were incorrect which could make analysis difficult"
select str_to_date(date_,'%y-%m-%d'); 
ALTER TABLE amazon_data
MODIFY COLUMN invoice_id VARCHAR(30),
MODIFY COLUMN branch VARCHAR(5),
MODIFY COLUMN city VARCHAR(30),
MODIFY COLUMN customer_type VARCHAR(30),
MODIFY COLUMN gender VARCHAR(10),
MODIFY COLUMN product_line VARCHAR(100),
MODIFY COLUMN unit_price DECIMAL(10,2),
MODIFY COLUMN quantity INT,
MODIFY COLUMN VAT FLOAT(6,4),
MODIFY COLUMN total DECIMAL(10,2),
MODIFY COLUMN date_ DATE,
MODIFY COLUMN time_ TIME,
MODIFY COLUMN payment_method VARCHAR(20),
MODIFY COLUMN cogs DECIMAL(10,2),
MODIFY COLUMN gross_margin_percentage FLOAT(11,9),
MODIFY COLUMN gross_income DECIMAL(10,2),
MODIFY COLUMN rating DECIMAL(4,1);

-- the above was all about data cleaning and making table to smoother to perform data analysis

/*
Data Wrangling
*/
---- "There are no null values in our database as in creating the tables, we set NOT  NULL for each field, hence null values are filtered out"
SELECT *
FROM amazon_data
WHERE rating IS NULL;

DESCRIBE amazon_data;

/*
Feature Engineering
*/
---- """Adding a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening
-- This will help answer the question on which part of the day most sales are made"""
ALTER TABLE amazon_data
ADD COLUMN time_of_day VARCHAR(10);

UPDATE amazon_data
SET time_of_day = 
    CASE 
        WHEN TIME(time_) BETWEEN '04:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(time_) BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        WHEN TIME(time_) BETWEEN '17:00:00' AND '20:59:59' THEN 'Evening'
        ELSE 'Night'
    END;


---- """Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri)
-- This will help answer the question on which week of the day each branch is busiest"""
ALTER TABLE amazon_data
ADD COLUMN day_name VARCHAR(10);

UPDATE amazon_data
SET day_name = DAYNAME(date_);


---- """Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar)
-- It will help to determine which month of the year has the most sales and profit."""
ALTER TABLE amazon_data
ADD COLUMN month_name VARCHAR(10);

UPDATE amazon_data
SET month_name = MONTHNAME(date_);

select * from amazon_data;    /*checking that successully we accomplished feature engineering task*/ 

select count(*) 
from amazon_data
where  time_of_day = 'Night';
