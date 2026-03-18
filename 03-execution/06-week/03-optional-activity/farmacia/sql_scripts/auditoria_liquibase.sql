-- ============================================================
--  auditoria_liquibase.sql
--  Consultas para auditar el estado de las migraciones
--  aplicadas por Liquibase (tabla databasechangelog).
-- ============================================================


-- 1. Historial completo de changesets ejecutados
SELECT
    id                                      AS "ID Changeset",
    author                                  AS "Autor",
    filename                                AS "Archivo",
    dateexecuted                            AS "Ejecutado el",
    orderexecuted                           AS "Orden",
    exectype                                AS "Tipo",
    description                             AS "Descripción",
    LEFT(md5sum, 12) || '...'               AS "MD5 (abrev.)"
FROM databasechangelog
ORDER BY orderexecuted ASC;


-- 2. Resumen: total de changesets por autor
SELECT
    author                  AS "Autor",
    COUNT(*)                AS "Total Changesets",
    MIN(dateexecuted)       AS "Primera Migración",
    MAX(dateexecuted)       AS "Última Migración"
FROM databasechangelog
GROUP BY author
ORDER BY "Total Changesets" DESC;


-- 3. Changesets ejecutados en las últimas 24 horas
SELECT
    id,
    author,
    filename,
    dateexecuted,
    description
FROM databasechangelog
WHERE dateexecuted >= NOW() - INTERVAL '24 hours'
ORDER BY dateexecuted DESC;


-- 4. Locks activos de Liquibase (útil para diagnóstico de cuelgues)
SELECT
    id,
    locked,
    lockgranted,
    lockedby
FROM databasechangeloglock;


-- 5. Changesets fallidos (exectype = 'FAILED')
SELECT
    id,
    author,
    filename,
    dateexecuted,
    exectype,
    description
FROM databasechangelog
WHERE exectype = 'FAILED'
ORDER BY dateexecuted DESC;
