select * from seasons; -- 74
select * from status; -- 139	
select * from circuits; -- 77
select * from races; -- 1102
select * from drivers; -- 857
select * from constructors; -- 211
select * from constructor_results; -- 12170
select * from constructor_standings; -- 12941
select * from driver_standings; -- 33902
select * from lap_times; -- 538121
select * from pit_stops; -- 9634
select * from qualifying; -- 9575
select * from results; -- 25840
select * from sprint_results; -- 120


-- 1) Identify the country which has produced 
-- the most F1 drivers.

select * from drivers

select nationality , count(*) as no_of_drivers
from drivers 
group BY nationality
order by count(*) desc
limit 1
--

select nationality, count(1) as no_of_drivers
from drivers
group by nationality 
order by 2 desc 
limit 1


--2) Which country has produced the most no of F1 circuits

select country as country, count(*) as no_of_circuits 
from circuits
group by country 
order by 2 desc 
limit 1

--3) Which countries have produced exactly 5 constructors? 

select nationality, count(*) as no_of_constructors
from constructors
group by nationality
having count(*) = 5 

-- 4) List down the no of races that have taken place each year

select year as Year, count(1) as no_of_races 
from races
group by year 
order by 1 


-- 5) Who is the youngest and oldest F1 driver?

select 
    driver_name,
    case
        when rnk_o = 1 then 'oldest_driver'
        when rnk_y = 1 then 'youngest_driver'
    end as label,
    dob
from(   select  concat(forename , ' ', surname) as driver_name, 
            dob,
            row_number() over(order by dob) as rnk_o,
            row_number() over(order by dob desc) as rnk_y
        from drivers
    ) x
where rnk_o = 1 or rnk_y = 1

-----------
select 
    driver_name,
    case
        when rnk = 1 then 'oldest_driver'
        when rnk= cnt then 'youngest_driver'
    end as label,
    dob
from(   select  concat(forename , ' ', surname) as driver_name, 
            dob,
            row_number() over(order by dob) as rnk,
            count(*) over() as cnt
           -- row_number() over(order by dob desc) as rnk_y

        from drivers
    ) x
where rnk = 1 or rnk = cnt

------
WITH ranked_drivers AS (
    SELECT 
        CONCAT(forename, ' ', surname) AS driver_name,
        dob,
        ROW_NUMBER() OVER (ORDER BY dob ASC) AS rnk
    FROM drivers
)
SELECT 
    CASE 
        WHEN rnk = 1 THEN 'oldest_driver'
        WHEN rnk = (SELECT MAX(rnk) FROM ranked_drivers) THEN 'youngest_driver'
    END AS label,
    driver_name,
    dob
FROM ranked_drivers
WHERE rnk = 1 OR rnk = (SELECT MAX(rnk) FROM ranked_drivers);


------
select max(case when rn=1 then driver_name end) as oldest_driver
	, max(case when rn=cnt then driver_name end) as youngest_driver
	from (
		select concat(forename, ' ', surname) as driver_name,
        row_number() over (order by dob ) as rn, 
        count(*) over() as cnt
		from drivers) x
	where rn = 1 or rn = cnt



-- 6) List down the no of races that have taken place each year 
-- and mentioned which was the first and the last race of each season.

