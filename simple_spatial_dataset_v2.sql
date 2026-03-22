-- Enhanced toy spatial dataset for introductory PostGIS exercises
-- Coordinates are abstract planar units (not real geography).

CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS demo_point CASCADE;
DROP TABLE IF EXISTS demo_line CASCADE;
DROP TABLE IF EXISTS demo_polygon CASCADE;

CREATE TABLE demo_point (
  point_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text UNIQUE NOT NULL,
  geom geometry(Point) NOT NULL
);

CREATE TABLE demo_line (
  line_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text UNIQUE NOT NULL,
  geom geometry(LineString) NOT NULL
);

CREATE TABLE demo_polygon (
  polygon_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text UNIQUE NOT NULL,
  geom geometry(Polygon) NOT NULL
);

INSERT INTO demo_point(name, geom) VALUES
  ('library', ST_GeomFromText('POINT(2 2)')),
  ('station', ST_GeomFromText('POINT(7 2)')),
  ('school',  ST_GeomFromText('POINT(6 7)')),
  ('cafe',    ST_GeomFromText('POINT(11 3)')),
  ('museum',  ST_GeomFromText('POINT(3 8)')),
  ('square',  ST_GeomFromText('POINT(7.5 7.5)'));

INSERT INTO demo_line(name, geom) VALUES
  ('river_walk', ST_GeomFromText('LINESTRING(0.5 2, 4 2, 6 4, 8 6, 11 6)')),
  ('diagonal_road', ST_GeomFromText('LINESTRING(0.5 8.5, 3 6, 6 6, 10 4, 12.5 4)')),
  ('connector', ST_GeomFromText('LINESTRING(10 1.5, 11.5 2.5, 12.2 4.5)'));

INSERT INTO demo_polygon(name, geom) VALUES
  ('central_zone', ST_GeomFromText('POLYGON((1 1, 5 1, 5 5, 1 5, 1 1))')),
  ('north_park',   ST_GeomFromText('POLYGON((5 5, 9 5, 9 9, 5 9, 5 5))')),
  ('east_block',   ST_GeomFromText('POLYGON((9 1, 13 1, 13 5, 9 5, 9 1))')),
  ('concave_zone', ST_GeomFromText('POLYGON((14 1, 18 1, 18 2, 15 2, 15 5, 14 5, 14 1))')),
  ('corner_square', ST_GeomFromText('POLYGON((16.2 3, 17.8 3, 17.8 4.6, 16.2 4.6, 16.2 3))'));

CREATE INDEX demo_point_geom_gix ON demo_point USING GIST (geom);
CREATE INDEX demo_line_geom_gix ON demo_line USING GIST (geom);
CREATE INDEX demo_polygon_geom_gix ON demo_polygon USING GIST (geom);

-- Quick inspection queries
SELECT name, ST_AsText(geom) AS wkt
FROM demo_point
ORDER BY name;

SELECT name, ST_AsText(geom) AS wkt
FROM demo_line
ORDER BY name;

SELECT name, ST_AsText(geom) AS wkt
FROM demo_polygon
ORDER BY name;