WITH municipalities AS (
    SELECT municipio, ST_Union(geom) AS geom
    FROM cont_freguesias
    GROUP BY municipio
)
SELECT
    mo.municipio AS origin_municipio,
    md.municipio AS destination_municipio,
    COUNT(*) AS trip_count
FROM tracks_braga t
JOIN municipalities mo
    ON ST_Covers(mo.geom, ST_StartPoint(t.proj_track))
JOIN municipalities md
    ON ST_Covers(md.geom, ST_EndPoint(t.proj_track))
GROUP BY mo.municipio, md.municipio;
