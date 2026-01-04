/* =========================================================
   Cyclistic Bike Share Analysis
   Author:Brian Munene
   Tools:SQL
   PURPOSE: Data Cleaning, Transformation & Analysis
   ========================================================= */


/* =========================
   STEP 1: CREATE MASTER TABLE
   ========================= */

SELECT 'trips_2021_01' AS table_name, COUNT(*) AS row_count FROM trips_2021_01
UNION ALL
SELECT 'trips_2021_02', COUNT(*) FROM trips_2021_02
UNION ALL
SELECT 'trips_2021_03', COUNT(*) FROM trips_2021_03
UNION ALL
SELECT 'trips_2021_04', COUNT(*) FROM trips_2021_04
UNION ALL
SELECT 'trips_2021_05', COUNT(*) FROM trips_2021_05
UNION ALL
SELECT 'trips_2021_06', COUNT(*) FROM trips_2021_06
UNION ALL
SELECT 'trips_2021_07', COUNT(*) FROM trips_2021_07
UNION ALL
SELECT 'trips_2021_08', COUNT(*) FROM trips_2021_08
UNION ALL
SELECT 'trips_2021_09', COUNT(*) FROM trips_2021_09
UNION ALL
SELECT 'trips_2021_10', COUNT(*) FROM trips_2021_10
UNION ALL
SELECT 'trips_2021_11', COUNT(*) FROM trips_2021_11
UNION ALL
SELECT 'trips_2021_12', COUNT(*) FROM trips_2021_12;


/* =========================
   STEP 2: CHECK TOTAL ROWS
   ========================= */

SELECT COUNT(*)
FROM MASTER_TRIPS_2021;


/* =========================
   STEP 3: CREATE CLEAN MASTER TABLE
   ========================= */

CREATE TABLE master_clean AS
SELECT
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    end_station_name,
    member_casual
FROM master_trips_2021;


ALTER TABLE master_clean
RENAME TO trips_2021_master;


/* =========================
   STEP 4: CHECK FOR NULLS
   ========================= */

SELECT
    SUM(CASE WHEN ride_id IS NULL THEN 1 ELSE 0 END) AS ride_id_nulls,
    SUM(CASE WHEN rideable_type IS NULL THEN 1 ELSE 0 END) AS rideable_type_nulls,
    SUM(CASE WHEN started_at IS NULL THEN 1 ELSE 0 END) AS started_at_nulls,
    SUM(CASE WHEN ended_at IS NULL THEN 1 ELSE 0 END) AS ended_at_nulls,
    SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS start_station_name_nulls,
    SUM(CASE WHEN end_station_name IS NULL THEN 1 ELSE 0 END) AS end_station_name_nulls,
    SUM(CASE WHEN member_casual IS NULL THEN 1 ELSE 0 END) AS member_casual_nulls
FROM trips_2021_master;


/* =========================
   STEP 5: REMOVE NULLS
   ========================= */

UPDATE trips_2021_master
SET start_station_name = 'Unknown'
WHERE start_station_name IS NULL;

UPDATE trips_2021_master
SET end_station_name = 'Unknown'
WHERE end_station_name IS NULL;


/* =========================
   STEP 6: CONVERT TO DATETIME
   ========================= */

UPDATE trips_2021_master
SET
    started_at = datetime(started_at),
    ended_at   = datetime(ended_at);


/* =========================
   STEP 7: CREATE RIDE LENGTH
   ========================= */

ALTER TABLE trips_2021_master
ADD COLUMN ride_length INTEGER;

UPDATE trips_2021_master
SET ride_length =
    strftime('%s', ended_at) - strftime('%s', started_at);

DELETE FROM trips_2021_master
WHERE ride_length <= 0;


/* =========================
   STEP 8: ADD DATE COLUMNS
   ========================= */

ALTER TABLE trips_2021_master ADD COLUMN ride_date TEXT;
ALTER TABLE trips_2021_master ADD COLUMN ride_month TEXT;
ALTER TABLE trips_2021_master ADD COLUMN ride_day TEXT;
ALTER TABLE trips_2021_master ADD COLUMN ride_year TEXT;
ALTER TABLE trips_2021_master ADD COLUMN day_of_week TEXT;

UPDATE trips_2021_master
SET
    ride_date = date(started_at),
    ride_month = strftime('%m', started_at),
    ride_day = strftime('%d', started_at),
    ride_year = strftime('%Y', started_at),
    day_of_week = strftime('%w', started_at);


/* =========================
   STEP 9: REMOVE EXTREME OUTLIERS
   ========================= */

DELETE FROM trips_2021_master
WHERE ride_length > 720 * 60;


/* =========================
   STEP 10: ANALYSIS
   ========================= */

--------------------------------
--Total Number of Trips
--------------------------------
SELECT COUNT(*) AS trips
FROM trips_2021_master;

--------------------------------
--Rides By User Type
--------------------------------
SELECT member_casual, COUNT(*) AS trips
FROM trips_2021_master
GROUP BY member_casual;

--------------------------------
--Average Ride Length By User Type
--------------------------------
SELECT member_casual,
       AVG(ride_length) / 60 AS avg_ride_minutes
FROM trips_2021_master
GROUP BY member_casual;

--------------------------------
--Total Trips By Day Of Week For Members vs Casual Riders
--------------------------------
SELECT
    day_of_week,
    member_casual,
    COUNT(*) AS trips
FROM trips_2021_master
GROUP BY day_of_week, member_casual
ORDER BY day_of_week;

--------------------------------
--Total Trips By Month For Members vs Casual Riders
--------------------------------
SELECT
    ride_month,
    member_casual,
    COUNT(*) AS trips
FROM trips_2021_master
GROUP BY ride_month, member_casual
ORDER BY ride_month;

--------------------------------
--Average Ride Length By Day Of Week And User Type
--------------------------------
SELECT
    day_of_week,
    member_casual,
    AVG(ride_length) AS avg_ride_length
FROM trips_2021_master
GROUP BY day_of_week, member_casual
ORDER BY day_of_week;

--------------------------------
--Average Ride Length By User Type
--------------------------------
SELECT
    member_casual,
    AVG(ride_length) AS avg_ride_length
FROM trips_2021_master
GROUP BY member_casual;

--------------------------------
--Total Trips For Members vs Casual Riders
--------------------------------
SELECT
    member_casual,
    COUNT(*) AS total_trips
FROM trips_2021_master
GROUP BY member_casual;

--------------------------------
--Total Trips For Members vs Casual Riders By Bike type
--------------------------------
SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS total_rides
FROM trips_2021_master
GROUP BY member_casual, rideable_type;

---------------------------------
--Total Rides By Hour Of Day For Members vs Casual Riders
---------------------------------
SELECT
    member_casual,
    strftime('%H', started_at) AS hour_of_day,
    COUNT(*) AS total_rides
FROM trips_2021_master
GROUP BY member_casual, hour_of_day
ORDER BY hour_of_day;
