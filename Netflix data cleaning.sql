-- DATA CLEANING

/*since there are more than one director in the director's column , 
we will split the values and create a new table*/
CREATE TABLE netflix_directors AS
SELECT DISTINCT 
    show_id, 
    TRIM(unnest(string_to_array(director, ','))) AS director -- Splitting and trimming spaces
FROM 
    staging_table;
-- view the directors table
select * from netflix_directors order by show_id;

/* same we are doing for country, cast , listed_in 
-- for country */
CREATE TABLE netflix_countries AS
SELECT DISTINCT show_id ,
	   TRIM(UNNEST(string_to_array(country,',')))as country -- Splitting and trimming spaces
FROM 
	 staging_table;
-- view the countries table
select * from netflix_countries order by show_id;

/*-- for cast*/
CREATE TABLE netflix_cast AS
SELECT DISTINCT show_id ,
       TRIM(unnest(string_to_array(casting,','))) as casting -- Splitting and trimming spaces
FROM 
	 staging_table;
-- view cast table
SELECT * FROM netflix_cast;

/*-- for listed_in (genre)*/
CREATE TABLE netflix_genre AS
SELECT DISTINCT show_id , 
	   TRIM(UNNEST(string_to_array(listed_in,','))) as genre -- Splitting and trimming spaces
FROM 
	staging_table;
-- VIEW GENRE TABLE 
SELECT * FROM netflix_genre;

-- we are also creating a table for ratings
CREATE TABLE netflix_rating AS 
SELECT show_id,rating, rating_type 
FROM staging_table;


--------- 1. CORRECTING DATATYPE --------------------
ALTER TABLE staging_table
ALTER COLUMN date_added TYPE DATE
USING date_added::DATE;


---------- 2. MANAGING DUPLICATES--------------------
-- checking if title has any duplicates
SELECT title , count(*)
FROM staging_table 
GROUP BY title
having count(*)>1;
-- We have three titles with the same data, so

/*TO ELIMINATE DUPLICATES, WE WILL CREATE A NEW TABLE WHERE EACH TITLE APPEARS ONLY ONCE.
COLUMNS FOR WHICH SEPARATE TABLES HAVE BEEN CREATED WILL BE EXCLUDED, AND THIS TABLE WILL BE NAMED "NETFLIX_FINAL".*/
CREATE TABLE netflix_final AS 
WITH cte AS 
(
SELECT * , ROW_NUMBER() OVER(PARTITION BY title,type ORDER BY show_id) AS rn
FROM staging_table
)
SELECT show_id,
	   type ,
	   title,
	   date_added ,
	   release_year,
	   duration,
	   description
FROM cte
WHERE rn=1;

---------- 3.MANAGING NULL VALUES--------------------
-- checking for null values
SELECT
    COUNT(CASE WHEN show_id IS NULL THEN 1 END) AS null_show_id,
    COUNT(CASE WHEN type IS NULL THEN 1 END) AS null_type,
    COUNT(CASE WHEN title IS NULL THEN 1 END) AS null_title,
    COUNT(CASE WHEN director IS NULL THEN 1 END) AS null_director,
    COUNT(CASE WHEN casting IS NULL THEN 1 END) AS null_casting,
    COUNT(CASE WHEN country IS NULL THEN 1 END) AS null_country,
    COUNT(CASE WHEN date_added IS NULL THEN 1 END) AS null_date_added,
    COUNT(CASE WHEN release_year IS NULL THEN 1 END) AS null_release_year,
    COUNT(CASE WHEN rating IS NULL THEN 1 END) AS null_rating,
    COUNT(CASE WHEN rating_type IS NULL THEN 1 END) AS null_rating_type,
    COUNT(CASE WHEN duration IS NULL THEN 1 END) AS null_duration,
    COUNT(CASE WHEN listed_in IS NULL THEN 1 END) AS null_listed_in,
    COUNT(CASE WHEN description IS NULL THEN 1 END) AS null_description
FROM staging_table;

-- Fill missing ratings with a default value
UPDATE staging_table
SET rating = 'Not Rated'
WHERE rating IS NULL;

/*The provided SQL query attempts to populate the netflix_countries table using data 
from a STAGING_TABLE and joins with the netflix_countries and netflix_directors tables.*/
INSERT INTO netflix_countries
SELECT show_id,m.country
FROM staging_table AS st 
INNER JOIN (
SELECT director, country 
FROM netflix_countries AS nc
INNER JOIN 
netflix_directors AS nd ON nc.show_id=nd.show_id
GROUP BY director, country 
) AS m
ON m.director=st.director
WHERE st.country is null;









