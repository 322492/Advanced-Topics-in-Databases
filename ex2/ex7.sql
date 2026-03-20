CREATE FUNCTION check_party_votes_nonnegative(p_code text, p_party_id bigint)
RETURNS boolean AS $$
DECLARE
    pv_votes bigint;
BEGIN
    SELECT votes
    INTO pv_votes
    FROM party_votes
    WHERE municipality_code = p_code
    AND party_id = p_party_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Error! Party not found. p_code = %, p-party_id = %', p_code, p_party_id;
    END IF;

    RETURN pv_votes >= 0;
END;
$$ LANGUAGE plpgsql;