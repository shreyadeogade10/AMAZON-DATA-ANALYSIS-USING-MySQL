select * from amazon;

# 1. Product analysis
SELECT 
    `product line`,
    SUM(total) AS total_sales,
    AVG(`unit price`) AS avg_unit_price,
    SUM(quantity) AS total_quantity_sold,
    SUM(`gross income`) AS total_gross_income,
    AVG(rating) AS avg_rating
FROM 
    amazon
GROUP BY 
    `product line`
ORDER BY 
    total_sales DESC;

# 2. sales analysis
 
 SELECT 
    `product line`,                              
    YEAR(date) AS year,                       
    MONTH(date) AS month,                     
    SUM(total) AS total_sales,                
    COUNT(`invoice id`) AS number_of_sales,      
    AVG(total) AS average_sales
FROM 
    amazon                                 
GROUP BY 
    `product line`,                              
    YEAR(date),                               
    MONTH(date)                               
ORDER BY 
    `product line`,                              
    YEAR(date),                                
    MONTH(date);    
    
# 3. Customer analysis

# afternoon,evening, morning
SELECT 
    branch,                                     
    `customer type`,                              
    gender,                                     
    Time,                            
    COUNT(`invoice id`) AS number_of_purchases,   
    SUM(total) AS total_spent             
FROM 
   amazon                                
GROUP BY 
    branch,                                     
    `customer type`,                              
    gender,                                     
    Time                            
ORDER BY 
    branch, `customer type`, Time;
    
# customer segments and purchase trends

SELECT 
    `Product line`,                              
    gender,                                     
    COUNT(`invoice id`) AS number_of_purchases,   
    SUM(total) AS total_spent                 
FROM 
    amazon 
GROUP BY 
    `Product line`,gender  
ORDER BY 
   gender,number_of_purchases DESC;         

# profitability
SELECT 
    `customer type`,                             
    gender,                                    
    SUM(`gross income`) AS total_gross_income
FROM 
   amazon                                  
GROUP BY 
    `customer type`,                              
    gender                                     
ORDER BY 
    total_gross_income DESC; 
    
# approch used
#1. data wrangling 
#2. feature engineering
ALTER TABLE amazon CHANGE `Tax 5%` VAT VARCHAR(255);

ALTER TABLE amazon
ADD COLUMN timeofday VARCHAR(10);

UPDATE amazon
SET timeofday = CASE
    WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN HOUR(time) BETWEEN 18 AND 23 THEN 'Evening'
    ELSE 'Night'
END;

#
ALTER TABLE amazon
ADD COLUMN dayname VARCHAR(10);

UPDATE amazon
SET dayname = CASE
    WHEN DAYOFWEEK(Date) = 1 THEN 'Sun'
    WHEN DAYOFWEEK(Date) = 2 THEN 'Mon'
    WHEN DAYOFWEEK(Date) = 3 THEN 'Tue'
    WHEN DAYOFWEEK(Date) = 4 THEN 'Wed'
    WHEN DAYOFWEEK(Date) = 5 THEN 'Thu'
    WHEN DAYOFWEEK(Date) = 6 THEN 'Fri'
    WHEN DAYOFWEEK(Date) = 7 THEN 'Sat'
END;

#
ALTER TABLE amazon
ADD COLUMN monthname VARCHAR(10);

UPDATE amazon
SET monthname = CASE
    WHEN MONTH(Date) = 1 THEN 'Jan'
    WHEN MONTH(Date) = 2 THEN 'Feb'
    WHEN MONTH(Date) = 3 THEN 'Mar'
    WHEN MONTH(Date) = 4 THEN 'Apr'
    WHEN MONTH(Date) = 5 THEN 'May'
    WHEN MONTH(DATE) = 6 THEN 'Jun'
    WHEN MONTH(Date) = 7 THEN 'Jul'
    WHEN MONTH(Date) = 8 THEN 'Aug'
    WHEN MONTH(Date) = 9 THEN 'Sep'
    WHEN MONTH(Date) = 10 THEN 'Oct'
    WHEN MONTH(Date) = 11 THEN 'Nov'
    WHEN MONTH(Date) = 12 THEN 'Dec'
END;
  
  SELECT `Product line`,Quantity,date,time,timeofday,dayname,monthname FROM amazon;
  
  
# BUSINESS QUESTIONS
#1.What is the count of distinct cities in the dataset?
SELECT COUNT(DISTINCT(city)) AS no_of_cities FROM amazon; 

#2.For each branch, what is the corresponding city? 
SELECT branch,city FROM amazon
GROUP BY branch, city
ORDER BY branch;

#3.What is the count of distinct product lines in the dataset? 
SELECT COUNT(DISTINCT(`product line`)) AS distinct_product_lines
FROM amazon;

#4.Which payment method occurs most frequently?
SELECT payment, COUNT(PAYMENT) FROM amazon 
GROUP BY payment
LIMIT 1;

#5.Which product line has the highest sales? 
SELECT `product line`,SUM(Total) as total_sales FROM amazon 
GROUP BY `product line`
ORDER BY total_sales DESC
LIMIT 1 ;

#6.How much revenue is generated each month? 
SELECT monthname,SUM(total) AS total_revenue FROM amazon 
GROUP BY monthname
ORDER BY month(monthname);

#7.In which month did the cost of goods sold reach its peak?
SELECT monthname,SUM(cogs) AS total_cogs FROM amazon 
GROUP BY monthname
ORDER BY total_cogs DESC 
LIMIT 1;

#8.Which product line generated the highest revenue?
SELECT `product line`,SUM(total) as total_revenue FROM amazon
GROUP BY `product line` 
ORDER BY total_revenue DESC 
LIMIT 1;

#9.In which city was the highest revenue recorded?
SELECT city,SUM(total) as total_revenue FROM amazon 
GROUP BY city 
ORDER BY total_revenue DESC 
LIMIT 1;

#10.Which product line incurred the highest Value Added Tax?
SELECT `product line`,SUM(VAT) as total_vat 
FROM amazon
GROUP BY `product line` 
ORDER BY total_vat DESC 
LIMIT 1;

#11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT `product line`,total,
CASE WHEN total > avg_sales THEN 'Good' ELSE 'Bad' 
END AS sales_category
FROM(SELECT*,(SELECT AVG(total) FROM amazon) as avg_sales FROM amazon) as AvgSale;

#12.Identify the branch that exceeded the average number of products sold.
SELECT branch FROM(SELECT branch,AVG(quantity) as avg_quantity FROM amazon
                    GROUP BY branch) as branch_avg 
                    WHERE avg_quantity > (SELECT AVG(quantity) FROM amazon);
                    
#13.Which product line is most frequently associated with each gender?
SELECT gender,`product line`,COUNT(*) AS count FROM amazon 
GROUP BY gender,`product line`
HAVING count = (SELECT MAX(sub.count) FROM (SELECT gender,`product line`,COUNT(*) AS count 
                FROM amazon GROUP BY gender, `product line`) AS sub 
                WHERE sub.gender = amazon.gender 
                GROUP BY sub.gender);
                
#14.Calculate the average rating for each product line.
SELECT `product line`,AVG(rating) as average_ratings FROM amazon 
GROUP BY `product line`
ORDER BY average_ratings DESC;

#15.Count the sales occurrences for each time of day on every weekday.
SELECT dayname,timeofday,COUNT(*) AS count FROM amazon 
GROUP BY dayname, timeofday 
ORDER BY day(dayname),timeofday;

#16.Identify the customer type contributing the highest revenue.
SELECT `customer type`, SUM(total) AS total_revenue FROM amazon 
GROUP BY `customer type` 
ORDER BY total_revenue DESC 
LIMIT 1; 

#17.Determine the city with the highest VAT percentage.
SELECT city, SUM(VAT)/SUM(total)*100 AS vat_percentage FROM amazon 
GROUP BY city 
ORDER BY vat_percentage DESC 
LIMIT 1;

#18.Identify the customer type with the highest VAT payments.
SELECT `customer type`,SUM(VAT) AS total_vat_payments FROM amazon  
GROUP BY `customer type` 
ORDER BY total_vat_payments DESC 
LIMIT 1;

#19.What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT(`customer type`)) AS distinct_customer_type FROM amazon;

#20.What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT (payment)) AS count_of_payment_method 
FROM amazon;

#21.Which customer type occurs most frequently?
SELECT `customer type` FROM (SELECT `customer type`, COUNT(*) AS count FROM amazon 
                             GROUP BY `customer type` 
                             ORDER BY count DESC 
                             LIMIT 1) AS most_frequent_customer;
                             
#22.Identify the customer type with the highest purchase frequency.
SELECT `customer type` FROM (SELECT `customer type`, COUNT(*) AS purchase_frequency FROM amazon 
                             GROUP BY `customer type` 
                             ORDER BY purchase_frequency DESC 
                             LIMIT 1) AS highest_purchase_frequency_customr_type;
                             
#23.Determine the predominant gender among customers.
SELECT gender FROM (SELECT gender,COUNT(*) AS count FROM amazon 
					GROUP BY gender 
                    ORDER BY count DESC
                    LIMIT 1) AS predominant_gender;
                    
#24.Examine the distribution of genders within each branch.
SELECT branch, gender,COUNT(*) AS count FROM amazon 
GROUP BY branch,gender 
ORDER BY branch; 

#25.Identify the time of day when customers provide the most ratings.
SELECT timeofday,COUNT(Rating) AS rating_count FROM amazon 
GROUP BY timeofday 
ORDER BY rating_count DESC 
LIMIT 1;

#26.Determine the time of day with the highest customer ratings for each branch.
SELECT branch, timeofday,
       MAX(avg_rating) AS highest_avg_rating
FROM (
    SELECT branch, timeofday, AVG(rating) AS avg_rating
    FROM amazon
    GROUP BY branch, timeofday
) AS branch_time_avg_rating
GROUP BY branch,timeofday
ORDER BY branch;
                                                  
#27.Identify the day of the week with the highest average ratings.
SELECT dayname,AVG(rating) AS average_rating FROM amazon 
GROUP BY dayname 
ORDER BY average_rating DESC 
LIMIT 1;

#28. Determine the day of the week with the highest average ratings for each branch.
SELECT branch,dayname,AVG(rating) AS average_rating FROM amazon 
GROUP BY branch,dayname 
HAVING AVG(rating) = (SELECT MAX(avg_rating) FROM (SELECT branch,dayname,AVG(rating) AS avg_rating 
                                                   FROM amazon 
                                                   GROUP BY branch,dayname) AS branch_day_avg_ratings 
                                                   WHERE branch = amazon.branch)
 ORDER BY branch;                                                  ;

