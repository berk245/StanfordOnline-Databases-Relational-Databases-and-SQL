-- Find the titles of all movies directed by Steven Spielberg.
select title
from Movie
where director = 'Steven Spielberg' 

-- Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order
select year
from Movie
where Movie.mID in(
        select mID
        from Rating
        where stars > 3
    )
order by year 

-- Find the titles of all movies that have no ratings.
select title
from Movie
where mID not in (
        select mID
        from Rating
    ) 
    
-- Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.
select name
from Reviewer
where rID in (
        select rID
        from Rating
        where ratingDate is null
    ) 
    
-- Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.
select name,
    title,
    stars,
    ratingDate
from Reviewer,
    Rating,
    Movie
where Reviewer.rID = Rating.rID
    and Movie.mId = Rating.mID
order by name,
    title,
    stars 
    
-- For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.
select name,
    title
from Movie,
    Reviewer
where mID in (
        select distinct mID
        from Rating R1
        where R1.mID in (
                select distinct mID
                from Rating R2
                where R1.rID = R2.rId
                    and R1.mID = R2.mID
                    and R1.ratingDate < R2.ratingDate
                    and R2.stars > R1.stars
            )
    )
    and rID in (
        select distinct rID
        from Rating R1
        where R1.mID in (
                select distinct mID
                from Rating R2
                where R1.rID = R2.rId
                    and R1.mID = R2.mID
                    and R1.ratingDate < R2.ratingDate
                    and R2.stars > R1.stars
            )
    ) 
    
-- For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.
select title,
    stars
from Movie,
    (
        select mID,
            stars
        from Rating
        group by mID
        having max(stars)
    ) S1
where Movie.mID = S1.mID
order by title 

-- For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.
select title,
    s1.stars - s2.stars as spread
from Movie,
    (
        select mID,
            stars
        from Rating
        group by mID
        having max(stars)
    ) s1,
    (
        select mID,
            stars
        from Rating
        group by mID
        having min(stars)
    ) s2
where s1.mID = s2.mID
    and Movie.mID = s1.mID
order by spread desc,
    title 
    
    
-- Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. 
-- (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. 
-- Don't just calculate the overall average rating before and after 1980.)
select avg(early_ones.avgs) - avg(late_ones.avgs)
from (
        select avg(R.stars) as avgs
        from rating R,
            (
                select mID,
                    title
                from Movie
                where year < 1980
            ) as m1
        where m1.mID = r.mID
        group by m1.mID
    ) as early_ones,
    (
        select m1.title,
            avg(R.stars) as avgs
        from rating R,
            (
                select mID,
                    title
                from Movie
                where year > 1980
            ) as m1
        where m1.mID = r.mID
        group by m1.mID
    ) as late_ones