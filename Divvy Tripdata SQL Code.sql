-------------------------------------------------------------------------------------------------------------------------

/* Importing Data */

-- Creating Database
CREATE DATABASE divvy_trip;

-- We first created the structure of the table for the data in '2021-09-divvy_tripdata' using 'create table' option by defining the columns and its datatypes
-- Importing data to the table
LOAD DATA LOCAL INFILE 
  'C:/Users/Acer/Desktop/Arya/Portfolio Projects/Google Data Analytics Capstone Project/Case Study 1 - Cyclistic/Divvy Tripdata/CSV Files/2022-08-divvy_tripdata.csv' 
INTO TABLE divvy_trip.`2022-08-divvy_tripdata` 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ride_id,rideable_type,@started_at,@ended_at,start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual)
SET started_at = STR_TO_DATE(@started_at, '%d-%m-%Y %H:%i:%s'),
	ended_at = STR_TO_DATE(@ended_at, '%d-%m-%Y %H:%i:%s');  

-- To check whether the data is imported correctly
-- We will be checking if the data are loaded in the appropriate columns and also the number of rows in it
SELECT * FROM divvy_trip.`2022-08-divvy_tripdata`;
SELECT COUNT(*) FROM divvy_trip.`2022-08-divvy_tripdata`;

-- We are using the structure of the table '2021-09-divvy_tripdata' for creating other tables
CREATE TABLE divvy_trip.`2022-08-divvy_tripdata` LIKE divvy_trip.`2021-09-divvy_tripdata`;

-- The same code as above is used to import data into other tables

-------------------------------------------------------------------------------------------------------------------------

-- Combining all the 12 tables into a single table
DROP TABLE IF EXISTS divvy_trip.divvy_tripdata;
CREATE TABLE divvy_trip.divvy_tripdata AS
(
(
SELECT * FROM divvy_trip.`2021-09-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2021-10-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2021-11-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2021-12-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2022-01-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2022-02-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2022-03-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2022-04-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2022-05-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2022-06-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2022-07-divvy_tripdata`
)
UNION
(
SELECT * FROM divvy_trip.`2022-08-divvy_tripdata`
)
);

-- Checking the total number of rows in the new table
SELECT COUNT(*) FROM divvy_trip.divvy_tripdata;

-- Creating a copy of the above table to work with
DROP TABLE IF EXISTS divvy_trip.divvy_trip_working_data;
CREATE TABLE divvy_trip.divvy_trip_working_data AS SELECT * FROM divvy_trip.divvy_tripdata;

-------------------------------------------------------------------------------------------------------------------------

/* Initial Exploration */ 

SELECT * FROM divvy_trip.divvy_trip_working_data LIMIT 50;

---------------------------------------------------------------------

-- Checking for NULL values in all columns
-- All columns are separately checked for NULL values
SELECT
  *
FROM 
  divvy_trip.divvy_trip_working_data
WHERE 
  member_casual IS NULL;

---------------------------------------------------------------------

-- Checking for 'null' entries in all columns
SELECT
  COUNT(*) AS null_value_count
FROM 
  divvy_trip.divvy_trip_working_data
WHERE 
  LOWER(member_casual) = 'null';

---------------------------------------------------------------------

-- Checking for empty values in all columns
SELECT
  COUNT(*) AS empty_value_count
FROM divvy_trip.divvy_trip_working_data
WHERE member_casual = '';

---------------------------------------------------------------------

-- Checking for zero datetime in started_at and ended_at columns
SELECT
  COUNT(*) AS invalid_datetime_count
FROM 
  divvy_trip.divvy_trip_working_data
WHERE 
  ended_at = '0000-00-00 00:00:00';

---------------------------------------------------------------------

-- Number of unique ride id
SELECT
  COUNT(DISTINCT ride_id) AS unique_ride_id_count
FROM
  divvy_trip.divvy_trip_working_data;

---------------------------------------------------------------------

-- Distinct values rideable_type
SELECT 
  DISTINCT rideable_type AS distinct_rideable_type
FROM 
  divvy_trip.divvy_trip_working_data; 
  
---------------------------------------------------------------------

-- Number of unique start_station_name and start_station_id
SELECT
  COUNT(DISTINCT start_station_name) AS unique_start_station_name_count,
  COUNT(DISTINCT start_station_id) AS unique_start_station_id_count
FROM
  divvy_trip.divvy_trip_working_data;
  
-- Number of unique end_station_name (1453 distinct values) and end_station_id (1281 distinct values)
SELECT
  COUNT(DISTINCT end_station_name) AS unique_end_station_name_count,
  COUNT(DISTINCT end_station_id) AS unique_end_station_id_count
FROM
  divvy_trip.divvy_trip_working_data;

---------------------------------------------------------------------

-- Number of unique start_lat and start_lng
SELECT
  COUNT(*) AS unique_start_lattitude_and_longitude_count
FROM
(SELECT
  DISTINCT 
  start_lat,
  start_lng
FROM
  divvy_trip.divvy_trip_working_data) AS unique_start_lattitude_and_longitude;

-- Number of unique end_lat and end_lng
SELECT
  COUNT(*) AS unique_end_lattitude_and_longitude_count
FROM
(SELECT
  DISTINCT 
  end_lat,
  end_lng
FROM
  divvy_trip.divvy_trip_working_data) AS unique_end_lattitude_and_longitude;
  
---------------------------------------------------------------------

-- Distinct values in member_casual
SELECT 
  DISTINCT member_casual AS unique_member_casual
FROM 
  divvy_trip.divvy_trip_working_data;
  
---------------------------------------------------------------------

-- Maximum and minimum starting date and ending date
SELECT
  MIN(started_at) AS minimum_starting_time, -- 2021-09-01 00:00:00
  MAX(started_at) AS maximum_starting_time, -- 2022-08-31 23:59:39
  MIN(ended_at) AS minimum_ending_time,     -- 2021-09-01 00:00:00
  MAX(ended_at) AS maximum_ending_time      -- 2022-09-06 21:49:04      
FROM 
  divvy_trip.divvy_trip_working_data;

-- The record having maximum end date - The duration of the trip is greater than 24 hours and has no end station
SELECT
  *
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  DATE(ended_at) = (SELECT MAX(DATE(ended_at)) FROM divvy_trip.divvy_trip_working_data);
  
---------------------------------------------------------------------

-- Records without start station id and name
SELECT
  COUNT(*) AS no_start_station_name_and_id_records_count
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  start_station_name = ''
AND
  start_station_id = '';
  
-- Records with start station id but no name
SELECT
  COUNT(*) AS no_start_station_name_and_id_records_count
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  start_station_name = ''
AND
  start_station_id <> '';
  
-- Records with start station name but no id
SELECT
  COUNT(*) AS no_start_station_name_and_id_records_count
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  start_station_name <> ''
AND
  start_station_id = '';

---------------------------------------------------------------------

-- Records without end station id and name
SELECT
  COUNT(*) AS no_end_station_name_and_id_records_count
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  end_station_name = ''
AND
  end_station_id = '';
  
-- Records with end station id but no name
SELECT
  COUNT(*) AS no_end_station_name_and_id_records_count
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  end_station_name = ''
AND
  end_station_id <> '';
  
-- Records with end station name but no id
SELECT
  COUNT(*) AS no_end_station_name_and_id_records_count
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  end_station_name <> ''
AND
  end_station_id = '';
  
---------------------------------------------------------------------

-- Records with no start and end stations
SELECT
  COUNT(*) AS no_start_and_end_stations_record_count
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  start_station_id = ''
AND
  start_station_name = ''
AND  
  end_station_id = ''
AND
  end_station_name = '';
  
---------------------------------------------------------------------

-- Records without start lattitude and start longitude
SELECT
  COUNT(*) AS records_without_start_lattitude_and_longitude
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  start_lat = ''
AND
  start_lng = '';
  
---------------------------------------------------------------------

-- Records without end lattitude and end longitude
SELECT
  COUNT(*) AS records_without_end_lattitude_and_longitude
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  end_lat = ''
AND
  end_lng = '';
  
-------------------------------------------------------------------------------------------------------------------------

/* Data Cleaning */

-- We will first populate those records with start station id but missing start station name

-- Records with start_station_id but no start_station_name
SELECT 
    start_station_id, 
    start_station_name
FROM
    divvy_trip.divvy_trip_working_data
WHERE
  start_station_id <> ''
AND 
  start_station_name = '';
  
-- Checking whether the station ids have correponding station names in any other record
SELECT
    DISTINCT
    start_station_id,
    start_station_name
FROM 
    divvy_trip.divvy_trip_working_data
WHERE start_station_id IN (SELECT start_station_id FROM divvy_trip.divvy_trip_working_data WHERE start_station_id <> '' AND start_station_name = '');

-- To populate the start_station_name using start_station_id, we are self joining the table to join records with start_staion_name to those without start_station_name
SELECT
  table_1.start_station_id,
  table_1.start_station_name,
  table_2.start_station_id,
  table_2.start_station_name
FROM 
  divvy_trip.divvy_trip_working_data AS table_1
JOIN
  divvy_trip.divvy_trip_working_data AS table_2
ON
  table_1.start_station_id = table_2.start_station_id
AND
  table_1.start_station_name <> table_2.start_station_name
WHERE
  table_1.start_station_id <> '' AND table_1.start_station_name = '';
 
-- Updating the table to include missing start_station_names
UPDATE divvy_trip.divvy_trip_working_data AS table_1
	JOIN
       divvy_trip.divvy_trip_working_data AS table_2
    ON
       table_1.start_station_id = table_2.start_station_id
    AND
       table_1.start_station_name <> table_2.start_station_name
SET table_1.start_station_name = table_2.start_station_name
WHERE table_1.start_station_id <> '' AND table_1.start_station_name = '';

---------------------------------------------------------------------

-- Finding duplicates
WITH cte_row_number AS
(
SELECT
  *,
  ROW_NUMBER() OVER(PARTITION BY ride_id, rideable_type, started_at, ended_at, 
					start_station_name, start_station_id, end_station_name, end_station_id, 
                    start_lat, start_lng, end_lat, end_lng, member_casual
                    ORDER BY ride_id) AS row_no
FROM 
  divvy_trip.divvy_trip_working_data
)
SELECT
  *
FROM
  cte_row_number
WHERE 
  row_no > 1;

---------------------------------------------------------------------

-- Replacing '' with NULL
UPDATE divvy_trip.divvy_trip_working_data
SET start_station_name = NULL
WHERE start_station_name = '';
  
UPDATE divvy_trip.divvy_trip_working_data
SET start_station_id = NULL
WHERE start_station_id = '';

UPDATE divvy_trip.divvy_trip_working_data
SET end_station_name = NULL
WHERE end_station_name = '';

UPDATE divvy_trip.divvy_trip_working_data
SET end_station_id = NULL
WHERE end_station_id = '';

UPDATE divvy_trip.divvy_trip_working_data
SET end_lat = NULL
WHERE end_lat = '';

UPDATE divvy_trip.divvy_trip_working_data
SET end_lng = NULL
WHERE end_lng = '';

---------------------------------------------------------------------

-- Start station ids with more than 1 start station
WITH start_station_id_with_multiple_names AS
(
SELECT
  start_station_id,
  COUNT(DISTINCT start_station_name) AS number_of_start_stations
FROM 
  divvy_trip.divvy_trip_working_data
GROUP BY
  start_station_id
HAVING
  COUNT(DISTINCT start_station_name) > 1
)
-- The above ids with corresponding station names 
SELECT
  DISTINCT
  start_station_id,
  start_station_name
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  start_station_id IN (SELECT start_station_id FROM start_station_id_with_multiple_names)
ORDER BY
  start_station_id;

---------------------------------------------------------------------

-- Distinct start station ids
SELECT
  DISTINCT
  start_station_id
FROM 
  divvy_trip.divvy_trip_working_data_duplicate
ORDER BY
  start_station_id;
 
---------------------------------------------------------------------

-- Start stations with more than one id
WITH start_station_name_with_multiple_ids AS
(
SELECT
  start_station_name,
  COUNT(DISTINCT start_station_id) AS number_of_start_station_ids
FROM 
  divvy_trip.divvy_trip_working_data
GROUP BY
  start_station_name
HAVING
  COUNT(DISTINCT start_station_id) > 1
)
-- The above names with corresponding station ids 
SELECT
  DISTINCT
  start_station_name,
  start_station_id,
  MIN(DATE(started_at)) AS min_starting_date
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  start_station_name IN (SELECT start_station_name FROM start_station_name_with_multiple_ids)
GROUP BY
  start_station_name,
  start_station_id  
ORDER BY
  start_station_name;

---------------------------------------------------------------------

-- Distinct start station names
SELECT
  DISTINCT
  start_station_name
FROM 
  divvy_trip.divvy_trip_working_data
ORDER BY
  start_station_name;
  
---------------------------------------------------------------------

-- Repeating the above procedure for end station id and name

-- End station ids with more than 1 end station
 WITH end_station_id_with_multiple_names AS
(
SELECT
  end_station_id,
  COUNT(DISTINCT end_station_name) AS number_of_end_stations
FROM 
  divvy_trip.divvy_trip_working_data
GROUP BY
  end_station_id
HAVING
  COUNT(DISTINCT end_station_name) > 1
)
-- The above ids with corresponding station names 
SELECT
  DISTINCT
  end_station_id,
  end_station_name
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  end_station_id IN (SELECT end_station_id FROM end_station_id_with_multiple_names)
ORDER BY
  end_station_id;

---------------------------------------------------------------------

-- Distinct end station ids
SELECT
  DISTINCT
  end_station_id
FROM 
  divvy_trip.divvy_trip_working_data
ORDER BY
  end_station_id;

---------------------------------------------------------------------

-- End stations with more than one id
WITH end_station_name_with_multiple_ids AS
(
SELECT
  end_station_name,
  COUNT(DISTINCT end_station_id) AS number_of_end_station_ids
FROM 
  divvy_trip.divvy_trip_working_data
GROUP BY
  end_station_name
HAVING
  COUNT(DISTINCT end_station_id) > 1
)
-- The above names with corresponding station ids 
SELECT
  DISTINCT
  end_station_name,
  end_station_id,
  MIN(DATE(started_at)) AS min_starting_date
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  end_station_name IN (SELECT end_station_name FROM end_station_name_with_multiple_ids)
GROUP BY
  end_station_name,
  end_station_id  
ORDER BY
  end_station_name;

---------------------------------------------------------------------

-- Distinct end station names
SELECT
  DISTINCT
  end_station_name
FROM 
  divvy_trip.divvy_trip_working_data
ORDER BY
  end_station_name;
  
---------------------------------------------------------------------

-- Number of start station represented by each combination of start lattitudes and longitudes
SELECT
  start_lat,
  start_lng,
  start_station_name,
  COUNT(DISTINCT start_station_name) AS number_of_start_stations
FROM
  divvy_trip.divvy_trip_working_data
GROUP BY
  start_lat,
  start_lng
HAVING
  COUNT(DISTINCT start_station_name) > 1;
  
---------------------------------------------------------------------

-- Number of end station represented by each combination of end lattitudes and longitudes
SELECT
  end_lat,
  end_lng,
  COUNT(DISTINCT end_station_name) AS number_of_end_stations
FROM
  divvy_trip.divvy_trip_working_data
GROUP BY
  end_lat,
  end_lng
HAVING
  COUNT(DISTINCT end_station_name) > 1;
  
---------------------------------------------------------------------

-- Deleting records with null start or end station names
DELETE FROM divvy_trip.divvy_trip_working_data
WHERE start_station_name IS NULL OR end_station_name IS NULL;

-- Checking for null values
SELECT 
  COUNT(*)
FROM 
  divvy_trip.divvy_trip_working_data
WHERE
  start_station_name IS NULL
OR
  start_station_id IS NULL
OR
  end_station_name IS NULL
OR
  end_station_id IS NULL
OR
  end_lat IS NULL
OR
  end_lng IS NULL;
  
---------------------------------------------------------------------

-- Records with warehouses as their start or end stations
SELECT
  COUNT(*)
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  start_station_name IN ('NewHastings',
 'WEST CHI - WATSON',
 'WestChi',
 'DIVVY CASSETTE REPAIR MOBILE STATION',
 'Hastings WH 2',
'Base - 2132 W Hubbard',
'Base - 2132 W Hubbard Warehouse')
OR
  end_station_name IN ('NewHastings',
 'WEST CHI - WATSON',
 'WestChi',
 'DIVVY CASSETTE REPAIR MOBILE STATION',
 'Hastings WH 2',
'Base - 2132 W Hubbard',
'Base - 2132 W Hubbard Warehouse'
); 

-- Deleting those records with warehouses as their start or end stations
DELETE FROM  divvy_trip.divvy_trip_working_data
WHERE
  start_station_name IN ('NewHastings',
 'WEST CHI - WATSON',
 'WestChi',
 'DIVVY CASSETTE REPAIR MOBILE STATION',
 'Hastings WH 2',
'Base - 2132 W Hubbard',
'Base - 2132 W Hubbard Warehouse')
OR
  end_station_name IN ('NewHastings',
 'WEST CHI - WATSON',
 'WestChi',
 'DIVVY CASSETTE REPAIR MOBILE STATION',
 'Hastings WH 2',
'Base - 2132 W Hubbard',
'Base - 2132 W Hubbard Warehouse'
);  

---------------------------------------------------------------------

-- Duration of each trip in minutes
SELECT
  *,
  ROUND(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))/60, 2) AS trip_duration_in_minutes
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  ROUND(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))/3600, 2) NOT BETWEEN 1 AND 1440;
  
-- Deleting those records having duration < 1 minute or > a day  
DELETE FROM  divvy_trip.divvy_trip_working_data
WHERE
  ROUND(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))/60, 2) NOT BETWEEN 1 AND 1440; 
  
---------------------------------------------------------------------

-- Cleaning rideable_type
-- We are changing the first letter of each word to upper case and replacing '_' with a space
-- Extracting the first letter using 'SUBSTRING' and changing it to upper case
-- Concatenated the changed letter with the rest of the string
-- Replaced '_' with a space
-- Changed 'b' in bike to uppercase using 'REPLACE' (since there was only one 'b' in each of the rideable types) 
SELECT
  rideable_type,
  REPLACE(REPLACE(CONCAT(UPPER(SUBSTRING(rideable_type, 1, 1)), SUBSTRING(rideable_type, 2)), '_', ' '), 'b', 'B') AS ride
FROM
  divvy_trip.divvy_trip_working_data;

-- Updating the changes  
UPDATE divvy_trip.divvy_trip_working_data
SET rideable_type = REPLACE(REPLACE(CONCAT(UPPER(SUBSTRING(rideable_type, 1, 1)), SUBSTRING(rideable_type, 2)), '_', ' '), 'b', 'B');

-- Checking the length of entries in 'rideable_type' column
SELECT
  rideable_type,
  LENGTH(rideable_type) AS length
FROM
  divvy_trip.divvy_trip_working_data;
  
-- As per Divvy's information, the classic and docked bikes are the same. So we have to change 'Docked Bike' to 'Classic Bike'
SELECT
  COUNT(*)
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  rideable_type = 'Docked Bike';
  
UPDATE divvy_trip.divvy_trip_working_data
SET rideable_type = 'Classic Bike'
WHERE rideable_type = 'Docked Bike';
  
---------------------------------------------------------------------

-- Cleaning member_casual
-- Converting the first letter into uppercase and concatenated with the rest of the string
SELECT
  member_casual,
  CONCAT(UPPER(SUBSTRING(member_casual, 1, 1)), SUBSTRING(member_casual, 2)) AS ride
FROM
  divvy_trip.divvy_trip_working_data;

-- Updating the changes  
UPDATE divvy_trip.divvy_trip_working_data
SET member_casual = CONCAT(UPPER(SUBSTRING(member_casual, 1, 1)), SUBSTRING(member_casual, 2));

-- Checking the length of entries in 'member_casual' column
SELECT
  member_casual,
  LENGTH(member_casual) AS length
FROM
  divvy_trip.divvy_trip_working_data;

-- Since the length was 7 for all entries in the column, checking for the ASCII code of last character 
SELECT
  member_casual,
  ASCII(RIGHT(member_casual, 1)) AS last_character_code
FROM
  divvy_trip.divvy_trip_working_data;

-- It was the carriage return character (\r)
-- Removing the last character - since both distinct entries of 'member_casual' has only 6 letters, the first 6 characters are extracted using 'LEFT'  
SELECT
  member_casual,
  LENGTH(member_casual),
  LEFT(member_casual, 6),
  LENGTH(LEFT(member_casual, 6))
FROM
    divvy_trip.divvy_trip_working_data;

-- Updating the column entries
UPDATE divvy_trip.divvy_trip_working_data
SET member_casual = LEFT(member_casual, 6);

---------------------------------------------------------------------

-- Maximum and minimum starting date and ending date after cleaning the data
SELECT
  MIN(started_at) AS minimum_starting_time, -- 2021-09-01 00:00:00
  MAX(started_at) AS maximum_starting_time, -- 2022-08-31 23:58:50
  MIN(ended_at) AS minimum_ending_time,     -- 2021-09-01 00:03:00
  MAX(ended_at) AS maximum_ending_time      -- 2022-09-01 19:10:49
FROM 
  divvy_trip.divvy_trip_working_data;

-------------------------------------------------------------------------------------------------------------------------

/* Data Analysis */

-- Total number of trips and its percent by rider type
SELECT
  member_casual,
  COUNT(*) AS total_count,
  ROUND(COUNT(*)/ (SELECT COUNT(*) FROM divvy_trip.divvy_trip_working_data)*100, 2) AS percent
FROM
  divvy_trip.divvy_trip_working_data
GROUP BY
  member_casual;

---------------------------------------------------------------------

-- Number of trips by month for each rider type
WITH rider_type_and_month AS
(
SELECT 
  member_casual,
  started_at,
  CONCAT(MONTHNAME(started_at), ' ', YEAR(started_at)) AS month_and_year_of_trip
FROM 
  divvy_trip.divvy_trip_working_data
)
SELECT
  month_and_year_of_trip,
  SUM(
    CASE
      WHEN member_casual = 'Member' THEN 1
      ELSE 0
	END) AS Member,
    SUM(
      CASE
        WHEN member_casual = 'Casual' THEN 1
        ELSE 0
	  END) AS Casual  
FROM
  rider_type_and_month
GROUP BY
  month_and_year_of_trip
ORDER BY
  FIELD(month_and_year_of_trip, 'September 2021', 'October 2021', 'November 2021', 'December 2021', 'January 2022', 'February 2022', 'March 2022', 'April 2022', 'May 2022', 'June 2022', 'July 2022', 'August 2022');
  
---------------------------------------------------------------------

-- Number of trips by day of week for each rider type
WITH rider_type_and_day_of_week AS
(
SELECT 
  member_casual,
  DAYNAME(started_at) AS day_of_week
FROM 
  divvy_trip.divvy_trip_working_data
)
SELECT
  day_of_week,
  SUM(
      CASE 
        WHEN member_casual = 'Member' THEN 1
        ELSE 0
	END) AS Member,
  SUM(
    CASE
      WHEN member_casual = 'Casual' THEN 1
      ELSE 0
	END) AS Casual    
FROM
  rider_type_and_day_of_week
GROUP BY
  day_of_week
ORDER BY
  FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
  
---------------------------------------------------------------------

-- Number of trips by hour for each rider type
WITH rider_type_and_starting_hour AS
(
SELECT 
  member_casual,
  started_at,
  HOUR(started_at) AS trip_started_hour
FROM 
  divvy_trip.divvy_trip_working_data
)
SELECT
  trip_started_hour,
  SUM(
      CASE 
        WHEN member_casual = 'Member' THEN 1
        ELSE 0
	END) AS Member,
  SUM(
    CASE
      WHEN member_casual = 'Casual' THEN 1
      ELSE 0
	END) AS Casual    
FROM
  rider_type_and_starting_hour
GROUP BY
  trip_started_hour
ORDER BY
  trip_started_hour;
  
---------------------------------------------------------------------

-- Number of trips by rideable type for each rider type
SELECT
  rideable_type,
  SUM(
	CASE 
        WHEN member_casual = 'Member' THEN 1
        ELSE 0
	END) AS Member,
  SUM(
    CASE
      WHEN member_casual = 'Casual' THEN 1
      ELSE 0
	END) AS Casual
FROM
    divvy_trip.divvy_trip_working_data
GROUP BY
  rideable_type;
  
---------------------------------------------------------------------

-- Average trip duration by rider type
WITH rider_type_and_average_trip_duration AS
(
SELECT 
  member_casual,
  ROUND(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))/60, 2) AS trip_duration_in_minutes
FROM 
  divvy_trip.divvy_trip_working_data
)
SELECT
  member_casual,
  ROUND(AVG(trip_duration_in_minutes), 2) AS average_trip_duration
FROM
  rider_type_and_average_trip_duration
GROUP BY
  member_casual;
  
---------------------------------------------------------------------

-- Average trip duration of each rider type by month
WITH rider_type_month_and_average_trip_duration AS
(
SELECT 
  member_casual,
  started_at,
  CONCAT(MONTHNAME(started_at), ' ', YEAR(started_at)) AS month_and_year_of_trip,
  ROUND(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))/60, 2) AS trip_duration_in_minutes
FROM 
  divvy_trip.divvy_trip_working_data
)
SELECT
  month_and_year_of_trip,
  ROUND(
  AVG(
    CASE
      WHEN member_casual = 'Member' THEN trip_duration_in_minutes
	END)
  , 2) AS Member,
  ROUND(
    AVG(
      CASE
        WHEN member_casual = 'Casual' THEN trip_duration_in_minutes
	  END)
  , 2) AS Casual
FROM 
  rider_type_month_and_average_trip_duration
GROUP BY
  month_and_year_of_trip
ORDER BY
  FIELD(month_and_year_of_trip, 'September 2021', 'October 2021', 'November 2021', 'December 2021', 'January 2022', 'February 2022', 'March 2022', 'April 2022', 'May 2022', 'June 2022', 'July 2022', 'August 2022');  

---------------------------------------------------------------------

-- Average trip duration of each rider type by day of week
WITH rider_type_weekday_and_average_trip_duration AS
(
SELECT 
  member_casual,
  ROUND(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))/60, 2) AS trip_duration_in_minutes,
  DAYNAME(started_at) AS day_of_week
FROM 
  divvy_trip.divvy_trip_working_data
)
SELECT
  day_of_week,
  ROUND(
  AVG(
    CASE
      WHEN member_casual = 'Member' THEN trip_duration_in_minutes
	END)
  , 2) AS Member,
  ROUND(
    AVG(
      CASE
        WHEN member_casual = 'Casual' THEN trip_duration_in_minutes
	  END)
  , 2) AS Casual
FROM 
  rider_type_weekday_and_average_trip_duration
GROUP BY
  day_of_week
ORDER BY
  FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'); 
  
---------------------------------------------------------------------

-- Average trip duration of each rider type by starting hour
WITH rider_type_hour_and_average_trip_duration AS
(
SELECT 
  member_casual,
  started_at,
  HOUR(started_at) AS trip_started_hour,
  ROUND(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))/60, 2) AS trip_duration_in_minutes
FROM 
  divvy_trip.divvy_trip_working_data
)
SELECT
  trip_started_hour,
  ROUND(
  AVG(
    CASE
      WHEN member_casual = 'Member' THEN trip_duration_in_minutes
	END)
  , 2) AS Member,
  ROUND(
    AVG(
      CASE
        WHEN member_casual = 'Casual' THEN trip_duration_in_minutes
	  END)
  , 2) AS Casual
FROM 
  rider_type_hour_and_average_trip_duration
GROUP BY
  trip_started_hour
ORDER BY
  trip_started_hour; 
  
---------------------------------------------------------------------

-- Average trip duration by rideable type for each rider type
WITH rider_type_and_average_trip_duration AS
(
SELECT 
  member_casual,
  rideable_type,
  ROUND(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))/60, 2) AS trip_duration_in_minutes
FROM 
  divvy_trip.divvy_trip_working_data
)
SELECT
  rideable_type,
  ROUND(
  AVG(
    CASE
      WHEN member_casual = 'Member' THEN trip_duration_in_minutes
	END)
  , 2) AS Member,
  ROUND(
    AVG(
      CASE
        WHEN member_casual = 'Casual' THEN trip_duration_in_minutes
	  END)
  , 2) AS Casual
FROM
    rider_type_and_average_trip_duration
GROUP BY
  rideable_type;
  
---------------------------------------------------------------------

-- Top 20 start stations of casual riders
SELECT
  start_station_name,
  COUNT(*) AS total_casual_riders
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  member_casual = 'Casual'
GROUP BY
  start_station_name
ORDER BY
  COUNT(*) DESC
LIMIT 20;

---------------------------------------------------------------------

-- Top 20 start stations of annual members
SELECT
  start_station_name,
  COUNT(*) AS total_member_riders
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  member_casual = 'Member'
GROUP BY
  start_station_name
ORDER BY
  COUNT(*) DESC
LIMIT 20;

---------------------------------------------------------------------

-- Common start stations of both rider types
WITH top_start_stations_of_casual_riders AS
(
SELECT
  start_station_name,
  COUNT(*) AS total_casual_riders
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  member_casual = 'Casual'
GROUP BY
  start_station_name
ORDER BY
  COUNT(*) DESC
LIMIT 20
),
top_start_stations_of_annual_members AS
(
SELECT
  start_station_name,
  COUNT(*) AS total_member_riders
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  member_casual = 'Member'
GROUP BY
  start_station_name
ORDER BY
  COUNT(*) DESC
LIMIT 20
)
SELECT
  cr.start_station_name,
  cr.total_casual_riders,
  am.start_station_name,
  am.total_member_riders
FROM
  top_start_stations_of_casual_riders AS cr
INNER JOIN
  top_start_stations_of_annual_members AS am
ON
  cr.start_station_name = am.start_station_name;

---------------------------------------------------------------------

-- Top 20 end stations of casual riders
SELECT
  end_station_name,
  COUNT(*) AS total_casual_riders
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  member_casual = 'Casual'
GROUP BY
  end_station_name
ORDER BY
  COUNT(*) DESC
LIMIT 20;

---------------------------------------------------------------------

-- Top 20 end stations of annual members
SELECT
  end_station_name,
  COUNT(*) AS total_member_riders
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  member_casual = 'Member'
GROUP BY
  end_station_name
ORDER BY
  COUNT(*) DESC
LIMIT 20;

---------------------------------------------------------------------

-- Common end stations of both rider types
WITH top_end_stations_of_casual_riders AS
(
SELECT
  end_station_name,
  COUNT(*) AS total_casual_riders
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  member_casual = 'Casual'
GROUP BY
  end_station_name
ORDER BY
  COUNT(*) DESC
LIMIT 20
),
top_end_stations_of_annual_members AS
(
SELECT
  end_station_name,
  COUNT(*) AS total_member_riders
FROM
  divvy_trip.divvy_trip_working_data
WHERE
  member_casual = 'Member'
GROUP BY
  end_station_name
ORDER BY
  COUNT(*) DESC
LIMIT 20
)
SELECT
  cr.end_station_name,
  cr.total_casual_riders,
  am.end_station_name,
  am.total_member_riders
FROM
  top_end_stations_of_casual_riders AS cr
INNER JOIN
  top_end_stations_of_annual_members AS am
ON
  cr.end_station_name = am.end_station_name;

---------------------------------------------------------------------

-- Top 20 routes of casual riders
WITH rider_type_and_route AS
(
SELECT
  member_casual,
  start_station_name,
  end_station_name,
  CONCAT(start_station_name, ' - ', end_station_name) AS trip_route
FROM
  divvy_trip.divvy_trip_working_data
)
SELECT
  trip_route,
  COUNT(*) AS total_casual_riders
FROM
  rider_type_and_route
WHERE
  member_casual = 'Casual'
GROUP BY
  trip_route
ORDER BY
  COUNT(*) DESC
LIMIT 20;

---------------------------------------------------------------------

-- Top 20 routes of annual members 
WITH rider_type_and_route AS
(
SELECT
  member_casual,
  start_station_name,
  end_station_name,
  CONCAT(start_station_name, ' - ', end_station_name) AS trip_route
FROM
  divvy_trip.divvy_trip_working_data
)
SELECT
  trip_route,
  COUNT(*) AS total_member_riders
FROM
  rider_type_and_route
WHERE
  member_casual = 'Member'
GROUP BY
  trip_route
ORDER BY
  COUNT(*) DESC
LIMIT 20;

---------------------------------------------------------------------

-- Common routes of both rider types
WITH rider_type_and_route_casual_riders AS
(
SELECT
  member_casual,
  start_station_name,
  end_station_name,
  CONCAT(start_station_name, ' - ', end_station_name) AS trip_route
FROM
  divvy_trip.divvy_trip_working_data
),
top_routes_of_casual_riders AS
(
SELECT
  trip_route,
  COUNT(*) AS total_casual_riders
FROM
  rider_type_and_route_casual_riders
WHERE
  member_casual = 'Casual'
GROUP BY
  trip_route
ORDER BY
  COUNT(*) DESC
LIMIT 20
),
rider_type_and_route_annual_members AS
(
SELECT
  member_casual,
  start_station_name,
  end_station_name,
  CONCAT(start_station_name, ' - ', end_station_name) AS trip_route
FROM
  divvy_trip.divvy_trip_working_data
),
top_routes_of_annual_members AS
(
SELECT
  trip_route,
  COUNT(*) AS total_member_riders
FROM
  rider_type_and_route_annual_members
WHERE
  member_casual = 'Member'
GROUP BY
  trip_route
ORDER BY
  COUNT(*) DESC
LIMIT 20
)
SELECT
  cr.trip_route,
  cr.total_casual_riders,
  am.trip_route,
  am.total_member_riders
FROM
  top_routes_of_casual_riders AS cr
INNER JOIN
  top_routes_of_annual_members AS am
ON
  cr.trip_route = am.trip_route;

---------------------------------------------------------------------

-- Creating a table with necessary columns for visualization
DROP TABLE IF EXISTS divvy_trip.divvy_tripdata_cleaned;
CREATE TABLE divvy_trip.divvy_tripdata_cleaned AS
(
SELECT 
  ROW_NUMBER() OVER() AS index_no,
  rideable_type,
  started_at,
  ended_at,
  start_station_name,
  end_station_name,
  member_casual,
  ROUND(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))/60, 2) AS trip_duration_in_minutes,
  DAYNAME(started_at) AS day_of_week,
  CONCAT(MONTHNAME(started_at), ' ', YEAR(started_at)) AS month_and_year_of_trip,
  CONCAT(start_station_name, ' - ', end_station_name) AS trip_route
FROM 
  divvy_trip.divvy_trip_working_data
);

SELECT * FROM divvy_trip.divvy_tripdata_cleaned LIMIT 30;

---------------------------------------------------------------------
