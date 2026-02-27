WITH lists AS(
	SELECT m.code, p.shortname, pv.votes, 'party' AS list_type
	FROM municipality m
	JOIN party_votes pv
		ON pv.municipality_code = m.code
	JOIN party p
		ON p.id = pv.party_id

	UNION ALL

	SELECT m.code, c.shortname, c.votes, 'coalition'
	FROM municipality m
	JOIN coalition c
		ON c.municipality_code = m.code

	UNION ALL

	SELECT m.code, i.shortname, i.votes, 'independent'
	FROM municipality m
	JOIN independent i
		ON i.municipality_code = m.code
)
SELECT
	d.id AS district_id,
	d.name AS district_name,
	SUM(votes) FILTER (WHERE list_type = 'party') AS party_votes,
	SUM(votes) FILTER (WHERE list_type = 'coalition') AS coalition_votes,
	SUM(votes) FILTER (WHERE list_type = 'independent') AS independent_votes,
	SUM(votes) AS total_votes
FROM district d
JOIN municipality m
    ON m.district = d.id
JOIN lists l
	ON l.code = m.code
GROUP BY d.id, d.name
ORDER BY d.id, d.name