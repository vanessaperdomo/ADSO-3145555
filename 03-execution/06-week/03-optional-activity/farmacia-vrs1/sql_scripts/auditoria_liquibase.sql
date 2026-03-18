-- Consultar el historial de versiones aplicadas por Liquibase
SELECT
    id,
    author,
    dateexecuted,
    description,
    md5sum
FROM databasechangelog
ORDER BY orderexecuted ASC;
