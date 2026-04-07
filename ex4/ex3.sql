WITH one AS (SELECT * FROM taxi_stands WHERE id = 1),
	two AS (SELECT * FROM taxi_stands WHERE id = 2)
SELECT 
    ST_Distance(one.proj_location, two.proj_location)
FROM one, two;

WITH one AS (SELECT * FROM taxi_stands WHERE id = 1),
	two AS (SELECT * FROM taxi_stands WHERE id = 2)
SELECT 
    ST_DistanceSphere(one.location, two.location)
FROM one, two;