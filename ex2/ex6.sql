CREATE FUNCTION sum_votes_of_municipality(p_code text)
RETURNS bigint AS $$
    DECLARE
        r record;
        total bigint := 0;
    BEGIN
        FOR r IN
        SELECT votes
        FROM party_votes
        WHERE municipality_code = p_code
        LOOP
        total := total + COALESCE(r.votes, 0);
        END LOOP;
        RETURN total;
    END;
$$ LANGUAGE plpgsql;