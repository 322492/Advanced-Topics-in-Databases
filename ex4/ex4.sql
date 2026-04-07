SELECT name, 
ST_Distance(proj_location, ST_Transform(ST_SetSRID(ST_MakePoint(-8.615, 41.141), 4326), 3763)) AS distance
FROM taxi_stands
ORDER BY distance
LIMIT 1;