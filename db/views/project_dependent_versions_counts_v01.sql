SELECT dependencies.project_id AS project_id, COUNT(DISTINCT versions.project_id) AS versions_count
FROM dependencies
INNER JOIN versions ON versions.id = dependencies.version_id
GROUP BY dependencies.project_id
