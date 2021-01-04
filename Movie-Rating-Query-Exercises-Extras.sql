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