create database netflix_Data_db;
use netflix_Data_db;
show tables; 
SET SQL_SAFE_UPDATES = 0;
drop table netflix_raw;

CREATE TABLE netflix_raw (
    show_id VARCHAR(10) PRIMARY KEY,
    type VARCHAR(10),
    title VARCHAR(200),
    director VARCHAR(250),
    cast VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(20),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in VARCHAR(100),
    description VARCHAR(500)
);

select * from netflix_raw;

select show_id,COUNT(*) 
from netflix_raw
group by show_id 
having COUNT(*)>1;

select title,COUNT(*) 
from netflix_raw
group by title 
having COUNT(*)>1;

select * from netflix_raw 
where upper(title) in (
select upper(title)
from netflix_raw
group by title
having COUNT(*)>1
)
order by title;





CREATE TABLE netflix_genre AS
WITH RECURSIVE cte AS (
    -- Start with full string
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2) AS rest
    FROM netflix_raw

    UNION ALL

    -- Keep splitting until nothing left
    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS genre,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM cte
    WHERE rest <> ''
)
SELECT show_id, genre
FROM cte
WHERE genre <> '';

select * from netflix_genre;
select show_id,count(show_id) from netflix_genre group by show_id;
drop table netflix_genre;

CREATE TABLE netflix_director AS
WITH RECURSIVE cte AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(director, ',', 1)) AS director,
        SUBSTRING(director, LENGTH(SUBSTRING_INDEX(director, ',', 1)) + 2) AS rest
    FROM netflix_raw
    WHERE director IS NOT NULL AND director <> ''

    UNION ALL

    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS director,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM cte
    WHERE rest <> ''
)
SELECT show_id, director
FROM cte
WHERE director <> '';

select * from netflix_director;
select show_id,count(show_id) from netflix_director group by show_id;
drop table netflix_director;


CREATE TABLE netflix_country AS
WITH RECURSIVE cte AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS country,
        SUBSTRING(country, LENGTH(SUBSTRING_INDEX(country, ',', 1)) + 2) AS rest
    FROM netflix_raw
    WHERE country IS NOT NULL AND country <> ''

    UNION ALL

    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS country,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM cte
    WHERE rest <> ''
)
SELECT show_id, country
FROM cte
WHERE country <> '';

select * from netflix_country;
select show_id,count(show_id) from netflix_country group by show_id;
drop table netflix_country;


CREATE TABLE netflix_cast AS
WITH RECURSIVE cte AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS actor,
        SUBSTRING(cast, LENGTH(SUBSTRING_INDEX(cast, ',', 1)) + 2) AS rest
    FROM netflix_raw
    WHERE cast IS NOT NULL AND cast <> ''

    UNION ALL

    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS actor,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM cte
    WHERE rest <> ''
)
SELECT show_id, actor
FROM cte
WHERE actor <> '';

select * from netflix_cast;
select show_id,count(show_id) from netflix_cast group by show_id;
drop table netflix_cast;


select * from netflix_raw


where concat(upper(title),type)  in (
select concat(upper(title),type) 
from netflix_raw
group by title ,type
having COUNT(*)>1
)
order by title;

with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix_raw
)
select * from cte
where rn =1;

CREATE TABLE netflix AS
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY title, type ORDER BY show_id) AS rn
    FROM netflix_raw
)
SELECT 
    show_id,
    type,
    title,
    STR_TO_DATE(date_added, '%M %d, %Y') AS date_added,  -- convert 'September 1, 2020' to DATE
    release_year,
    rating,
    duration,           -- if duration is NULL, set 'Unknown'COALESCE(duration, 'Unknown') AS 
    description
FROM cte
WHERE rn = 1;

drop table netflix;
select * from netflix;

select show_id,country from netflix_raw where country is null;

INSERT INTO netflix_country (show_id, country)
SELECT nr.show_id, m.country
FROM netflix_raw nr
JOIN (
    SELECT nd.director, nc.country
    FROM netflix_director nd
    JOIN netflix_country nc ON nd.show_id = nc.show_id
    WHERE nc.country IS NOT NULL
    GROUP BY nd.director, nc.country
) m ON nr.director = m.director
WHERE nr.country IS NULL;

select * from netflix where duration is null;
update netflix
set duration=rating
where duration is null;

select * from netflix where date_added is null;

--netflix data analysis

-- for each director count the no of movies and tv shows created by them in separate columns 
-- for directors who have created tv shows and movies both 

SELECT 
    nd.director,
    COUNT(DISTINCT CASE WHEN n.type = 'Movie' THEN n.show_id END) AS no_of_movies,
    COUNT(DISTINCT CASE WHEN n.type = 'TV Show' THEN n.show_id END) AS no_of_tvshows
FROM netflix n
INNER JOIN netflix_director nd 
    ON n.show_id = nd.show_id
GROUP BY nd.director
HAVING COUNT(DISTINCT n.type) > 1;

-- 2 which country has highest number of comedy movies 
SELECT 
    nc.country, 
    COUNT(DISTINCT ng.show_id) AS no_of_movies
FROM netflix_genre ng
INNER JOIN netflix_country nc ON ng.show_id = nc.show_id
INNER JOIN netflix n ON ng.show_id = n.show_id
WHERE ng.genre = 'Comedies' 
  AND n.type = 'Movie'
GROUP BY nc.country
ORDER BY no_of_movies DESC
LIMIT 1;

-- 3 for each year (as per date added to netflix), which director has maximum number of movies released
WITH cte AS (
    SELECT 
        nd.director,
        YEAR(n.date_added) AS date_year,
        COUNT(n.show_id) AS no_of_movies
    FROM netflix n
    INNER JOIN netflix_director nd ON n.show_id = nd.show_id
    WHERE n.type = 'Movie'
      AND n.date_added IS NOT NULL
    GROUP BY nd.director, YEAR(n.date_added)
),
cte2 AS (
    SELECT 
        cte.*,
        ROW_NUMBER() OVER (PARTITION BY date_year ORDER BY no_of_movies DESC, director) AS rn
    FROM cte
)
SELECT director, date_year, no_of_movies
FROM cte2
WHERE rn = 1
ORDER BY date_year;

-- 4 what is average duration of movies in each genre

SELECT 
    ng.genre, 
    AVG(CAST(REPLACE(n.duration, ' min', '') AS UNSIGNED)) AS avg_duration
FROM netflix n
INNER JOIN netflix_genre ng ON n.show_id = ng.show_id
WHERE n.type = 'Movie'
GROUP BY ng.genre
ORDER BY avg_duration DESC;

-- 5  find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them 

SELECT 
    nd.director,
    COUNT(DISTINCT CASE WHEN ng.genre = 'Comedies' THEN n.show_id END) AS no_of_comedy,
    COUNT(DISTINCT CASE WHEN ng.genre = 'Horror Movies' THEN n.show_id END) AS no_of_horror
FROM netflix n
INNER JOIN netflix_genre ng ON n.show_id = ng.show_id
INNER JOIN netflix_director nd ON n.show_id = nd.show_id
WHERE n.type = 'Movie'
  AND ng.genre IN ('Comedies', 'Horror Movies')
GROUP BY nd.director
HAVING COUNT(DISTINCT ng.genre) = 2
ORDER BY no_of_comedy DESC, no_of_horror DESC;


-- See genres for a specific director
SELECT *
FROM netflix_genre
WHERE show_id IN (
    SELECT show_id
    FROM netflix_director
    WHERE director = 'Steve Brill'
)
ORDER BY genre;











