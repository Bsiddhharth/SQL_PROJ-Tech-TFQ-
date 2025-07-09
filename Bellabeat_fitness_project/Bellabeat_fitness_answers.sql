-- drop table if exists daily_activity;
-- create table daily_activity
-- (
-- 	Customer_ID						bigint,
-- 	Activity_Date					date,
-- 	Day_of_Week						varchar(20),
-- 	Total_Steps						int,
-- 	Total_Distance					decimal,
-- 	Tracker_Distance				decimal,
-- 	Very_Active_Distance			decimal,
-- 	Moderately_Active_Distance		decimal,
-- 	Light_Active_Distance			decimal,
-- 	Sedentary_Active_Distance		decimal,
-- 	Very_Active_Minutes				int,
-- 	Fairly_Active_Minutes			int,
-- 	Lightly_Active_Minutes			int,
-- 	Sedentary_Minutes				int,
-- 	Calories						int
-- );

-- drop table if exists weight_log;
-- create table weight_log
-- (
-- 	Customer_ID			bigint,
-- 	Datetimes			timestamp,
-- 	Day_of_Week			varchar(20),
-- 	Dates 				date,	
-- 	Times				time,			
-- 	Weight_Kg			decimal,
-- 	Weight_Pounds		decimal,
-- 	Fat					int,
-- 	BMI					decimal,
-- 	Is_Manual_Report	boolean,
-- 	Manual_Report		int,
-- 	Log_Id				decimal
-- );

--updated table creation for weigth_log
-- CREATE TABLE weight_log (
--     customer_id        BIGINT,
--     datetimes          TEXT,
--     day_of_week        VARCHAR(20),
--     dates              TEXT,
--     times              TEXT,
--     weight_kg          DECIMAL,
--     weight_pounds      DECIMAL,
--     fat                INT,
--     bmi                DECIMAL,
--     is_manual_report   BOOLEAN,
--     manual_report      INT,
--     log_id             DECIMAL
-- );

-- drop table if exists sleep_day;
-- create table sleep_day
-- (
-- 	Customer_Id				bigint,
-- 	Sleep_Day				date,
-- 	Day_of_Week				varchar(20),
-- 	Total_Sleep_Records		int,
-- 	Total_Minutes_Asleep	int,
-- 	Total_Time_In_Bed		int
-- );

-- for daily_activity  table
-- ALTER TABLE daily_activity
-- ALTER COLUMN activity_date TYPE TEXT;
--Performed above since at first the date format
-- was different hence unabled to perform the import data


-- after the import was successfult below querry was executed
-- ALTER COLUMN activity_date TYPE DATE
-- USING to_date(activity_date, 'MM/DD/YYYY');



-- for sleep_day same issue happened while importing
-- ALTER TABLE sleep_day
-- ALTER COLUMN sleep_day TYPE TEXT;

-- ALTER TABLE sleep_day
-- ALTER COLUMN sleep_day TYPE DATE
-- USING to_date(sleep_day, 'MM/DD/YYYY');

-- Convert datetimes (e.g., 4/13/2016 1:08:52) to TIMESTAMP
-- ALTER TABLE weight_log
-- ALTER COLUMN datetimes TYPE TIMESTAMP
-- USING to_timestamp(datetimes, 'MM/DD/YYYY HH24:MI:SS');

-- -- Convert times (e.g., 1:08:52) to TIME
-- ALTER TABLE weight_log
-- ALTER COLUMN times TYPE TIME
-- USING to_timestamp(times, 'HH24:MI:SS')::TIME;

-- -- Convert dates (e.g., 4/13/2016) to DATE
-- ALTER TABLE weight_log
-- ALTER COLUMN dates TYPE DATE
-- USING to_date(dates, 'MM/DD/YYYY');



select * from daily_activity;
select * from weight_log;
select * from sleep_day;

--  Identify the day of the week when the customers are most active and least 
-- active. Active is determined based on the no of steps.

-- using partition
select distinct most_active, least_active
	from (
		select day_of_week, sum(total_steps) as total_steps
		, first_value(day_of_week) over(order by sum(total_steps) desc) as most_active
		, first_value(day_of_week) over(order by sum(total_steps)) as least_active
		from daily_activity 
		group by day_of_week ) x;

-- using cte
with step_totals as (
  select day_of_week, sum(total_steps) as total_steps
  from daily_activity
  group by day_of_week
)
select 
  max(case when total_steps = (select max(total_steps) from step_totals) then day_of_week end) as most_active,
  max(case when total_steps = (select min(total_steps) from step_totals) then day_of_week end) as least_active
from step_totals;


-- using union
(select  'Most Active' as activity_level,
day_of_week, sum(total_steps) as steps
from daily_activity
group by day_of_week
order by steps desc
limit 1
) 
union 
(select   'Least Active' as activity_level,
day_of_week, sum(total_steps) as steps
from daily_activity
group by day_of_week
order by steps asc
limit 1) 


-- 2) Identify the customer who has the most effective 
--sleep. Effective sleep is determined based on 
--is customer spent most of the time in bed sleeping.


-- when the time_in_bed alone was checked multiple candidates were found
-- (sum of time spend in bed - total minutes sleep) as wasted time
-- then ranked according to wasted_time


select * from sleep_day;

with cte as(
	select customer_id, 
	(sum(total_time_in_bed) - sum(Total_Minutes_Asleep)) as wasted_time,
	rank() over (ORDER BY (sum(total_time_in_bed) - sum(Total_Minutes_Asleep))) as rnk
	from sleep_day
	group by customer_id
)
select customer_id
from cte 
where rnk = 1

-- can also be done by finding efficiency ratio (but getting different answer)

-- WITH cte AS (
--     SELECT 
--         customer_id,
--         ROUND(AVG(CAST(Total_Minutes_Asleep AS Numeri) / NULLIF(Total_Time_In_Bed, 0)), 3) AS avg_efficiency
--     FROM 
--         sleep_day
--     GROUP BY 
--         customer_id
-- )
-- SELECT customer_id
-- FROM cte
-- ORDER BY avg_efficiency DESC
-- LIMIT 1;

-- 3) Identify customers with no sleep record.

select * from daily_activity;
select * from weight_log;
select * from sleep_day;

select distinct customer_id
from daily_activity
where customer_id not in (
	select customer_id
	from sleep_day
)


-- 4) Fetch all customers whose daily activity, sleep and weight logs are all present.

-- can also use join

select distinct da.customer_id
from daily_activity da
inner join weight_log w on da.customer_id = w.customer_id
inner join sleep_day s on da.customer_id = s.customer_id
order by da.customer_id 

-- for this question using intersect will give the answer
select customer_id from daily_activity 
intersect
select customer_id from weight_log
intersect
select customer_id from sleep_day
order by customer_id


-- 5) For each customer, display the total hours they slept for each day of the week. 
--Your output should contains 8 columns, 
--first column is the customer id and the next 7 columns are the day of the week 
--(like monday, tuesday etc)

select * from sleep_day

select customer_id,

	round(sum( case when Lower(day_of_week) = 'monday' then Total_Minutes_Asleep else 0 end ) / 60, 2 )as Monday,
	round(sum( case when Lower(day_of_week) = 'tuesday' then Total_Minutes_Asleep else 0 end ) / 60, 2 )as Tuesday,
	round(sum( case when Lower(day_of_week) = 'wednesday' then Total_Minutes_Asleep else 0 end ) / 60, 2 )as Wednesday,
	round(sum( case when Lower(day_of_week) = 'thursday' then Total_Minutes_Asleep else 0 end ) / 60, 2 )as Thursday,
	round(sum( case when Lower(day_of_week) = 'friday' then Total_Minutes_Asleep else 0 end ) / 60, 2 )as Friday,
	round(sum( case when Lower(day_of_week) = 'saturday' then Total_Minutes_Asleep else 0 end ) / 60, 2 )as Saturday,
	round(sum( case when Lower(day_of_week) = 'sunday' then Total_Minutes_Asleep else 0 end ) / 60, 2 )as Sunday

from sleep_day
GROUP BY customer_id


-- 6) For each customer, display the following:
-- customer_id
-- date when they had the highest_weight(also mention weight in kg) 
-- date when they had the lowest_weight(also mention weight in kg)


select * from weight_log;

with rnk_cte as (
	select customer_id,
	dates,
	weight_kg,
	Row_number() over (partition by customer_id order by weight_kg desc) as rnk_max,
	Row_number() over (partition by customer_id order by weight_kg asc ) as rnk_min
	from weight_log
 )

SELECT 
    MAX(CASE WHEN rnk_max = 1 THEN customer_id END) AS customer_id,
    MAX(CASE WHEN rnk_max = 1 THEN dates END) AS max_weight_date,
    MAX(CASE WHEN rnk_max = 1 THEN weight_kg END) AS max_weight,
    MAX(CASE WHEN rnk_min = 1 THEN dates END) AS min_weight_date,
    MAX(CASE WHEN rnk_min = 1 THEN weight_kg END) AS min_weight
FROM rnk_cte
GROUP BY customer_id
ORDER BY customer_id;

--

select distinct d.customer_id
	, coalesce(first_value(dates||'  ('||weight_kg||' kgs)') over(partition by d.customer_id order by weight_kg desc), 'NA') as highest_weight_on
	, coalesce(first_value(dates||'  ('||weight_kg||' kgs)') over(partition by d.customer_id order by weight_kg), 'NA') as lowest_weight_on
	from weight_log w
	right join daily_activity d on d.customer_id=w.customer_id
	order by highest_weight_on;
--

SELECT DISTINCT customer_id,
    FIRST_VALUE(dates) OVER (PARTITION BY customer_id ORDER BY weight_kg DESC) AS max_weight_date,
    FIRST_VALUE(weight_kg) OVER (PARTITION BY customer_id ORDER BY weight_kg DESC) AS max_weight,
    FIRST_VALUE(dates) OVER (PARTITION BY customer_id ORDER BY weight_kg ASC) AS min_weight_date,
    FIRST_VALUE(weight_kg) OVER (PARTITION BY customer_id ORDER BY weight_kg ASC) AS min_weight
FROM weight_log;

--
-- Using the last_value window function (have to add unbounded preceding and unbounded following )
SELECT DISTINCT customer_id,
    FIRST_VALUE(dates) OVER (PARTITION BY customer_id ORDER BY weight_kg DESC) AS max_weight_date,
    FIRST_VALUE(weight_kg) OVER (PARTITION BY customer_id ORDER BY weight_kg DESC) AS max_weight,
    LAST_VALUE(dates) OVER (
        PARTITION BY customer_id 
        ORDER BY weight_kg DESC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS min_weight_date,

    LAST_VALUE(weight_kg) OVER (
        PARTITION BY customer_id 
        ORDER BY weight_kg DESC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS min_weight

FROM weight_log;


-- 7) Fetch the day when customers sleep the most.

select * from sleep_day


select day_of_week
from (
	select day_of_week, 
	sum(total_minutes_asleep) as total_sleep,
	rank() over (order by sum(total_minutes_asleep) desc) as rnk
	from sleep_day
	group by day_of_week) x

where x.rnk=1;	


--

SELECT day_of_week, SUM(total_minutes_asleep) AS total_sleep
FROM sleep_day
GROUP BY day_of_week
ORDER BY total_sleep DESC
limit 1;


-- 8) For each day of the week, determine the 
-- percentage of time customers spend lying on bed without sleeping.

select * from sleep_day

select day_of_week ,
ROUND(
        100.0 * SUM(total_time_in_bed - total_minutes_asleep) / sum(total_time_in_bed),
        2
    ) as perc 
from sleep_day
GROUP BY day_of_week

-- below will be a better execustion as it handles the null
select day_of_week ,
ROUND(
        100.0 * SUM(total_time_in_bed - total_minutes_asleep) / nullif(sum(total_time_in_bed),0),
        2
    ) as perc 
from sleep_day
GROUP BY day_of_week

--

select day_of_week,
round(   
	((sum(total_time_in_bed) - sum(total_minutes_asleep)) :: Decimal 
	/ sum(total_time_in_bed) :: Decimal )* 100  , 2
)
from sleep_day
group BY day_of_week


-- 9) Identify the most repeated day of week. 
--Repeated day of week is when a day has been mentioned the most in entire database.

select * from daily_activity;
select * from weight_log;
select * from sleep_day;


select day_of_week, count(*) as total_times
from ( 
	select day_of_week from sleep_day
	union all
	select day_of_week from daily_activity
	union all
	select day_of_week from weight_log
) 
GROUP BY day_of_week
order by total_times desc
limit 1

-------
with cte as 
		(select day_of_week from daily_activity
		union all
		select day_of_week from weight_log
		union all
		select day_of_week from sleep_day),
	cte_final as 
		(select day_of_week, 
		count(1) as occurence, 
		rank() over(order by count(1) desc) as rnk
		from cte
		group by day_of_week)
select day_of_week
from cte_final
where rnk=1;




-- 10) Based on the given data, identify the average kms a customer walks based on 6000 steps.

select * from daily_activity;
select * from weight_log;
select * from sleep_day;

-- average km a customer walks based on 6000 steps
-- or Estimated KMs for 6000 Steps per customer
select --customer_id,
	round(avg(total_distance / nullif(total_steps,0)) * 6000 * 1.609 -- average 6000 miles -  kilometers
	,2) as km
from daily_activity
--GROUP BY customer_id
--order by km desc



select customer_id, round(avg(total_distance),2) as distance_kms
from daily_activity 
where total_steps > 6000
group by customer_id
order by distance_kms desc;



