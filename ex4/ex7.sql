SELECT distrito_ilha, ST_SimplifyPreserveTopology(ST_Union(geom), 250) AS geom
FROM cont_freguesias
GROUP BY distrito_ilha;