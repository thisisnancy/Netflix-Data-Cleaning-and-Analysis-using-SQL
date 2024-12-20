/*Responding to Key Queries Based on the Data*/

/*--1---what is the average duration of movies in each genre */
SELECT DISTINCT 
    ng.genre, -- The genre of the movie
    ROUND(AVG(CAST(REPLACE(duration, ' min', '') AS INTEGER)), 2) AS Avg_duration -- Calculate and round the average duration
FROM 
    netflix_final n -- Main Netflix data table
INNER JOIN 
    netflix_genre ng ON n.show_id = ng.show_id 
WHERE n.type = 'Movie' 
GROUP BY ng.genre -- Group by genre to calculate the average duration for each
ORDER BY ROUND(AVG(CAST(REPLACE(duration, ' min', '') AS INTEGER)), 2);  


/*--2---for each director count the no. of tv-shows and movies created by 
then in separate columns for directors who have created tv-shows and movies both*/
SELECT 
    nd.director,
    COUNT(DISTINCT CASE WHEN n.type = 'Movie' THEN n.show_id END) AS count_movies,
    COUNT(DISTINCT CASE WHEN n.type = 'TV Show' THEN n.show_id END) AS count_tv_shows
FROM 
    netflix_final n 
INNER JOIN 
    netflix_directors nd ON n.show_id = nd.show_id 
GROUP BY nd.director -- Group by each director
HAVING COUNT(DISTINCT n.type) > 1; 


/*--3---Which actor/actress has appeared in the highest number of Netflix movies?*/
SELECT nc.casting, COUNT(DISTINCT nc.show_id) AS number_of_movies
FROM netflix_cast nc  
INNER JOIN netflix_final n ON nc.show_id = n.show_id  -- Join with the Netflix final table to filter by movie type
WHERE n.type = 'Movie'  
GROUP BY nc.casting  -- Group by the actor/actress (casting)
ORDER BY number_of_movies DESC  
LIMIT 1;  


/*--4---which country has highest number of comedy movies*/
SELECT 
    nc.country, 
    COUNT(DISTINCT ng.show_id) AS no_of_movies -- Count of unique comedy movies available in the country
FROM 
    netflix_countries nc 
INNER JOIN 
    netflix_genre ng ON ng.show_id = nc.show_id 
INNER JOIN 
    netflix_final n ON n.show_id = nc.show_id 
WHERE 
      ng.genre = 'Comedies' 
      AND n.type = 'Movie'
GROUP BY nc.country -- Group by country to count movies available per country
ORDER BY COUNT(DISTINCT ng.show_id) DESC LIMIT 1;


/*--5---for each year (as per date added to netflix), which director has maximum 
number of movies released*/
WITH cte AS (
    SELECT 
        EXTRACT(YEAR FROM n.date_added) AS release_year,
        nd.director,
        COUNT(n.show_id) AS movie_count,
        ROW_NUMBER() OVER (
            PARTITION BY EXTRACT(YEAR FROM n.date_added) 
            ORDER BY COUNT(n.show_id) DESC
        ) AS rn 
    FROM netflix_final n
    INNER JOIN netflix_directors nd ON n.show_id = nd.show_id
    WHERE n.type = 'Movie'
    GROUP BY EXTRACT(YEAR FROM n.date_added), nd.director
)
SELECT 
    release_year,
    director,
    movie_count
FROM cte 
WHERE rn = 1
ORDER BY release_year;


/*--6---find the list of directors who have created both horror and comedy movies
display director name along with number of comdey and horror movie directed by them*/
SELECT nd.director, 
       COUNT(DISTINCT CASE WHEN ng.genre = 'Comedies' THEN n.show_id END) AS comedy_movies_count,
       COUNT(DISTINCT CASE WHEN ng.genre = 'Horror Movies' THEN n.show_id END) AS horror_movies_count
FROM netflix_directors nd
INNER JOIN netflix_genre ng ON nd.show_id = ng.show_id
INNER JOIN netflix_final n ON n.show_id = nd.show_id
WHERE n.type = 'Movie'
GROUP BY nd.director
HAVING COUNT(DISTINCT CASE WHEN ng.genre = 'Comedies' THEN n.show_id END) > 0 
   AND COUNT(DISTINCT CASE WHEN ng.genre = 'Horror Movies' THEN n.show_id END) > 0;
   

/*--7--Identify the top 5 longest movies on Netflix and their respective directors.*/
SELECT nd.director,
       CAST(REPLACE(n.duration,' min','')AS INT) AS duration_in_min
FROM netflix_directors nd 
INNER JOIN netflix_final n ON nd.show_id=n.show_id
WHERE n.type='Movie'
  AND n.duration IS NOT NULL
ORDER BY duration_in_min DESC 
LIMIT 5 ;


/*--8--How has the number of movies and TV shows added to Netflix each year changed over time?*/
SELECT EXTRACT(YEAR FROM n.date_added)as release_year,
	   COUNT(CASE WHEN n.type='Movie' THEN n.show_id END) AS total_movie_released,
	   COUNT(CASE WHEN n.type='TV Show' THEN n.show_id END) as total_tvshows_released
FROM netflix_final n
GROUP BY EXTRACT(YEAR FROM n.date_added)
ORDER BY EXTRACT(YEAR FROM n.date_added)
;


