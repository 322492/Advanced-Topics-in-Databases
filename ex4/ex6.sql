SELECT 
    geom, 
    ST_SimplifyPreserveTopology(geom, 50), 
    ST_SimplifyPreserveTopology(geom, 100), 
    ST_SimplifyPreserveTopology(geom, 250)
FROM raa_cen_ori_freguesias
WHERE freguesia = 'Lajes do Pico';