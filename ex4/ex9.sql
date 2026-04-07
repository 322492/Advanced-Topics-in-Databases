SELECT tracks.id AS track_id, taxi.id AS taxi_id
FROM taxi_stands taxi
JOIN tracks_braga tracks ON ST_DWithin(taxi.proj_location, tracks.proj_track, 200);