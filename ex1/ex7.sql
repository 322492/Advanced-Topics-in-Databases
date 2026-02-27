SELECT
	c.municipality_code,
	c.shortname,
	c.name,
	string_agg(p.shortname, '.' ORDER BY cm.order_number) AS members_shortnames,
	c.shortname = string_agg(p.shortname, '.' ORDER BY cm.order_number) AS matches_shortname
FROM coalition c
JOIN coalition_member cm
	ON c.shortname = cm.coalition_shortname
	AND c.municipality_code = cm.municipality_code
JOIN party p
	ON cm.party_id = p.id
GROUP BY c.municipality_code, c.shortname, c.name
ORDER BY c.municipality_code, c.shortname;