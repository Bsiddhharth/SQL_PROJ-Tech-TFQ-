/***
--> Digital Music Store - Data Analysis
Data Analysis project to help Chinook Digital Music Store to help how they can
optimize their business opportunities and to help answering business related questions.
***/

select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503



-- Using SQL solve the following problems using the chinook database.
1) Find the artist who has contributed with the maximum no of albums. Display the artist name and the no of albums.

2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.

3) Find the employee who has supported the most no of customers. Display the employee name and designation
 
4) Which city corresponds to the best customers?

5) The highest number of invoices belongs to which country?

6) Name the best customer (customer who spent the most money).

7) Suppose you want to host a rock concert in a city and want to know which location should host it.

8) Identify all the albums who have less then 5 track under them.
    Display the album name, artist name and the no of tracks in the respective album.

9) Display the track, album, artist and the genre for all tracks which are not purchased.

10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.

11) Which is the most popular and least popular genre?

12) Identify if there are tracks more expensive than others. If there are then
    display the track name along with the album title and artist name for these expensive tracks.
    
13) Identify the 5 most popular artist for the most popular genre.
    Popularity is defined based on how many songs an artist has performed in for the particular genre.
    Display the artist name along with the no of songs.
    [Reason: Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.
    Lets invite the artists who have written the most rock music in our dataset.]

14) Find the artist who has contributed with the maximum no of songs/tracks. Display the artist name and the no of songs.

15) Are there any albums owned by multiple artist?
 
16) Is there any invoice which is issued to a non existing customer?

17) Is there any invoice line for a non existing invoice?

18) Are there albums without a title?

19) Are there invalid tracks in the playlist?
