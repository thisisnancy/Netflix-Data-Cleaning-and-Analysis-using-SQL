CREATE TABLE staging_table (
    show_id VARCHAR(50) PRIMARY KEY,  -- Unique identifier for the show
    type VARCHAR(50),                -- Type of media (e.g., Movie, TV Show)
    title VARCHAR(255),              -- Title of the media
    director VARCHAR(255),           -- Director's name
    casting TEXT,                    -- Cast members (list stored as text)
    country VARCHAR(250),            -- Country of production
    date_added VARCHAR(20),          -- Date the media was added (stored as DATE)
    release_year INT,                -- Year the media was released
    rating VARCHAR(10),               -- Rating (e.g., PG, R, TV-MA)
	rating_type VARCHAR(50),         -- Rating_type 
    duration VARCHAR(50),            -- Duration (e.g., '90 min', '1 Season')
    listed_in TEXT,                  -- Categories/Genres
    description TEXT                 -- Description of the media
);

-- using copy commmand in psql to load data into the staging_data table (For postgresql)
\c staging_table from 'C:\Users\sonin\DATA SCIENCE\SQL\netflix_analytics\netflix_titles.csv' DELIMITER ',' CSV HEADER ENCODING 'LATIN1'

-- viewing staging_table
SELECT * FROM staging_table;