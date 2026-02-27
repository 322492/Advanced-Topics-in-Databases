WITH RECURSIVE
porto AS (
	SELECT m.code AS municipality_code, m.mandates::int AS mandates
	FROM municipality m
	WHERE m.name = 'PORTO'
	LIMIT 1
),
lists_raw AS (
	-- Parties
	SELECT
		'party'::text AS list_type,
		p.shortname,
		p.name,
		COALESCE(pv.votes, 0)::bigint AS votes
	FROM porto x
	JOIN party_votes pv
		ON pv.municipality_code = x.municipality_code
	JOIN party p
		ON p.id = pv.party_id

	UNION ALL

	-- Coalitions
	SELECT
		'coalition'::text AS list_type,
		c.shortname,
		c.name,
		COALESCE(c.votes, 0)::bigint AS votes
	FROM porto x
	JOIN coalition c
		ON c.municipality_code = x.municipality_code

	UNION ALL

	-- Independents
	SELECT
		'independent'::text AS list_type,
		i.shortname,
		i.name,
		COALESCE(i.votes, 0)::bigint AS votes
	FROM porto x
	JOIN independent i
		ON i.municipality_code = x.municipality_code
),
lists AS (
	SELECT
		lr.list_type,
		lr.shortname,
		lr.name,
		lr.votes,
		ROW_NUMBER() OVER (ORDER BY lr.list_type, lr.shortname) AS idx
	FROM lists_raw lr
),
seats(step, seats) AS (
	-- step 0: nobody has seats yet
	SELECT
		0 AS step,
		array_fill(0::int, ARRAY[(SELECT COUNT(*)::int FROM lists)]) AS seats

	UNION ALL

	-- allocate one seat per step to the list with the highest quotient
	SELECT
		s.step + 1,
		(
			COALESCE(s.seats[1:w.idx - 1], '{}'::int[])
			|| (s.seats[w.idx] + 1)
			|| COALESCE(s.seats[w.idx + 1:array_length(s.seats, 1)], '{}'::int[])
		) AS seats
	FROM seats s
	CROSS JOIN porto p
	JOIN LATERAL (
		SELECT l.idx
		FROM lists l
		ORDER BY
			(l.votes::numeric / (s.seats[l.idx] + 1)) DESC,
			l.votes DESC,
			l.shortname ASC,
			l.list_type ASC
		LIMIT 1
	) w ON TRUE
	WHERE s.step < p.mandates
),
final_state AS (
	SELECT s.seats
	FROM seats s
	CROSS JOIN porto p
	WHERE s.step = p.mandates
)
SELECT
	l.list_type,
	l.shortname,
	l.name,
	l.votes,
	fs.seats[l.idx] AS seats_won
FROM lists l
CROSS JOIN final_state fs
ORDER BY seats_won DESC, l.shortname ASC;
