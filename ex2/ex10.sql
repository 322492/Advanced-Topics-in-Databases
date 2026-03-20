CREATE VIEW municipality_step_order AS
    SELECT code, name, valid_votes + blank_votes + null_votes AS total_ballots,
        row_number() OVER (
                ORDER BY valid_votes, code
        ) AS step_no
FROM municipality;

CREATE TABLE parliament_control(
    id boolean PRIMARY KEY DEFAULT TRUE,
    step_n integer NOT NULL
);

CREATE TABLE national_party_votes(
    party_id bigint PRIMARY KEY
    REFERENCES party(id),
    votes bigint NOT NULL
);

CREATE TABLE national_deputies(
    party_id bigint PRIMARY KEY
    REFERENCES party(id),
    deputies bigint NOT NULL
);

CREATE FUNCTION refresh_virtual_parliament()
RETURNS void AS $$
DECLARE
    p_step integer := (SELECT step_n FROM parliament_control);
BEGIN
    -- 1. Accumulated national votes for first p_step municipalities
    DELETE FROM national_party_votes;
    INSERT INTO national_party_votes(party_id, votes)
    SELECT pv.party_id, SUM(pv.votes)
    FROM party_votes pv
    JOIN municipality_step_order mso ON mso.code = pv.municipality_code
    WHERE mso.step_no <= p_step
    GROUP BY pv.party_id;

    -- 2. D'Hondt seat allocation
    DELETE FROM national_deputies;
    WITH RECURSIVE
    divisors AS (
        SELECT 1 AS divisor
        UNION ALL
        SELECT divisor + 1
        FROM divisors
        WHERE divisor < 230
    ),
    quotients AS (
        SELECT npv.party_id,
        npv.votes::numeric / d.divisor AS quotient
        FROM national_party_votes npv
        CROSS JOIN divisors d
    ),
    top_230 AS (
        SELECT party_id
        FROM quotients
        ORDER BY quotient DESC, party_id
        LIMIT 230
    )
    INSERT INTO national_deputies(party_id, deputies)
    SELECT party_id, COUNT(*)
    FROM top_230
    GROUP BY party_id;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION trg_refresh_virtual_parliament()
RETURNS trigger AS $$
BEGIN
    PERFORM refresh_virtual_parliament();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_virtual_parliament_refresh
AFTER INSERT OR UPDATE OF step_n
ON parliament_control
FOR EACH ROW
EXECUTE FUNCTION trg_refresh_virtual_parliament();