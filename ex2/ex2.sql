CREATE FUNCTION municipality_label(p_code text)
RETURNS text AS $$
DECLARE
    m_name text;
    m_code text;
BEGIN
    SELECT name, code
    INTO m_name, m_code
    FROM municipality
    WHERE code = p_code;
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    RETURN m_name || '(' || m_code || ')';
END;
$$ LANGUAGE plpgsql;