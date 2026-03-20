CREATE FUNCTION party_name_by_shortname(p_shortname text)
RETURNS text AS $$
DECLARE
    p_name text;
BEGIN
    SELECT name
    INTO p_name
    FROM party
    WHERE shortname = p_shortname;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Party shortname % does not exist', p_shortname;
    END IF;

    RETURN p_name;
END;
$$ LANGUAGE plpgsql;