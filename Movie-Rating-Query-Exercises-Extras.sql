-- Find the names of all reviewers who rated Gone with the Wind.
select distinct name
from (
        select rID
        from Rating
        where mID = 101
    ) q1,
    Reviewer r
where q1.rID = r.rID 

-- For any rating where the reviewer is the same as the director of the movie, 
-- return the reviewer name, movie title, and number of stars.
select name,
    title,
    stars
from (
        select distinct name,
            rID,
            title,
            mID
        from Movie,
            Reviewer
        where director = name
    ) q1,
    Rating
where q1.rID = Rating.rID
    and q1.mID = Rating.mID 

--Return all reviewer names and movie names together in a single list, alphabetized. 
--(Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)
select name
from Reviewer
union
select title
from Movie 

-- Find the titles of all movies not reviewed by Chris Jackson.
select distinct title
from Movie
where Movie.title not in (
        select title
        from Movie,
            Rating,
            Reviewer
        where Movie.mID = Rating.mID
            and Reviewer.rID = Rating.rID
            and Reviewer.name = 'Chris Jackson'
    ) 

-- For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers.
-- Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.
select distinct rev1.name,
    rev2.name
from Rating as rat1,
    Rating as rat2,
    Reviewer as rev1,
    Reviewer as rev2
where rat1.mID = rat2.mID
    and rev1.rID = rat1.rID
    and rev2.rID = rat2.rID
    and rev1.name is not rev2.name
    and rev2.name > rev1.name
order by rev1.name 

-- For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
select name,
    title,
    stars
from Reviewer as r,
    Movie as m,
    (
        select mID,
            rID,
            r1.stars
        from (
                select min(stars) as least
                from Rating
            ) least,
            Rating r1
        where not r1.stars > least.least
    ) as l
where r.rID = l.rID
    and m.mID = l.mID

-- List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.    
select title,
    avg(stars)
from Movie m,
    Rating r
where m.mID = r.mID
group by m.mID
order by avg(stars) desc,
    title

-- Find the names of all reviewers who have contributed three or more ratings.
select name
from Reviewer as r,
    (
        select rID
        from Rating
        group by rID
        having count(*) > 2
    ) as q
where r.rID = q.rID

-- Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title.
select m1.title,
    m1.director
from Movie as m1,
    (
        select director
        from Movie as m
        group by director
        having count(*) > 1
    ) as m2
where m1.director = m2.director
order by m1.director,
    m1.title


-- Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
select title,
    avg_rating
from Movie,
    (
        select mID,
            max(average) as avg_rating
        from (
                select mID,
                    avg(stars) as average
                from Rating as r
                group by mID
            )
    ) as q1
where Movie.mID = q1.mID

-- Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)
select title,
    average
from Movie as m,
    (
        select mID,
            average
        from (
                select mID,
                    avg(stars) as average
                from Rating as r
                group by mID
            ) as movie_average_tuple,
(
                select min(average) as min
                from (
                        select mID,
                            avg(stars) as average
                        from Rating as r
                        group by mID
                    ) as movie_average_tuple
            ) as min_average
        where movie_average_tuple.average = min_average.min
    ) as id_min_tuple
where m.mID = id_min_tuple.mID

-- For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL.
select director,
    title,
    max(stars) as max
from Rating,
    Movie
where Movie.director is not NULL
    and Rating.mID = Movie.mID
group by director