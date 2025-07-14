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


--9) Display the track, album, artist 
--and the genre for all tracks which are not purchased.

--finding connection
-- artist -> album -> track -> Genre

select t.name, al.title, ar.name, g.name
from artist ar 
join album al  on ar.artistid = al.artistid
join track t on al.albumid = t.albumid
join genre g on t.genreid = g.genreid
where t.trackid not in (
    select trackid from invoiceline
)

-- using left join
SELECT t.name, al.title, ar.name, g.name
FROM track t
JOIN album al ON t.albumid = al.albumid
JOIN artist ar ON al.artistid = ar.artistid
JOIN genre g ON t.genreid = g.genreid
left join invoiceline inv on t.trackid = inv.trackid
where inv.trackid is null;

--
SELECT 
    t.name AS track_name,
    al.title AS album_title,
    art.name AS artist_name,
    g.name AS genre
FROM Track t
JOIN Album al ON al.AlbumId = t.AlbumId
JOIN Artist art ON art.ArtistId = al.ArtistId
JOIN Genre g ON g.GenreId = t.GenreId
WHERE NOT EXISTS (
    SELECT 1
    FROM InvoiceLine il
    WHERE il.TrackId = t.TrackId
);


--10) Find artist who have performed in multiple genres. 
-- Diplay the aritst name and the genre.

--finding connection
-- artist -> album -> track -> genre

-- below querry shows the artist name and the no_of_genres
SELECT 
    a.name AS artist_name,
    COUNT(distinct g.genreid) AS no_of_genres
FROM artist a 
JOIN album al ON a.artistid = al.artistid
JOIN track t ON al.albumid = t.albumid
JOIN genre g ON t.genreid = g.genreid
GROUP BY a.artistid, a.name
HAVING COUNT(distinct g.genreid) > 1;


--

with temp as
        (select distinct art.name as artist_name, g.name as genre
        from Track t
        join album al on al.albumid=t.albumid
        join artist art on art.artistid = al.artistid
        join genre g on g.genreid = t.genreid
        order by 1,2),
    final_artist as
        (select artist_name
        from temp t
        group by artist_name
        having count(1) > 1)
select t.*
from temp t
join final_artist fa on fa.artist_name = t.artist_name
order by 1,2;

--

SELECT 
    artist_name,
    STRING_AGG(genre, ', ' ORDER BY genre) AS genres
FROM (
    SELECT DISTINCT art.name AS artist_name, g.name AS genre
    FROM Track t
    JOIN Album al ON al.albumid = t.albumid
    JOIN Artist art ON art.artistid = al.artistid
    JOIN Genre g ON g.genreid = t.genreid
) temp
GROUP BY artist_name
HAVING COUNT(DISTINCT genre) > 1
ORDER BY artist_name;


-- 11) Which is the most popular and least popular genre?
-- Popularity is defined based on how many times it has been purchased.

-- finding connection 

with temp as (
    select distinct g.name as genre_name, 
    rank() over(order by count(1) desc) as rnk_genre
    from track t 
    join genre g on t.genreid = g.genreid
    join invoiceline i on t.trackid = i.trackid
    group by g.name
),
temp2 as(
    select max(rnk_genre) as max_rnk 
    from temp
)

select genre_name, 'most_popular' as popularity
from temp where rnk_genre = 1
union all
select genre_name, 'least_popular' as popularity
from temp where (rnk_genre in (select max_rnk from temp2))

----
with temp as
        (select distinct g.name
        , count(1) as no_of_purchases
        , rank() over(order by count(1) desc) as rnk
        from InvoiceLine il
        join track t on t.trackid = il.trackid
        join genre g on g.genreid = t.genreid
        group by g.name
        order by 2 desc),
    temp2 as
        (select max(rnk) as max_rnk from temp)
select name as genre
, case when rnk = 1 then 'Most Popular' else 'Least Popular' end as popular
from temp
cross join temp2
where rnk = 1 or rnk = max_rnk;


-- 12) Identify if there are tracks more expensive than others. 
-- If there are then display the track name along with the album title
--  and artist name for these expensive tracks.


-- all tracks except the one with lowest unitprice?

select t.name as track_name, a.title as album_title, 
    ar.name as artist_name, t.unitprice as unitprice
from  track t 
join album a on t.albumid = a.albumid
join artist ar on a.artistid = ar.artistid
where t.unitprice > (select min(unitprice) from track)
order by track_name



-- 13) Identify the 5 most popular artist for the most popular genre.
--     Popularity is defined based on how many songs an artist 
--     has performed in for the particular genre.
--     Display the artist name along with the no of songs.
--     [Reason: Now that we know that our customers love rock music, 
--     we can decide which musicians to invite to play at the concert.
--     Lets invite the artists who have written the most rock music in our dataset.]


--lets find the most poupular genre first then do the rest


with most_popular_genre as
    (select genre 
    from  (select distinct g.name as genre ,
            rank() over(order by count(*) desc) as rnk_gnr
        from track t 
        join genre g on t.genreid = g.genreid
        join invoiceline i on t.trackid = i.trackid
        group by  g.name)x
    where x.rnk_gnr = 1),

    ---- or 

    -- (select g.name as genre 
    -- from track t 
    -- join genre g on t.genreid = g.genreid
    -- join invoiceline i on t.trackid = i.trackid
    -- group by  g.name
    -- order by count(*) desc
    -- limit 1),

    popular_artist as   
    (select a.name  as artist_name,
    count(*) as no_of_songs,
    rank() over(order by count(*) desc) as rnk_artist
    from artist a
    join album al on a.artistid = al.artistid 
    join track t on al.albumid = t.albumid 
    join genre g on t.genreid = g.genreid
    where g.name in (select genre from most_popular_genre)
    group  by a.name 
    ) 
select artist_name, no_of_songs, rnk_artist
from popular_artist 
where rnk_artist <=5


-- 14) Find the artist who has contributed with the maximum no of songs/tracks. 
-- Display the artist name and the no of songs.

select a.name ,  
    count(t.trackid) as no_of_tracks 
from artist a 
join album al on a.artistid = al.artistid
join track t on al.albumid = t.albumid
group by a.name 
order by no_of_tracks desc
limit 1

-- 
select artist_name , no_of_tracks
from   (select a.name as artist_name,  
        count(t.trackid) as no_of_tracks,
        rank() over (order by count(t.trackid) desc) as rnk
    from artist a 
    join album al on a.artistid = al.artistid
    join track t on al.albumid = t.albumid
    group by a.name )x
where x.rnk = 1


-- 15) Are there any albums owned by multiple artist?

select albumid, count(*) as no_of_artist
from album
group by albumid
having count(*) > 1 


-- 16) Is there any invoice 
-- which is issued to a non existing customer?

select *
from invoice i
where i.customerid not in (
    select customerid from customer
)
-- above code works fine but 
--If any CustomerId in Customer is NULL, 
--this can return no results due to how NOT IN works with NULLs

-- below code safely handles the above issue

SELECT *
FROM Invoice i
WHERE NOT EXISTS (
    SELECT 1
    FROM Customer c
    WHERE c.CustomerId = i.CustomerId
);


-- 17) Is there any invoice line for a non existing invoice?

SELECT *
FROM InvoiceLine i
WHERE NOT EXISTS (
    SELECT 1
    FROM Invoice iv
    WHERE iv.invoiceid = i.invoiceid
);


--18) Are there albums without a title?
select title
from album 
where title is null

--
select count(*) from albumw
where title is null


-- 19) Are there invalid tracks in the playlist?

select * 
from PlaylistTrack  p
where not exists (
    select 1 
    from track t
    where p.trackid = t.trackid
)

--
SELECT pt.*, pl.Name AS playlist_name
FROM PlaylistTrack pt
LEFT JOIN Track t ON pt.TrackId = t.TrackId
JOIN Playlist pl ON pl.PlaylistId = pt.PlaylistId
WHERE t.TrackId IS NULL;


