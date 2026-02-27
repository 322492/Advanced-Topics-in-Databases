SELECT
	d.id AS district_id,
	d.name AS district_name,
	m.code AS municipality_code,
	m.name AS municipality_name,
	m.mandates,
	SUM(mandates) OVER (PARTITION BY d.id) AS district_total_mandates,
	CAST(m.mandates AS DECIMAL) / SUM(mandates) OVER (PARTITION BY d.id) AS mandates_share
FROM district d
JOIN municipality m
    ON m.district = d.id