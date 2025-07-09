SELECT * FROM PlaylistTrack;
SELECT * FROM Playlist;
SELECT * FROM InvoiceLine;
SELECT * FROM Invoice;
SELECT * FROM Customer;
SELECT * FROM Employee;
SELECT * FROM Track;
SELECT * FROM Album;
SELECT * FROM Artist;
SELECT * FROM MediaType;
SELECT * FROM Genre;


--1) Find the artist who has contributed with the maximum 
--no of albums. Display the artist name and the no of albums.

SELECT * FROM Album;
SELECT * FROM Artist;

-- using cte 
with cte as(
    select artistid, count(*)  as no
    from Album
    GROUP BY artistid
    )
select cte.artistid, art.name as artist_name, cte.no as no_of_albums
from cte 
join artist art on  cte.artistid = art.artistid
order by no_of_albums DESC
limit 1

---
-- using cte with rank
with temp as
    (select artistid
    , count(1) as no_of_albums
    , rank() over(order by count(1) desc) as rnk
    from Album
    group by artistid)
select art.name as artist_name, t.no_of_albums
from temp t
join artist art on art.artistid = t.artistid
where rnk = 1;

--
-- using join and groupby
SELECT 
    ar.Name AS artist_name,
    COUNT(al.AlbumId) AS number_of_albums
FROM  Artist ar
JOIN Album al ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId
ORDER BY number_of_albums DESC
LIMIT 1;

--2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.

SELECT * FROM Genre;
SELECT * FROM Customer;


-- finding a link between genre and customer
-- customer -> invoice -> invoiceline -> track -> genre


select distinct(concat(cs.firstname,' ', cs.lastname))as name, 
    cs.email as email_id, cs.country as country
from customer cs
join invoice iv on cs.customerid = iv.customerid
join invoiceline il on iv.invoiceid = il.invoiceid
join track t on il.trackid = t.trackid
join genre g on t.genreid = g.genreid
where g.name in ('Jazz', 'Rock', 'Pop')

--
select  (c.firstname||' '||c.lastname) as customer_name
, c.email, c.country, g.name as genre
from InvoiceLine il
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
join Invoice i on i.invoiceid = il.invoiceid
join customer c on c.customerid = i.customerid
where g.name in ('Jazz', 'Rock', 'Pop');

--3) Find the employee who has supported the most no of customers. Display the employee name and designation

SELECT * FROM Customer;
SELECT * FROM Employee;

-- a limitaiton to below code is if two emp with same no comes,
-- below only returns one of them

select  (emp.firstname||' '||emp.lastname) as emp_name,
    emp.title as designation
from employee emp
join customer c on emp.employeeid =  c.supportrepid
group by emp.firstname,emp.lastname,emp.title
order by count(*) desc 
limit 1

-- above limitaion can be overcome by using a rank
SELECT employee_name, title AS designation
FROM (
    SELECT (e.firstname || ' ' || e.lastname) AS employee_name, 
           e.title,
           COUNT(1) AS no_of_customers,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM Customer c
    JOIN employee e ON e.employeeid = c.supportrepid
    GROUP BY e.firstname, e.lastname, e.title
) x
WHERE x.rnk = 1;


-- 4) Which city corresponds to the best customers?

SELECT * FROM Customer;
select * from invoice;

select city
from(
    select c.city as city,
        SUM(i.total) AS total_revenue,
        rank() over(order by sum(total) desc) as rnk
    from customer c 
    join invoice i on c.customerid = i.customerid
    group by c.city
    ) x
where x.rnk = 1


-- 5) The highest number of invoices belongs to which country?

select * from invoice;

select billingcountry, count(*) as no_of_invoices
from invoice
group by  billingcountry
order by no_of_invoices desc
limit 1

---

select billingcountry
from
    (
        select billingcountry, 
        count(*) as no_of_invoices,
        rank() over (order by count(*) desc) as rnk
        from invoice
        group by  billingcountry
    ) x
where x.rnk = 1


-- 6) Name the best customer (customer who spent the most money).

SELECT * FROM Customer;
select * from invoice;
select * from invoiceline;


select cust_name
from
(select concat(c.firstname,' ', c.lastname) as cust_name,
    rank() over (order by sum(iv.total) desc) as rnk
    from customer c
    join invoice iv on c.customerid = iv.customerid
    group by c.customerid, c.firstname, c.lastname
    )x
where x.rnk = 1

--7) Suppose you want to host a rock concert in a city 
--and want to know which location should host it.

-- finding the connection 
-- invoice -> invoiceline -> track -> genre
select * from genre;
 
select city
from
    (select iv.billingcity as city,
        count(*) as rock_lovers,
        rank() over (order by count(*) desc) as rnk
    from invoice iv 
    join invoiceline il  on iv.invoiceid = il.invoiceid
    join track t on il.trackid =  t.trackid 
    join genre g on t.genreid = g.genreid
    where lower(g.name) = 'rock'
    group by iv.billingcity
    ) x
where x.rnk = 1



--8) Identify all the albums who have 
--less then 5 track under them.
--Display the album name, artist name 
--and the no of tracks in the respective album.

-- finding connection
-- artist -> album -> track 

select * from track;
select * from album;
select * from artist;


select t.albumid , al.title, ar.name,
    count(*) as no_of_tracks 
from artist ar 
join album al on ar.artistid = al.artistid
join track t on al.albumid = t.albumid
group by t.albumid, al.title, ar.name
having count(*) < 5

-----------

with temp as
    (select t.albumid, count(1) as no_of_tracks
    from Track t
    group by t.albumid
    having count(1) < 5
    order by 2 desc)
select al.title as album_title, art.name as artist_name, t.no_of_tracks
from temp t
join album al on t.albumid = al.albumid
join artist art on art.artistid = al.artistid
order by t.no_of_tracks desc;
