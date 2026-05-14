# Netflix Movies & TV Shows Insights with SQL

## Overview
This project focuses on analyzing Netflix movies and TV shows using MySQL.
The aim is to explore the dataset, answer key business questions, and uncover useful insights about content types, genres, ratings, actors, directors, and country-wise trends.
The SQL queries in this project help understand viewing patterns, content distribution, and overall trends within Netflix’s library.

## Objectives

-Analyze the number of Movies and TV Shows on Netflix.
-Identify the most common content ratings.
-Explore content by release year, country, and duration.
-Categorize content using keywords from the description.
-Use SQL queries to extract clear and useful insights from the dataset.


## Structure & basic data exploration

```sql
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
```

##  [DATA ANALYSIS BUSINESS PROBLEM `S AND QUERY]

### Q1.Count the number of Movies vs TV shows.
```sql
SELECT type, 
	COUNT(*) AS Count 
FROM netflix
GROUP BY type;
```


### Q2.Find the most common ratings for movies and TV shows.

```sql
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
```


### Q3.List all movies released in a specific year (2020).

```sql
SELECT
	* FROM netflix
WHERE
	type="Movie" 
    AND
    release_year=2020;
```

### Q4.Find the top 5 countries with the most content on netflix.

```sql
SELECT
	country,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;
```


### Q5.Identify the longest movie.

```sql
SELECT 
	* FROM netflix
WHERE
	type = "Movie"
    AND
    duration= (SELECT MAX(duration) FROM netflix);
```


### Q6.Find content added in last 5 years.

```sql
SELECT
	  *
FROM netflix
WHERE 
	STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
```


### Q7.Find all the TV/movies shows by director ' S. Shankar'.

```sql
SELECT 
	*
FROM  netflix
WHERE 
	director  LIKE "%S. Shankar%";
```


### Q8.Find all the TV shows with more than 5 seasons.

```sql
SELECT 
	* FROM netflix
WHERE 
	type= "TV Show"
    AND
	duration >"5 seasons";
```


### Q9.Count the number of content items in each genre.

```sql
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
```


### Q10.Find each year and average numbers of content release by india on netflix.return top 5 year with highest avg content release

```sql
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
```

### Q11.List all movies that are documentaries
```sql
SELECT
	*
FROM netflix
WHERE
	listed_in LIKE "%documentaries%";
```


### Q12.Find all content without a director

```sql
SELECT *
FROM netflix
WHERE 
	director IS NULL
    OR
    director = '';
```


### Q13.Find how many movies actor 'vijay sethupati' appeared in last 10 years

```sql
SELECT 
    *
FROM netflix
WHERE
    LOWER(`cast`) LIKE '%vijay sethupathi%'   
    AND release_year >= YEAR(CURDATE()) - 10;
```


### Q14.Find the top 5 actors who have appeared in highest number of movies produced in india.

```sql
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
```


### Q15.Categorize the content based on presence of the keywords 'kill' and 'violence' in the description field. 
   label content containing these keywords as 'bad' and all other content as 'good'. count how many items fall into each category.

```sql
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
```


## Findings and Conclusion

- **Content Distribution:** Netflix has a wide mix of movies and TV shows with different genres and rating categories.
- **Common Ratings:** The most frequent ratings help identify the general target audience of Netflix content.
- **Geographical Insights:** Country-wise analysis, including India’s yearly content share, shows how content is spread across regions.
- **Content Categorization:** Keyword-based categorization gives a better understanding of the themes and nature of the available content.

Overall, this analysis offers a clear overview of Netflix’s content library and supports content-related decision-making.



