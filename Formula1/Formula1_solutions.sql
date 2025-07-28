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

-- group by year, show the first and last race for each??


select distinct year, 
    count(*) over ( partition by year ) as total_races,
    first_value(name) over ( partition by year order by date 
                ) as first_race,
    last_value(name) over (partition by year order by date 
            rows between unbounded preceding and unbounded following) as last_race

from races
order by year

--

WITH race_ranked AS (
    SELECT 
        year,
        name AS race_name,
        date,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY date ASC) AS first_race_rn,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY date DESC) AS last_race_rn
    FROM races
),
first_last AS (
    SELECT 
        year,
        COUNT(*) AS total_races,
        MAX(CASE WHEN first_race_rn = 1 THEN race_name END) AS first_race,
        MAX(CASE WHEN last_race_rn = 1 THEN race_name END) AS last_race
    FROM race_ranked
    GROUP BY year
)
SELECT *
FROM first_last
ORDER BY year;



-- 7) Which circuit has hosted the most no of races. 
-- Display the circuit name, no of races, city and country.


with cte as
(   select c.circuitid as circuitid, 
    count(1) as no_of_races,
    rank() over( order by count(1) desc) as rnk
    from circuits c 
    join races r on c.circuitid = r.circuitid 
    group by c.circuitid )

select c.name as circuit_name, cte.no_of_races, 
       c.location as city,  c.country as country
       , cte.rnk as rank
from circuits c 
join cte on c.circuitid = cte.circuitid
--where cte.rnk = 1
order by cte.rnk


-- 8) Display the following for 2022 season:
-- 	year, race_no, circuit name, 
--  driver name, driver race position, driver race points, flag to indicate if winner, 
--  constructor name, constructor position, constructor points,flag to indicate if constructor is winner,
--  race status of each driver, 
--  flag to indicate fastest lap for which driver,
--  total no of pit stops by each driver

-- finding connection
-- circuits

-- 

select r.raceid, r.year, r.round as race_no, r.name as circuit_name, concat(d.forename,' ',d.surname) as driver_name
		, ds.position as driver_position, ds.points as driver_points, case when ds.position=1 then 'WINNER' end as winner_flag
		, c.name as constructor_name, cs.position as constructor_position, cs.points as constructor_points
		, case when cs.position=1 then 'WINNER' end as cons_winner_flag, sts.status
		, case when lp.driverid is not null then 'Faster Lap' end as fastest_lap_indi, pt.no_of_stops
		from races r
		join driver_standings ds on ds.raceid=r.raceid
		join drivers d on d.driverid = ds.driverid
		join constructor_standings cs on cs.raceid=r.raceid 
		join constructors c on c.constructorid=cs.constructorid
		join results res on res.raceid=r.raceid and res.driverid=ds.driverid and res.constructorid=cs.constructorid
		join status sts on sts.statusid=res.statusid
		left join (	select lp.raceid, lp.driverid
					from lap_times lp
					join (	select raceid, min(time) as fastest_lap
							from lap_times
							group by raceid) x on x.raceid=lp.raceid and x.fastest_lap=lp.time
				 ) lp on lp.driverid = ds.driverid and lp.raceid=r.raceid
		left join (	select raceid,driverid, count(1) as no_of_stops
					from pit_stops
					group by raceid,driverid) pt on pt.driverid = ds.driverid and pt.raceid=r.raceid
		where year=2022 --and r.raceid=1074
		order by year, race_no, driver_position;

--------------------------

WITH fastest_laps AS (
    SELECT 
        lp.raceid,
        lp.driverid
    FROM lap_times lp
    JOIN (
        SELECT raceid, MIN(time) AS fastest_time
        FROM lap_times
        GROUP BY raceid
    ) x ON lp.raceid = x.raceid AND lp.time = x.fastest_time
),
pit_counts AS (
    SELECT raceid, driverid, COUNT(*) AS no_of_stops
    FROM pit_stops
    GROUP BY raceid, driverid
)

SELECT 
    r.raceid,
    r.year,
    r.round AS race_no,
    cir.name AS circuit_name,
    
    CONCAT(d.forename, ' ', d.surname) AS driver_name,
    ds.position AS driver_position,
    ds.points AS driver_points,
    CASE WHEN ds.position = 1 THEN 'WINNER' END AS winner_flag,

    cons.name AS constructor_name,
    cs.position AS constructor_position,
    cs.points AS constructor_points,
    CASE WHEN cs.position = 1 THEN 'WINNER' END AS cons_winner_flag,

    sts.status AS race_status,
    CASE WHEN fl.driverid IS NOT NULL THEN 'Fastest Lap' END AS fastest_lap_indi,
    COALESCE(pc.no_of_stops, 0) AS no_of_stops

FROM races r
JOIN circuits cir ON r.circuitId = cir.circuitId
JOIN driver_standings ds ON ds.raceid = r.raceid
JOIN drivers d ON d.driverid = ds.driverid
JOIN results res ON res.raceid = r.raceid AND res.driverid = ds.driverid
JOIN constructors cons ON cons.constructorid = res.constructorid
JOIN constructor_standings cs ON cs.raceid = r.raceid AND cs.constructorid = res.constructorid
JOIN status sts ON sts.statusid = res.statusid
LEFT JOIN fastest_laps fl ON fl.raceid = r.raceid AND fl.driverid = ds.driverid
LEFT JOIN pit_counts pc ON pc.raceid = r.raceid AND pc.driverid = ds.driverid

WHERE r.year = 2022
ORDER BY r.year, r.round, ds.position;


-- 9) List down the names of all F1 champions and the no of times they have won it.

-- connecting drivers -> driver_standings -> races


select * from races

with cte as (

    select r.year, concat(d.forename, ' ', d.surname ) as driver_name,
            sum(res.points) as tot_points,
            rank() over(partition by r.year order by sum(res.points) desc) as rnk

    from races r 
    join results res on r.raceid = res.raceid
    join drivers d on res.driverid = d.driverid
    group by r.year, res.driverid, concat(d.forename,' ',d.surname)

),
    top_races as (
        select *
        from cte 
        where rnk = 1
    )

select driver_name, count(1) as no_of_times_won
from top_races
group by driver_name
order by count(1) desc

-- 10) Who has won the most constructor championships

with cte as
        (select r.year, c.name as constructor_name
        , sum(res.points) as tot_points
        , rank() over(partition by r.year order by sum(res.points) desc) as rnk
        from races r
        join constructor_standings cs on cs.raceid=r.raceid
        join constructors c on c.constructorid = cs.constructorid
        join constructor_results res on res.raceid=r.raceid and res.constructorid=cs.constructorid 
        --where r.year>=2022
        group by r.year,  res.constructorid, c.name),
    cte_rnk as
        (select * from cte where rnk=1)
select constructor_name, count(1) as no_of_championships
from cte_rnk
group by constructor_name
order by 2 desc;

-- 

WITH last_races AS (
    SELECT year, MAX(round) AS final_round
    FROM races
    GROUP BY year
),
champions AS (
    SELECT 
        r.year,
        c.name AS constructor_name
    FROM races r
    JOIN last_races lr ON r.year = lr.year AND r.round = lr.final_round
    JOIN constructor_standings cs ON cs.raceId = r.raceId AND cs.position = 1
    JOIN constructors c ON c.constructorId = cs.constructorId
)
SELECT 
    constructor_name,
    COUNT(*) AS no_of_championships
FROM champions
GROUP BY constructor_name
ORDER BY no_of_championships DESC;



-- 11) How many races has India hosted?

select c.name as circuit_name,c.country,count(*) as no_of_races
from races r 
join circuits c on r.circuitid = c.circuitid 
where lower(c.country) = 'india'
group by c.name,c.country



--12) Identify the driver who won the championship 
-- or was a runner-up. Also display the team they belonged to. 

-- the constructor can change team mid season so (edge case)

with cte as(
    select r.year as year, concat(d.forename, ' ', d.surname) as driver_name,
        c.name as constructor, sum(res.points) as tot_points,
        rank() over(partition by r.year order by sum(res.points) desc) as rnk
    from races r 
    join driver_standings ds on r.raceid = ds.raceid 
    join drivers d on ds.driverid = d.driverid 
    join results res on res.raceid = r.raceid and res.driverid = ds.driverid
    join constructors c on c.constructorid = res.constructorid
    group by r.year,res.driverid, concat(d.forename, ' ', d.surname), c.name)

select year, driver_name, constructor,
    case when rnk = 1 then 'Winner' 
    else 'Runner Up' end as flag
from cte 
where rnk <= 2


-- 13) Display the top 10 drivers with most wins.

select concat(d.forename,' ', d.surname) as driver_name, 
    count(*) as tot_no_wins
from drivers d 
join results res on d.driverid = res.driverid 
where res.position = 1
group by d.driverid, concat(d.forename,' ', d.surname)
order by count(*) desc
limit 10

--


--  Which drivers led the championship the most times across all races (not necessarily wins), 
-- and who are the top 10?
select driver_name, race_wins
	from (
		select ds.driverid, concat(d.forename,' ',d.surname) as driver_name
		, count(1) as race_wins
		, rank() over(order by count(1) desc) as rnk
		from driver_standings ds
		join drivers d on ds.driverid=d.driverid
		where position=1
		group by ds.driverid, concat(d.forename,' ',d.surname)
		order by race_wins desc, driver_name) x
	where rnk <= 10;



-- 14) Display the top 3 constructors of all time.


select name, no_of_wins
from
(
select c.constructorid, c.name as name, count(*) as  no_of_wins,
    rank() over(order by count(*) desc) as rnk
from results res
join constructors c on c.constructorid = res.constructorid
join races r on r.raceid = res.raceid
where res.position = 1
group by c.constructorid, c.name
) as x
where  x.rnk <= 3


-- 15) Identify the drivers who have won races with multiple teams.

SELECT driverid, driver_name, STRING_AGG(constructor_name, ', ')
FROM (
    SELECT DISTINCT 
        r.driverid,
        CONCAT(d.forename, ' ', d.surname) AS driver_name,
        c.name AS constructor_name
    FROM results r
    JOIN drivers d ON d.driverid = r.driverid
    JOIN constructors c ON c.constructorid = r.constructorid
    WHERE r.position = 1
) x
GROUP BY driverid, driver_name
HAVING COUNT(1) > 1
ORDER BY driverid, driver_name;

