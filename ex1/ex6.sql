SELECT
	d.id AS district_id,
	d.name AS district_name,
	m.code AS municipality_code,
	m.name AS municipality_name,
	m.mandates,
	SUM(mandates) OVER (PARTITION BY d.id) AS district_total_mandates,
	SUM(mandates) OVER (PARTITION BY d.id ORDER BY m.mandates DESC, m.name ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_mandates,
	CAST(SUM(mandates) OVER (PARTITION BY d.id ORDER BY m.mandates DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS DECIMAL) / SUM(mandates) OVER (PARTITION BY d.id) AS cumulative_share 
FROM district d
JOIN municipality m
    ON m.district = d.id
ORDER BY d.id, mandates DESC, m.name;