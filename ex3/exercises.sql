-- ex1
SELECT name, ST_AsText(geom), ST_GeometryType(geom) FROM demo_point
UNION ALL
(SELECT name, ST_AsText(geom), ST_GeometryType(geom)  FROM demo_line)
UNION ALL
(SELECT name, ST_AsText(geom), ST_GeometryType(geom) FROM demo_polygon)
ORDER BY 3;

-- ex2
SELECT name, ST_X(geom), ST_Y(geom) FROM demo_point
ORDER BY name;

-- ex3
SELECT name, ST_Length(geom) FROM demo_line
ORDER BY 2 DESC; -- first row is the longest

-- ex4
SELECT name, ST_Area(geom), ST_Perimeter(geom) from demo_polygon
ORDER BY 2 DESC;

-- ex5
SELECT name, ST_NPoints(geom) AS points from demo_polygon
UNION ALL
SELECT name, ST_NumPoints(geom) AS points from demo_line

-- ex6
SELECT point.name, polygon.name FROM demo_point point
CROSS JOIN demo_polygon polygon
WHERE ST_Contains(polygon.geom, point.geom);

-- ex7
WITH
qContains AS (SELECT point.name, polygon.name FROM demo_point point
			CROSS JOIN demo_polygon polygon
			WHERE ST_Contains(polygon.geom, point.geom)),
qWithin AS 	(SELECT point.name, polygon.name FROM demo_point point
			CROSS JOIN demo_polygon polygon
			WHERE ST_Within(point.geom, polygon.geom))
SELECT NOT EXISTS (
  (SELECT * FROM qContains EXCEPT SELECT * FROM qWithin)
  UNION ALL
  (SELECT * FROM qWithin EXCEPT SELECT * FROM qContains)
) AS same_results;

-- ex8
SELECT
  l.name AS line_name,
  p.name AS polygon_name,
  CASE
    WHEN ST_Touches(l.geom, p.geom) THEN 'touch'
    ELSE 'intersect'
  END AS relation
FROM demo_line l
CROSS JOIN demo_polygon p
WHERE ST_Intersects(l.geom, p.geom);

-- ex9
SELECT p1.name, p2.name, ST_Touches(p1.geom, p2.geom) AS touch
FROM demo_polygon p1
JOIN demo_polygon p2 ON p1.name < p2.name
WHERE ST_Touches(p1.geom, p2.geom)
LIMIT 1;

SELECT p1.name, p2.name, ST_Disjoint(p1.geom, p2.geom) AS disjoint
FROM demo_polygon p1
JOIN demo_polygon p2 ON p1.name < p2.name
WHERE ST_Disjoint(p1.geom, p2.geom)
LIMIT 1;

-- ex10
WITH east_block AS (SELECT * FROM demo_polygon WHERE name = 'east_block')
SELECT p.name, ST_Distance(p.geom, east_block.geom) AS distance FROM demo_point p
CROSS JOIN east_block
ORDER BY distance ASC;

WITH station AS (SELECT * FROM demo_point WHERE name = 'station')
SELECT l.name, ST_Distance(l.geom, station.geom) AS distance FROM demo_line l
CROSS JOIN station
ORDER BY distance ASC;

-- ex11
SELECT name, ST_AsText(ST_Centroid(geom)) FROM demo_polygon;

-- ex12
INSERT INTO demo_point(name, geom) VALUES
('playground', ST_GeomFromText('POINT(10.5 3.5)'));

SELECT poly.name FROM demo_polygon poly
CROSS JOIN demo_point pt
WHERE ST_Within(pt.geom, poly.geom)
AND pt.name = 'playground';

SELECT pt.name, line.name, ST_Distance(pt.geom, line.geom) FROM demo_point pt
CROSS JOIN demo_line line
WHERE line.name = 'connector'
AND pt.name = 'playground';

-- ex13
SELECT ST_AsText(ST_ConvexHull(
    ST_Collect(
    		ARRAY(SELECT geom FROM demo_point)
            )) ), 
		ST_Area(ST_ConvexHull(
			    ST_Collect(
			    		ARRAY(SELECT geom FROM demo_point)
			            ))
			);

-- ex14
SELECT name, ST_AsText(ST_Envelope(geom)) from demo_polygon;
-- ST_Envelope returns a geometry representing the bounding box of a geometry.

-- ex15
SELECT name, ST_Area(geom) AS area, ST_Area(ST_Envelope(geom)) AS envelope_area, ST_Area(ST_Envelope(geom))-ST_Area(geom) AS empty_space 
FROM demo_polygon
WHERE name = 'concave_zone';

-- ex16
WITH concave_zone AS (SELECT * FROM demo_polygon WHERE name = 'concave_zone'),
	corner_square AS (SELECT * FROM demo_polygon WHERE name = 'corner_square')
SELECT concave_zone.geom&&corner_square.geom AS "&&", ST_Intersects(concave_zone.geom, corner_square.geom) AS st_intersect  FROM concave_zone
CROSS JOIN corner_square;
-- && returns TRUE if A's 2D bounding box intersects B's 2D bounding box.
-- ST_Intersects tests if two geometries intersect (they have at least one point in common)

-- ex17
SELECT p1.name, p2.name FROM demo_polygon p1
JOIN demo_polygon p2 ON p1.name < p2.name
WHERE p1.geom&&p2.geom;

SELECT p1.name, p2.name FROM demo_polygon p1
JOIN demo_polygon p2 ON p1.name < p2.name
WHERE ST_Intersects(p1.geom,p2.geom);

-- ex18
WITH central_zone AS (SELECT * FROM demo_polygon WHERE name = 'central_zone'),
	north_park AS (SELECT * FROM demo_polygon WHERE name = 'north_park')
SELECT ST_Relate(central_zone.geom, north_park.geom) FROM central_zone
CROSS JOIN north_park;

WITH central_zone AS (SELECT * FROM demo_polygon WHERE name = 'central_zone'),
	north_park AS (SELECT * FROM demo_polygon WHERE name = 'north_park')
SELECT ST_Touches(central_zone.geom, north_park.geom) FROM central_zone
CROSS JOIN north_park;

-- ex19
WITH concave_zone AS (SELECT * FROM demo_polygon WHERE name = 'concave_zone'),
	corner_square AS (SELECT * FROM demo_polygon WHERE name = 'corner_square')
SELECT ST_Relate(concave_zone.geom, corner_square.geom), ST_Disjoint(concave_zone.geom, corner_square.geom) FROM concave_zone
CROSS JOIN corner_square;

-- ex20
SELECT ST_RelateMatch('FF2FF1212', 'FF*FF****'); -- true, Disjoint pattern matches matrix from concave_zone and corner_square
SELECT ST_RelateMatch('FF2FF1212', 'T1FF1FFF1'); -- false, Equality pattern does not match matrix from concave_zone and corner_square

-- ex21
SELECT polygon.name, COUNT(point.geom) FROM demo_polygon polygon
LEFT JOIN demo_point point ON ST_Contains(polygon.geom, point.geom)
GROUP BY polygon.name
ORDER BY 2;

-- ex22
INSERT INTO demo_polygon(name, geom) VALUES
  ('south_strip', ST_GeomFromText('POLYGON((4 0, 10 0, 10 1, 4 1, 4 0))'));

SELECT p1.name, p2.name FROM demo_polygon p1
CROSS JOIN demo_polygon p2
WHERE p1.name = 'south_strip'
AND p2.name <> 'south_strip'
AND (ST_Intersects(p1.geom, p2.geom) OR ST_Touches(p1.geom, p2.geom));

-- ex23
SELECT name, ST_Area(geom) AS area, ST_Area(ST_Envelope(geom)) AS envelope_area, ST_Area(ST_Envelope(geom))-ST_Area(geom) AS empty_space 
FROM demo_polygon
WHERE name = 'south_strip';
-- envelope doesn't add empty space because polygon is rectangle
-- it could be fitted perfectly in minimum bounding rectangle (envelope)

-- ex24
-- indexes are already present
-- CREATE INDEX demo_point_geom_gix ON demo_point USING GIST (geom);
-- CREATE INDEX demo_line_geom_gix ON demo_line USING GIST (geom);
-- CREATE INDEX demo_polygon_geom_gix ON demo_polygon USING GIST (geom);
EXPLAIN
SELECT p1.name, p2.name FROM demo_polygon p1
JOIN demo_polygon p2 ON p1.name < p2.name
WHERE p1.geom&&p2.geom;
-- Nested Loop  (cost=0.00..2.55 rows=1 width=64)
-- 	Join Filter: ((p1.name < p2.name) AND (p1.geom && p2.geom))
--  ->  Seq Scan on demo_polygon p1  (cost=0.00..1.05 rows=5 width=64)
--  ->  Materialize  (cost=0.00..1.07 rows=5 width=64)
--    ->  Seq Scan on demo_polygon p2  (cost=0.00..1.05 rows=5 width=64)

EXPLAIN
SELECT p1.name, p2.name FROM demo_polygon p1
JOIN demo_polygon p2 ON p1.name < p2.name
WHERE ST_Intersects(p1.geom, p2.geom);
-- Nested Loop  (cost=0.13..72.35 rows=1 width=64)
--  ->  Seq Scan on demo_polygon p1  (cost=0.00..1.05 rows=5 width=64)
--  ->  Index Scan using demo_polygon_geom_gix on demo_polygon p2  (cost=0.13..14.25 rows=1 width=64)
--      Index Cond: (geom && p1.geom)
--      Filter: ((p1.name < name) AND st_intersects(p1.geom, geom))