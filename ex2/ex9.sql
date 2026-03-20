CREATE TABLE party_votes_log(
municipality_code text NOT NULL,
party_id bigint NOT NULL,
old_votes bigint,
new_votes bigint,
changed_at timestamp NOT NULL DEFAULT now()
);

CREATE FUNCTION audit_party_votes()
RETURNS trigger AS $$
    BEGIN
    IF NEW.votes != OLD.votes THEN
        INSERT INTO party_votes_log(
            municipality_code,
            party_id,
            old_votes,
            new_votes
        )
        VALUES(
            NEW.municipality_code,
            NEW.party_id,
            OLD.votes,
            NEW.votes
        );
    END IF;
    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_party_votes
AFTER UPDATE OF votes
ON party_votes
FOR EACH ROW
EXECUTE FUNCTION audit_party_votes();