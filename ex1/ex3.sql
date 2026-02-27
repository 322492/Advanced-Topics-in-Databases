SELECT
	d.id AS district_id,
	d.name AS district_name,
	m.code AS municipality_code,
	m.name AS municipality_name,
	m.mandates,
	RANK() OVER (PARTITION BY d.id ORDER BY m.mandates DESC),
	DENSE_RANK() OVER (PARTITION BY d.id ORDER BY m.mandates DESC)
FROM district d
JOIN municipality m
    ON m.district = d.id
ORDER BY d.id, m.mandates DESC, m.name ASC; 