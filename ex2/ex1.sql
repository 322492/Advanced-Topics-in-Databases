CREATE FUNCTION municipality_mandates(p_code text) 
RETURNS bigint AS $$
DECLARE
    v_mandates bigint;
BEGIN
    SELECT mandates
    INTO v_mandates
    FROM municipality
    WHERE code = p_code;

    RETURN v_mandates;
END;
$$ LANGUAGE plpgsql;