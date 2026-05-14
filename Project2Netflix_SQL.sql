--  [CREATE DATABASE]
CREATE DATABASE project2Netflix_sql;

--  [DROP TABLE IF PRESENT]
DROP TABLE IF EXISTS netflix;

--  [CREATE TABLE IN DATABASE]
CREATE TABLE Netflix
		(
		   show_id VARCHAR(5),
        type VARCHAR(10),
        title VARCHAR(125),
        director VARCHAR(220),
        cast VARCHAR(800),
        country VARCHAR(150),
        date_added VARCHAR(50),
        release_year INT,
        rating	VARCHAR(10),
        duration VARCHAR(15),
        listed_in VARCHAR(155),
        description VARCHAR(300)
    )

-- 		[DATA EXPLORATION]

--  [DISPLAY ALL THE RECORDS]
SELECT * FROM netflix; 

--  [COUNT TOTAL RECORDS IN THE TABLE]
SELECT COUNT(*) AS total_records 
	FROM netflix;

-- [DISPLAY TYPE (NO REPETATION)] 
SELECT
	DISTINCT type
FROM netflix;


--        [DATA ANALYSIS PROBLEM & QUERY]
-- Q1.Count the number of Movies vs TV shows.
SELECT type, 
	COUNT(*) AS Count 
FROM netflix
GROUP BY type;

-- Q2.Find the most common ratings for movies and TV shows.
SELECT
	type,
    rating
FROM
(
SELECT
	   type,
	   rating,
       COUNT(*),
       RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC )AS ranking
FROM netflix
GROUP BY 1,2
) AS t1
WHERE ranking=1;

-- Q3.List all movies released in a specific year (2020).
SELECT
	* FROM netflix
WHERE
	type="Movie" 
    AND
    release_year=2020;

-- Q4.Find the top 5 countries with the most content on netflix.
SELECT
	country,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

-- Q5.Identify the longest movie.
SELECT 
	* FROM netflix
WHERE
	type = "Movie"
    AND
    duration= (SELECT MAX(duration) FROM netflix);

-- Q6.Find content added in last 5 years.
SELECT
	  *
FROM netflix
WHERE 
	STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
    
-- Q7.Find all the TV/movies shows by director ' S. Shankar'.
SELECT 
	*
FROM  netflix
WHERE 
	director  LIKE "%S. Shankar%";

-- Q8.Find all the TV shows with more than 5 seasons.
SELECT 
	* FROM netflix
WHERE 
	type= "TV Show"
    AND
	duration >"5 seasons";
    
-- Q9.Count the number of content items in each genre.
WITH RECURSIVE genre_split AS (
    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2) AS rest
    FROM netflix

    UNION ALL

    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)),
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM genre_split
    WHERE rest <> ''
)
SELECT
    genre,
    COUNT(show_id) AS total_content
FROM genre_split
GROUP BY 1
ORDER BY 2 DESC;

-- Q10.Find each year and average numbers of content release by india on netflix.return top 5 year with highest avg content release
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100,
        2
    ) AS avg_release_percent
FROM netflix
WHERE country = 'India'
GROUP BY 1, 2
ORDER BY 4 DESC
LIMIT 5;

-- Q11.List all movies that are documentaries
SELECT
	*
FROM netflix
WHERE
	listed_in LIKE "%documentaries%";

-- Q12.Find all content without a director
SELECT *
FROM netflix
WHERE 
	director IS NULL
    OR
    director = '';

-- Q13.Find how many movies actor 'vijay sethupati' appeared in last 10 years
SELECT 
    *
FROM netflix
WHERE
    LOWER(`cast`) LIKE '%vijay sethupathi%'   -- case-insensitive match
    AND release_year >= YEAR(CURDATE()) - 10;
    
-- Q14.Find the top 5 actors who have appeared in highest number of movies produced in india.
SELECT actor, COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(`cast`, ',', 1)) AS actor
    FROM netflix
    WHERE country LIKE '%India%' AND type = 'Movie'

    UNION ALL

    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`cast`, ',', 2), ',', -1))
    FROM netflix
    WHERE country LIKE '%India%' AND type = 'Movie'

    UNION ALL

    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`cast`, ',', 3), ',', -1))
    FROM netflix
    WHERE country LIKE '%India%' AND type = 'Movie'
) AS all_actors
WHERE actor <> ''
GROUP BY actor
ORDER BY total_content DESC
LIMIT 5;
    
-- Q15.Categorize the content based on presence of the keywords 'kill' and 'violence' in the description field. 
-- label content containing these keywords as 'bad' and all other content as 'good'. count how many items fall into each category.
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN LOWER(description) LIKE '%kill%' 
              OR LOWER(description) LIKE '%violence%' 
            THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1;