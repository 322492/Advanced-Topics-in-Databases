CREATE FUNCTION check_nonnegative_party_votes()
RETURNS trigger AS $$
    BEGIN
        IF NEW.votes < 0 THEN
            RAISE EXCEPTION 'Votes cannot be negative';
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_nonnegative_party_votes
BEFORE INSERT OR UPDATE OF votes
ON party_votes
FOR EACH ROW
EXECUTE FUNCTION check_nonnegative_party_votes();
