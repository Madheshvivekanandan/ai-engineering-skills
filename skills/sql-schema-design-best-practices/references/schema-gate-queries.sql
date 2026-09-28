-- Schema gate queries (see SKILL.md section 14).
-- Hand-written catalog constructions, not documented APIs: test each against your own
-- database and confirm the hits by hand before wiring it into CI.

-- Tables with no primary key
SELECT t.table_schema, t.table_name
FROM information_schema.tables t
WHERE t.table_type = 'BASE TABLE'
  AND t.table_schema NOT IN ('pg_catalog', 'information_schema')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints tc
    WHERE tc.table_schema = t.table_schema AND tc.table_name = t.table_name
      AND tc.constraint_type = 'PRIMARY KEY');

-- Forbidden data types
-- this excludes only the system schemas; replace with an inclusion list of your project's
-- schemas (e.g. table_schema IN ('app','billing')) so extension-owned tables do not show up
SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
  AND data_type IN ('real', 'double precision', 'money', 'character',
                    'timestamp without time zone', 'time with time zone');

-- Foreign keys whose leading child column is not indexed
-- (leading-column heuristic: expect false positives and negatives on composite keys.
--  A partial or INVALID index does not count as covering a foreign key, hence the
--  indpred/indisvalid tests: a partial index WHERE deleted_at IS NULL would otherwise
--  mask a genuinely unindexed FK.)
SELECT c.conrelid::regclass AS child_table, c.conname
FROM pg_constraint c
WHERE c.contype = 'f'
  AND NOT EXISTS (SELECT 1 FROM pg_index i
                  WHERE i.indrelid = c.conrelid AND i.indkey[0] = c.conkey[1]
                    AND i.indisvalid AND i.indpred IS NULL);

-- Never-used indexes, largest first
-- this also lists primary-key and unique-constraint indexes, which cannot be dropped
-- without dropping the constraint, and on an idle or freshly restored
-- database every index has zero scans -- read it against production statistics only
SELECT relname, indexrelname, idx_scan,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;

-- INVALID indexes left behind by a failed CREATE INDEX CONCURRENTLY
SELECT c.relname
FROM pg_index i JOIN pg_class c ON c.oid = i.indexrelid
WHERE NOT i.indisvalid;

-- NOT VALID constraints that were never validated
SELECT conrelid::regclass, conname, contype
FROM pg_constraint
WHERE NOT convalidated;

-- Nullable-column ratio per table: a rigor signal, not a verdict
-- this excludes only the system schemas; replace with an inclusion list of your project's
-- schemas (e.g. table_schema IN ('app','billing')) so extension-owned tables do not show up
SELECT table_schema, table_name,
       count(*) FILTER (WHERE is_nullable = 'YES') AS nullable,
       count(*) AS total
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
GROUP BY 1, 2 ORDER BY 3 DESC;
