-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(210),
	casts VARCHAR(1000),
	country VARCHAR(200),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)

);
SELECT * FROM netflix;
----------------------------------------------------------------------
--Business Problems and Solutions

--SHOW TOTAL CONTENT
SELECT COUNT(*) AS total_content FROM netflix;
--RESULT: 8807
-------------------------------------------------------------------------
--lIST WHAT ARE THE DIFFERENT KINDS OF CONTENT AVALABLE
SELECT DISTINCT(type) FROM netflix;
--result: Movie AND TV Show
-----------------------------------------------------------------------
--Query 1. Count the Number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
--Result 1: Our data shows that Movie has 6131 counts whereas TV Shows have 2676 counts.
------------------------------------------------------------------------------
--Query 2. Find the Most Common Rating for Movies and TV Shows

SELECT
	type,
	rating,
	COUNT(*)AS total_rating
FROM netflix
GROUP BY 1,2
ORDER BY 1,3 DESC;
-- This gives us total rating for each rating category in movies and tv shows,
-- we want have just the highest rating given from movies and TV-shows
-- we will use windows function to extract only the highest rating from each cataerogy

SELECT
	type,
	rating,
	COUNT(*)AS total_rating,
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*)DESC) AS RANKING
FROM netflix
GROUP BY 1,2;
--ORDER BY 1,3 DESC;
--nOW we need to extract only the first rank from the abouve query 
--for this we have to enclose this query as subquery for main query

SELECT type, rating --ranking
FROM
	(SELECT
		type,
		rating,
		COUNT(*)AS total_rating,
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*)DESC) AS RANKING
	FROM netflix
	GROUP BY 1,2) as t1
WHERE ranking = 1;
-- RESULT: rating TV-MA is higest among both categories.
----------------------------------------------------------------------------------
--qUERY 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix
LIMIT 5;

SELECT type,title 
FROM netflix
WHERE type='Movie' AND release_year=2020;
--------------------------------------------------------------------------------
--qUERY 4. Find the Top 5 Countries with the Most Content on Netflix

SELECT country, COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
--RESULT: WE GET COUNT BY COUNTRY COMBINATIONS ALSO SO WE NEED TO SPLIT COUNTRIES

--SEPEERATE THE COUNTRIES BY STRING_TO_ARRAY FUNCTION
SELECT 
	STRING_TO_ARRAY(country,',') AS new_country
FROM netflix;
-- IT STILL HAVE MULTIPLE COUNTRIES SO WE NEED TO UNNEST THEM
SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) AS new_country
FROM netflix;
-- IT SEPERATED THE COUNTRIES TOTALLY,
--THERE WAS LEADING SPACE IN SOME COUNTRIES SO NEED TO TRIM THAT TRIM FUNCTION, 
--NOW THE FINAL QUERY WILL BE
SELECT 
	--country,
	TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS new_country,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
--RESULT:
--"United States"	3690
--"India"	1046
--"United Kingdom"	806
--"Canada"	445
--"France"	393
-------------------------------------------------------------------------------
--qUERY 5. Identify the Longest Movie
SELECT * FROM netflix LIMIT 5;

SELECT title, duration FROM netflix
WHERE type='Movie' AND 
	duration = (SELECT MAX(duration) FROM netflix);
--------------------------------------------------------------------------------
--6. Find Content Added in the Last 5 Years
-- NEED TO CONVERT THE DATE_ADDED COLUMN TO ACTUTAL DATE FORMAT TO EXTRACT THE YEAR

SELECT 
	*,
	TO_DATE(date_added, 'Month DD,YYYY') AS added_date
FROM netflix;

--fINAL QUERY TO EXTRACT ONLY FROM LAST 5 YEARS

SELECT 
	*
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 YEARS';
--EXTRACT COUNTS BY CONTENT TYPE IN LAST 5 YEARS

SELECT 
	--*
	type,COUNT(*)
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 YEARS'
GROUP BY type;
--------------------------------------------------------------------------------
--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT * FROM netflix LIMIT 5;
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

--LOOKING FOR COUNTS
SELECT COUNT(*)
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

--RESULT: 22
--------------------------------------------------------------------------------
--8. List All TV Shows with More Than 5 Seasons
--WE NEED TO SPLIT DURATION COULMN TO EXTRACT FIRST VALUE--CONVERT IT TO NUMERIC
SELECT 
	*, 
	SPLIT_PART(duration, ' ', 1) AS SEASONS 
FROM netflix
WHERE type='TV Show' ;

--FINAL QUERY TO EXTRACT MORE THAN 5 SEASONS
SELECT 
	* 
	FROM netflix
WHERE type='TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5 ;

--------------------------------------------------------------------------------
--9. Count the Number of Content Items in Each Genre
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(LISTED_IN,','))) AS GENRE,
	COUNT(SHOW_ID)
FROM NETFLIX
GROUP BY 1
ORDER BY 2 DESC;
--------------------------------------------------------------------------------
--10.Find each year and the average numbers of content release in united states on netflix.
SELECT * FROM netflix LIMIT 5;

SELECT 
	release_year,
	COUNT(*)
FROM netflix
WHERE country LIKE '%United States%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

----RELEASE FROM INDIA
SELECT 
	release_year,
	COUNT(*)
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
--10.Find each year and the average numbers of content ADDED in united states on netflix.

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) as added_year,
	COUNT(*)
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
 -- In order to calculate the average number we need total count added from india
SELECT 
	COUNT(*) as total_count
FROM netflix
WHERE country LIKE '%India%';

-- for average count added

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) as added_year,
	COUNT(*) AS total_count,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country LIKE '%India%')::numeric * 100 
	,2)as AVERAGE_COUNT
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1 
ORDER BY 3 DESC;

------------------------------------------------------------------------------

--11. List All Movies that are Documentaries
--using ILIKE will gather capital or small letters both
SELECT * FROM netflix LIMIT 10;
SELECT 
	*
FROM netflix
WHERE LISTED_IN ILIKE '%Documentaries%';

SELECT 
	count(*) as total_count
FROM netflix
WHERE LISTED_IN LIKE '%Documentaries%';

--Result: 869
-------------------------------------------------------------------------------
--12. Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

SELECT COUNT(*) as Null_directors 
FROM netflix
WHERE director IS NULL;

--Result: 2634
--------------------------------------------------------------------------------
--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 20 Years

SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

SELECT COUNT(*) as total_movies 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
--Result: 2 movies

SELECT COUNT(*) as total_movies 
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 20;
-- Result: 10 movies
---------------------------------------------------------------------------------  
--14. Find the Top 5 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 5;
--Result:
" Anupam Kher"	36
" Paresh Rawal"	24
"Shah Rukh Khan"	24
" Om Puri"	23
"Akshay Kumar"	22

--Top 5 actors in United states
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'United States'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 5;
--Result:
" Adam Sandler"	20
" Fred Tatasciore"	15
" Molly Shannon"	14
" Erin Fitzgerald"	13
" Samuel L. Jackson"	13
-------------------------------------------------------------------------------
--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

select * from netflix
where description  ILIKE '%kill%' 
	or 
	description ILIKE '%violence%';

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;

---with CTE

WITH CATEGORY_TABLE
AS (
	SELECT 
	        CASE 
	            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
	            ELSE 'Good'
	        END AS category
	    FROM netflix
	)

SELECT 
	category, 
	COUNT(*) as Total_Content
FROM CATEGORY_TABLE
GROUP BY 1
--RESULT:
--"Good"	8465
--"Bad"	342

WITH CATEGORY_TABLE
AS (
	SELECT 
	        CASE 
	            WHEN description ILIKE '%happy%' OR description ILIKE '%love%' OR description ILIKE '%good%'THEN 'Good'
	            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
				ELSE 'Normal'
	        END AS category
	    FROM netflix
	)

SELECT 
	category, 
	COUNT(*) as Total_Content
FROM CATEGORY_TABLE
GROUP BY 1
--------------------------------------------------------------
















