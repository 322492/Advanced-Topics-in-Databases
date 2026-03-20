CREATE FUNCTION municipality_size_class(p_code text)
RETURNS text AS $$
DECLARE
    m_mandates bigint;
BEGIN
    SELECT mandates
    INTO m_mandates
    FROM municipality
    WHERE code = p_code;
    
    IF m_mandates < 5 THEN
        RETURN 'small';
    ELSIF m_mandates < 10 THEN
        RETURN 'medium';
    ELSE
        RETURN 'large';
    END IF;
END;
$$ LANGUAGE plpgsql;