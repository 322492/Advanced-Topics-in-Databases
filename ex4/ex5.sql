SELECT id, taxi, ST_Length(proj_track) AS total_length, ST_NPoints(proj_track) AS num_points
FROM tracks_braga
ORDER BY 1;