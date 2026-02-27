SELECT 
    d.id, 
    d.name, 
	COUNT(*) AS total_municipalities,
    COUNT(*) FILTER (WHERE m.mandates > 10) as municipalities_with_over_10_mandates
FROM district d
JOIN municipality m
    ON m.district = d.id
GROUP BY d.id, d.name
ORDER BY d.id;
