-- 3a
SELECT t.month, t.day, t.hour, l.district, l.municipality, 
l.parish, l.stand_id, SUM(f.trip_count) AS total_trips FROM
fact_trips f
JOIN dim_time t ON f.time_id = t.time_id
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY CUBE (t.month, t.day, t.hour, l.district, l.municipality, l.parish, l.stand_id);

-- 3b
SELECT x.taxi_id, t.day, SUM(f.trip_count) AS total_trips FROM
fact_trips f
JOIN dim_time t ON f.time_id = t.time_id
JOIN dim_taxi x ON f.taxi_id = x.taxi_id
GROUP BY ROLLUP(x.taxi_id, t.day);

-- 3c
SELECT t.month, SUM(f.trip_count) AS total_trips FROM
fact_trips f
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY t.month;

-- 3d
SELECT l.district, l.municipality, x.taxi_id, SUM(f.trip_count) AS total_trips FROM
fact_trips f
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_taxi x ON f.taxi_id = x.taxi_id
GROUP BY CUBE(l.district, l.municipality, x.taxi_id);

-- 3e
SELECT l.district, l.municipality, l.parish, l.stand_id, SUM(f.trip_count) AS total_trips FROM
fact_trips f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY ROLLUP(l.district, l.municipality, l.parish, l.stand_id);

-- 3f
SELECT x.taxi_id, l.parish, t.hour, SUM(f.trip_count) AS total_trips FROM
fact_trips f
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_taxi x ON f.taxi_id = x.taxi_id
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY CUBE(x.taxi_id, l.parish, t.hour);