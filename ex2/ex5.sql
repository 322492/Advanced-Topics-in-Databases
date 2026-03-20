CREATE FUNCTION municipality_parties(p_code text)
RETURNS TABLE(party_shortname text, votes bigint) AS $$
    BEGIN
        RETURN QUERY
        SELECT p.shortname, pv.votes
        FROM party_votes pv
        JOIN party p
            ON p.id = pv.party_id
        WHERE pv.municipality_code = p_code
        ORDER BY pv.votes DESC;
    END;
$$ LANGUAGE plpgsql;