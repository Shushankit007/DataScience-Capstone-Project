/*
Exploratory Data Analysis
*/

use capstone;
select * from amazon_data;
select count(*) from amazon_data;   /* to check number of rows in column*/

---- "Business Question and Answer"

--- "1. What is the count of distinct cities in the dataset?"   /*ans : 3 */
select count(DISTINCT city) as distinct_city_count 
from amazon_data;

--- "2. For each branch, what is the corresponding city?"   /*ans: A=Yangon   C=Naypyitaw   B=Mandalay*/
select DISTINCT branch, city
from amazon_data;

--- "3. What is the count of distinct product lines in the dataset?"    /* ans : 6*/
select  count(DISTINCT product_line)
from amazon_data;

--- "4. Which payment method occurs most frequently?"   /*ans : Ewallet=345 */
select payment_method, count(*) as freq_pay_method
from amazon_data
group by payment_method
order by freq_pay_method desc;

--- "5. Which product line has the highest sales?"   /* ans : Electronic accessories=971*/
select product_line,sum(quantity) as total_sales
from amazon_data
group by product_line
order by total_sales desc;

--- "6. How much revenue is generated each month?"   /* January=116292.11, March=109455.74, February=97219.58 */
select month_name, sum(total) as revenue_month
from amazon_data
group by month_name;

--- "7. In which month did the cost of goods sold reach its peak?"  /* january=110754.16 */
select month_name, sum(cogs) as cogs_month
from amazon_data
group by month_name
order by cogs_month desc;
 
--- "8. Which product line generated the highest revenue?"  /* Food and beverages=56144.96 */
select product_line, sum(total) as revenue
from amazon_data
group by product_line
order by revenue desc;

--- "9. In which city was the highest revenue recorded?" /* ans: Naypyitaw=110568.86 */
select city, sum(total) as total_revenue
from amazon_data
group by city
order by total_revenue desc;

--- "10. Which product line incurred the highest Value Added Tax?"  /* Sports and travel=2624.8965 */
select product_line, sum(VAT) as total_VAT
from amazon_data
group by product_line
order by product_line desc;

--- "11. For each product line, add a column indicating 'Good' if its sales are above average, otherwise 'Bad'."
select sum(quantity*unit_price) as avg_sales
from amazon_data;
select product_line, sum(quantity*unit_price) as sales,
case
when sum(quantity*unit_price) > (select avg(quantity*unit_price) from amazon_data) then 'Good'
else 'bad'
end as sale_status
from amazon_data
group by product_line;
  
--- "12. Identify the branch that exceeded the average number of products sold."
-- shows the average of products sold of the total solds by each branch = 1836.6667
select avg (total_sold) as avg_total_sold
from (select sum(quantity) as total_sold from amazon_data group by branch) as product_sold;    
-- total sum of the product sold = 5510 
select sum(quantity) from amazon_data;   
-- total product sold by by each branch
select branch , sum(quantity)
from amazon_data
group by branch;        

select branch, (select sum(quantity) from amazon_data as a2 WHERE a2.branch = a1.branch ) as branch_total_sold 
from amazon_data as a1
group by branch
having branch_total_sold > (select avg (total_sold) as avg_total_sold 
from (select sum(quantity) as total_sold from amazon_data group by branch) as product_sold);

--- "13. Which product line is most frequently associated with each gender?"
select gender, product_line, freq as most_freq
from (select gender,product_line, count(*) as freq,
row_number() over (partition by gender order by count(*) desc) as row_num
from amazon_data
group by gender, product_line) as temp_data
where row_num=1;

--- "14. Calculate the average rating for each product line."
select product_line, avg(rating) as avg_rating
from amazon_data
group by product_line;

--- "15. Count the sales occurrences for each time of day on every weekday."
select day_name, time_of_day, count(*) as sales_occur
from amazon_data
group by day_name, time_of_day
order by field(day_name,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
field(time_of_day,'Morning','Afternoon','Evening','Night');

--- "16. Identify the customer type contributing the highest revenue."  /* answer = member contribute highest*/
select customer_type, sum(cogs)
from amazon_data
group by customer_type;

--- "17. Determine the city with the highest VAT percentage."  /* answer = Yangon*/
select city, max(vat)
from amazon_data
group by city;

--- "18. Identify the customer type with the highest VAT payments."  /* ans = member */
select customer_type, sum(VAT) as total_vat
from amazon_data
group by customer_type
order by total_vat desc;

--- "19. What is the count of distinct customer types in the dataset?"
select count(distinct customer_type) as count_distinct_customer_type
from amazon_data;

--- "20. What is the count of distinct payment methods in the dataset?"
select count(distinct payment_method) as count_distinct_pay_method
from amazon_data;

--- "21. Which customer type occurs most frequently?"   /* ans = member*/
select customer_type, count(customer_type) as freq_customer_type
from amazon_data
group by customer_type;

--- "22. Identify the customer type with the highest purchase frequency."  /* ans = member */
select customer_type, count(*) as purchase_freq
from amazon_data
group by customer_type;

--- "23. Determine the predominant gender among customers."  /* ans = female*/
select gender, count(*) as count_gender
from amazon_data
group by gender;

--- "24. Examine the distribution of genders within each branch."
select branch, gender, count(*) as count_gender
from amazon_data
group by branch, gender
order by branch asc;

--- "25. Identify the time of day when customers provide the most ratings."  /* ans = afternoon*/
select time_of_day, count(rating) as count_ratings
from amazon_data
group by time_of_day
order by count_ratings desc;

--- "26. Determine the time of day with the highest customer ratings for each branch."
select branch, time_of_day, count(rating) as rating_count
from amazon_data
group by branch, time_of_day
order by branch, rating_count desc;
-- to simplify it more by getting only the highest rating for each branch at time of day
select branch, time_of_day,count(rating) as rating_count
from amazon_data
group by branch, time_of_day 
having count(rating) = (
        select count(rating) as max_rating_count
        from amazon_data as inner_data
        where inner_data.branch = amazon_data.branch
        group by inner_data.time_of_day
        order by max_rating_count desc
        limit 1)
order by branch;

--- "27. Identify the day of the week with the highest average ratings."
select day_name, avg(rating) as avg_rating
from amazon_data
group by day_name
order by avg_rating desc;

--- "28. Determine the day of the week with the highest average ratings for each branch."
select branch, day_name, avg(rating) as avg_rating
from amazon_data
group by branch, day_name
order by branch,avg_rating desc;
-- fro more accrate output i written below query
select branch, day_name, avg_rating
from (select branch, day_name, avg(rating) as avg_rating,
	  row_number() over (partition by branch order by avg(rating) desc) as rn
from amazon_data
group by branch, day_name) as ranked_data
where rn = 1
order by branch;

