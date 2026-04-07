SELECT 
    ST_Transform(geom, 4326)
FROM raa_cen_ori_freguesias
WHERE freguesia = 'Lajes do Pico';

SELECT '<?xml version="1.0" encoding="UTF-8"?>' ||
       '<kml xmlns="http://www.opengis.net/kml/2.2">' ||
       '<Document>' ||
       '<Placemark><name>' || freguesia || '</name>' ||
       ST_AsKML(ST_Transform(geom, 4326), 8) ||
       '</Placemark>' ||
       '</Document>' ||
       '</kml>'
FROM raa_cen_ori_freguesias
WHERE freguesia = 'Lajes do Pico';