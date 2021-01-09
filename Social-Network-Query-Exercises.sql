-- Find the names of all students who are friends with someone named Gabriel.
select name
from Highschooler as h,
    (
        select ID2
        from Friend as f,
            (
                select ID
                from Highschooler
                where name is 'Gabriel'
            ) as Gabriels
        where f.ID1 = Gabriels.ID
    ) as Gabriels_friends
where Gabriels_friends.ID2 = h.ID

-- For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.
select l1.name,
    l1.grade,
    h1.name,
    h1.grade
from Highschooler as h1,
    (
        select name,
            grade,
            ID2
        from Highschooler as h,
            Likes as l
        where h.ID = l.ID1
            and h.grade > 10
    ) as l1
where h1.ID = l1.ID2
    and (l1.grade - h1.grade) > 1


-- For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.
select h1.name,
    h1.grade,
    h2.name,
    h2.grade
from Highschooler as h1,
    Highschooler h2,
    (
        select l1.ID1,
            l1.ID2
        from Likes as l1,
            Likes as l2
        where l1.ID1 = l2.ID2
            and l1.ID2 = l2.ID1
    ) like_pairs
where h1.ID = like_pairs.ID1
    and h2.ID = like_pairs.ID2
    and h1.name < h2.name


-- Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.
select name,
    grade
from Highschooler as h
where ID not in (
        select ID1
        from Likes
        union
        select ID2
        from Likes
    )
order by grade,
    name

-- For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.
select h1.name,
    h1.grade,
    unknown.name,
    unknown.grade
from Highschooler as h1,
    Likes as l,
    (
        select name,
            ID,
            grade
        from Highschooler
        where ID not in (
                select ID1
                from Likes
            )
    ) as unknown
where h1.ID = l.ID1
    and l.ID2 = unknown.ID	