CREATE OR REPLACE FUNCTION track_speed_profile(p_track_id integer)
RETURNS TABLE
(
    seq        integer,
    segment_m  double precision,
    speed_kmh  double precision
)
LANGUAGE plpgsql
AS $$
DECLARE
    g      geometry(LineString, 3763);
    n      integer;
    i      integer;
    p_prev geometry(Point, 3763);
    p_curr geometry(Point, 3763);
    d      double precision;
BEGIN
    SELECT proj_track
    INTO g
    FROM tracks_braga
    WHERE id = p_track_id;
    IF g IS NULL THEN
        RAISE EXCEPTION 'Track % not found, or proj_track is NULL', p_track_id;
    END IF;
    n := ST_NPoints(g);
    IF n < 2 THEN
        RETURN;
    END IF;
    FOR i IN 2..n LOOP
        p_prev := ST_PointN(g, i - 1);
        p_curr := ST_PointN(g, i);
        d := ST_Distance(p_prev, p_curr);
        seq := i - 1;
        segment_m := d;
        speed_kmh := d * 3.6;
        RETURN NEXT;
    END LOOP;
    RETURN;
END;
$$;