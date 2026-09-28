---
name: sql-schema-design-best-practices
description: Stack-agnostic standard for designing and evolving relational database schemas. Load BEFORE writing or reviewing DDL, migration files, or index definitions (CREATE TABLE / ALTER TABLE / CREATE INDEX; Flyway, Liquibase, Alembic, Prisma, Knex, golang-migrate, Rails or Django migrations), and when picking types for money or timestamps, diagnosing a slow query with EXPLAIN, planning a zero-downtime schema change or a backfill, or designing multi-tenant row isolation. ORM-agnostic — applies equally to raw SQL and to Node, Go, Java, .NET, or Python backends.
---

# SQL Schema Design Best Practices

Default engine PostgreSQL; on another engine, see §1.
When this conflicts with an in-repo convention, follow the repo and say so.

## 1. Dialect Differences

On another engine, translate each PostgreSQL construct by intent and check these behaviours, which differ beyond spelling:

| Behaviour | PostgreSQL | Elsewhere |
|---|---|---|
| Nulls in `UNIQUE` | Distinct by default (fixes in §4) | Implementation-defined; check, never assume |
| Transactional DDL | A failed migration rolls back cleanly | MySQL largely lacks it: one statement per migration file, each re-runnable |
| Online DDL (`ADD CONSTRAINT ... NOT VALID` + `VALIDATE CONSTRAINT`, `CREATE INDEX CONCURRENTLY`) | Built in (§8) | Use the engine's own online-DDL path or an external tool; caveats differ |
| Expression indexes | Index the expression directly | MySQL 8.0.13+ indexes it directly with extra parentheses (`CREATE INDEX idx ON t ((lower(email)))`); SQL Server needs an indexed computed column |
| Clustered primary key | Heap table; the PK is just another unique index | InnoDB clusters on the PK, so a wide or random PK costs far more; re-examine the key choices in §3 |
| Row-level security | Built-in policies (§11) | Not universal; enforce isolation in one shared query layer |

## 2. Logical Modeling

- Model to 3NF before writing DDL: no list in a column (a child table, not CSV ids or a `jsonb` array of foreign keys), no numbered repeating columns (`phone_1`, `tag1..tag5`), no attribute bag (EAV) for a known shape, no hand-maintained derived value (use a generated column, a view, or compute on read).
- Polymorphic parent: one nullable FK per possible parent plus `CHECK (num_nonnulls(order_id, invoice_id) = 1)`, or one intersection table per parent type. Never `parent_id` + `parent_type` (cannot carry an FK).
- Fixed value set: a lookup table + FK, or `CHECK (col IN (...))`; never free text or a set that lives only in application code. Prefer the lookup table over an enum type when values need labels, ordering, or soft retirement (a new value is then a row, not a schema change).
- Denormalize only after a measured query problem, and record in the migration's description the query, the measurement, and which invariant application code now owns.
- Hierarchies: adjacency list when reading one level at a time or when a recursive CTE suffices. For arbitrary-depth subtree reads, moves, or deletes: default to a closure table; use a materialized path when subtree reads dominate and moves are rare (a move rewrites every descendant's path); use `ltree` only on PostgreSQL where the extension is permitted.
- Credentials: store salted password hashes only; never reversible storage or any path that returns the stored password (no "email me my password").

## 3. Keys and Identity

- Every table has a primary key, including join tables and event logs.
- Natural key only when immutable and narrow (ISO country or currency code); otherwise a surrogate, keeping a `UNIQUE` constraint on the natural key.
- Integer keys: `bigint GENERATED ALWAYS AS IDENTITY`; `BY DEFAULT` only where the application must supply ids (imports, replication). Never `serial`, never 32-bit.
- Identity does not enforce uniqueness: back it with `PRIMARY KEY` or `UNIQUE`.
- Opaque or client-generated keys: UUIDv7, never random UUIDv4 (`gen_random_uuid()`, `uuidv4()`) for a primary key or heavily-inserted index key. Server-side `uuidv7()` is PostgreSQL 18+: check `\df uuidv7` on the target; where absent, generate UUIDv7 in the application and keep the column `uuid` with no server default.
- Never renumber or reuse key values to close gaps.

## 4. Constraints

Every rule that must always hold is a database constraint; application validation is a convenience, because the application is never the only writer.

- `NOT NULL` by default; nullable only where absence has a documented meaning.
- `CHECK` passes when the expression is null: `CHECK (price > 0)` admits a null price. Write `CHECK (price IS NULL OR price > 0)` or make the column `NOT NULL`.
- `UNIQUE` on nullable columns admits unlimited nulls. Fix: make the columns `NOT NULL`; else `NULLS NOT DISTINCT` (PostgreSQL 15+); on older majors a unique expression index over `coalesce(col, <sentinel>)`.
- Uniqueness over a subset of rows: a unique partial index, never a read-then-write check in code.
- Must-not-overlap rules (bookings, price validity windows, employment spans): `EXCLUDE USING gist`, never an application overlap check. Equality on a scalar column needs `btree_gist` (core PostgreSQL has no GiST operator class for `integer`/`bigint`/`uuid`); confirm the managed platform permits it: `CREATE EXTENSION IF NOT EXISTS btree_gist; ALTER TABLE bookings ADD CONSTRAINT bookings_room_id_during_excl EXCLUDE USING gist (room_id WITH =, during WITH &&);` with `during tstzrange`.
- A `FOREIGN KEY` on every reference between tables, with the referential action written explicitly. The default `NO ACTION` is deferrable; `RESTRICT` is not and blocks even an update whose end state is valid. `CASCADE` only when the child is a component of the parent (order lines, not invoices); `SET NULL`/`SET DEFAULT` only for optional references.
- Index the referencing (child) columns of every FK; PostgreSQL does not create that index.
- Composite FKs: all referencing columns `NOT NULL`, or `MATCH FULL`; by default a row with any null referencing column escapes the constraint.
- Never a `CHECK` that reads other rows or tables, directly or through a function: it is not enforced consistently and breaks dump/restore. Use `UNIQUE`, `EXCLUDE`, or `FOREIGN KEY` for cross-row rules.

## 5. Data Types

| Need | Use | Never |
|---|---|---|
| Money, any exact quantity | `numeric(p,s)` with explicit scale, or `bigint` minor units, plus a currency column | `real`, `double precision`, PostgreSQL `money` |
| Point in time | `timestamptz` | `timestamp`, even "because we store UTC" (it silently discards input zone offsets) |
| Calendar date (birth date, invoice date) | `date` | a timestamp |
| Duration | `interval`; if an integer is unavoidable, the unit in the name (`timeout_seconds`) | a bare integer of unstated unit |
| Time of day | `time`, plus a separate date/zone if needed | `time with time zone`, `CURRENT_TIME` |
| Sub-second truncation | `date_trunc('second', ts)` | `timestamptz(0)`, which rounds and can store a future value |
| Text | `text`; a length limit only as a business rule, as `CHECK (length(col) <= n)` (relaxable online, §8) | `char(n)`; reflexive `varchar(n)` (narrowing it rewrites the table) |
| Case-insensitive unique text | `text` + `CREATE UNIQUE INDEX users_email_lower_key ON users (lower(email))`, queried as `lower(email) = lower($1)` | plain `UNIQUE (email)` and hoping callers normalize; `citext` as a reflex |
| Open-ended document | `jsonb` | `json`; `jsonb` to avoid designing |
| Boolean | `boolean NOT NULL` | a nullable three-state boolean (a real third state is a lookup value) |

- Collation: set it deliberately at database creation. A later change is breaking and requires rebuilding every affected index.
- `jsonb`: keep documents small (any update locks and rewrites the whole row) with a mostly fixed shape. Promote any field you filter, sort, join, or constrain on to a real column, or at least an expression index. GIN operator class: default `jsonb_ops` indexes keys and values; `jsonb_path_ops` is smaller and faster but supports only `@>`, `@?`, `@@`. `jsonb` rejects `\u0000` in strings and `NaN`/`Infinity` numbers.
- Timestamp ranges: `ts >= :start AND ts < :end`, never `BETWEEN` (a closed interval double-counts boundaries).

## 6. Indexing

- Every index serves a specific named query. Do not index every column in a `WHERE` clause; one well-ordered composite usually replaces several single-column indexes.
- Composite order by predicate shape, never by selectivity: equality (`=`, `IN`) columns first, then at most one range column, then only if justified `INCLUDE` payload. Keep to about 3 key columns.
- Never design around PostgreSQL 18 B-tree skip scan for a non-leading predicate; it helps only when the leading column has very few distinct values.
- Expression index: used only when the query contains the exact indexed expression (`lower(email)`, `(payload->>'sku')`); alternative: a stored generated column indexed normally.
- Partial index: the planner cannot prove a parameterized predicate implies the index predicate: an index `WHERE status = 'active'` will not serve `WHERE status = $1`.
- `INCLUDE`/covering index: only for one hot query on a slowly-changing table; on a frequently-updated table the index-only scan visits the heap anyway (all-visible bits unset) and the payload is pure bloat.
- Drop an index a new one makes redundant (a non-unique index on a leading prefix of another).
- Drop indexes with zero scans in production statistics, after confirming they enforce no constraint and do not serve a rare (for example monthly) job.
- Prefer an index over a cache: add the index, measure, then decide whether the cache is still needed.

## 7. Query Performance and EXPLAIN

- Validate every index or query change with `EXPLAIN (ANALYZE, BUFFERS)` on production-scale data and paste the real output in the PR. Plans do not extrapolate across data sizes: a small dev table legitimately sequential-scans.
- Estimated vs actual rows must agree within an order of magnitude at every node; a larger gap is a statistics or data-model problem an index will not fix.
- Multiply each node's time and rows by its `loops` before concluding anything.
- `EXPLAIN ANALYZE` executes the statement: wrap DML as `BEGIN; EXPLAIN (ANALYZE, BUFFERS) UPDATE ...; ROLLBACK;`.
- Always write `BUFFERS` explicitly (implicit with `ANALYZE` only on PostgreSQL 18+). Check timing overhead with `pg_test_timing` before trusting a microbenchmark.
- Never `NOT IN (subquery)` over a nullable expression: one null returns zero rows. Use `NOT EXISTS`.
- No `SELECT *` in production queries.

## 8. Migrations and Zero-Downtime Evolution

- Every schema change is a versioned migration file in the same commit as the code that needs it; no manual DDL in production.
- One logical change per migration; never combine an additive and a destructive change in one migration.
- Every migration ships a tested rollback path: a reverse migration CI executes, or for a genuinely irreversible step a written recovery plan in the PR (restore point, retained shadow column, replay procedure). "Restore a backup" is a plan only once someone has timed it.
- Evolve a live schema as expand / migrate / contract, three separately released phases:

| Phase | Schema | Application |
|---|---|---|
| Expand | Add the new column/table/constraint, nullable or with a non-volatile default. Remove nothing. | Write both old and new; read old. |
| Migrate | Backfill in batches (§9); add constraints `NOT VALID`, then validate. | Switch reads to new; verify under real traffic (last cheap revert point). |
| Contract | Drop the old structure. | Remove dual-write and compatibility code, only after the previous release is fully retired. |

- Never rename or drop a column, table, or constraint in the same release as the code change that stops using it.

PostgreSQL lock and rewrite rules. `ACCESS EXCLUSIVE`, the default DDL lock, blocks even plain `SELECT`, and lock waits are unbounded by default.

| Operation | Safe recipe | Naive failure |
|---|---|---|
| Every migration session | `SET lock_timeout = '3s'`; on `55P03` rerun the whole migration (the error aborts its transaction, so an in-transaction retry fails with `25P02`) | DDL queues behind one long query and every later `SELECT` queues behind the DDL: site outage |
| `statement_timeout` | Bound it for lock-taking, table-scanning DDL; raise it, or set `statement_timeout = 0` explicitly, for `CREATE INDEX CONCURRENTLY`, `VALIDATE CONSTRAINT`, `REINDEX ... CONCURRENTLY` | Unbounded, a scanning `ALTER` holds `ACCESS EXCLUSIVE` for hours; too tight, it kills a concurrent build and leaves an INVALID index. It bounds runtime, not lock waits, so it never replaces `lock_timeout` |
| `ADD COLUMN` | Nullable, or a non-volatile `DEFAULT` (metadata-only at any size) | A volatile default (`clock_timestamp()`), stored generated column, identity column, or constrained domain rewrites the table and its indexes under `ACCESS EXCLUSIVE` |
| Add `CHECK` or `FOREIGN KEY` to a populated table | `ADD CONSTRAINT ... NOT VALID`, then `VALIDATE CONSTRAINT` in a separate transaction (takes only `SHARE UPDATE EXCLUSIVE`) | Single-step `ADD CONSTRAINT` scans the table with writes blocked |
| `SET NOT NULL` | First a valid `CHECK (col IS NOT NULL)` (`NOT VALID`, then `VALIDATE`); `SET NOT NULL` then skips the scan | A bare `SET NOT NULL` scans under `ACCESS EXCLUSIVE` |
| Create an index | `CREATE INDEX CONCURRENTLY` outside any transaction: disable the runner's per-migration transaction (Rails `disable_ddl_transaction!`, Django `atomic = False`, an Alembic autocommit block, Flyway `executeInTransaction=false`). Same for `REINDEX ... CONCURRENTLY` and `DETACH PARTITION CONCURRENTLY`. Afterwards confirm the index is not INVALID; if it is, drop and retry or `REINDEX INDEX CONCURRENTLY` | Plain `CREATE INDEX` blocks writes for the whole build; inside a transaction block `CONCURRENTLY` errors immediately. A concurrent build waits for existing transactions, and a failed one leaves an INVALID index |
| Change a column type | A new column via expand / migrate / contract | Rewrites the table unless the types are binary coercible |
| Several scans or rewrites | Combine the subcommands into one `ALTER TABLE` | Repeated locks and passes. The strictest subcommand's lock applies to the whole statement, and rewriting forms are not MVCC-safe |
| `DROP COLUMN` | Expect space back only after a rewrite | The column is hidden; its storage is not reclaimed |

## 9. Backfills and Bulk Loads

- A backfill is a separate, restartable job, not a migration: batched on an indexed key (PK ranges or a keyset cursor), starting at 1,000-10,000 rows per batch and tuned from measured lock duration and WAL volume, one transaction per batch.
- Idempotent (re-running a batch is a no-op: `WHERE new_col IS NULL`), resumable (persisted cursor), throttled (pause between batches), with a progress log and a kill switch.
- `ANALYZE` the table afterwards, before judging any query's performance.
- Expect heap and index size to roughly double. Keep autovacuum running (it makes space reusable, not returned). Never `VACUUM FULL` or `CLUSTER` a live table (`ACCESS EXCLUSIVE` for the whole rewrite); use an online repack tool or expand / migrate / contract.
- Initial loads and large restores, in order: one transaction; `COPY`, not `INSERT`; create indexes after the data; drop and recreate foreign keys around the load (FK triggers over millions of rows can overflow the trigger event queue and fail the command); raise `maintenance_work_mem` and `max_wal_size`; then `ANALYZE`.

## 10. Soft Deletes and Audit Columns

- Prefer an explicit state column (`status`, or `archived_at` with a documented meaning) or an archive table over a generic soft delete.
- With `deleted_at timestamptz`: every unique index becomes partial `WHERE deleted_at IS NULL` (or a deleted record can never be re-created), and every read path filters it. Audit existing queries, including exports and authorization checks, in the same PR.
- Every table: `created_at timestamptz NOT NULL DEFAULT now()` and `updated_at timestamptz NOT NULL DEFAULT now()`, with `updated_at` maintained by a trigger, not application code.
- "Who changed what" needs an append-only history table or logical decoding, not mutable audit columns.

## 11. Multi-Tenancy and Row Isolation

- Shared-schema tenancy: `tenant_id NOT NULL` on every tenant-scoped table, as the leading column of its primary key, its tenant-scoped indexes, and its tenant-scoped unique constraints.
- Foreign keys are composite, `(tenant_id, parent_id)` referencing `(tenant_id, id)`; a single-column FK permits a reference to another tenant's parent.
- PostgreSQL row-level security is defense in depth, not the isolation mechanism:
  - RLS enabled with no policy is default-deny. Write both `USING` and `WITH CHECK`.
  - Permissive policies are OR-combined; the tenant boundary must be `RESTRICTIVE` or any permissive policy widens it.
  - Set `FORCE ROW LEVEL SECURITY` on every RLS table (owners otherwise bypass policies); superusers and `BYPASSRLS` roles always bypass, so the application never connects as one.
  - Referential-integrity checks bypass RLS, so a unique or FK violation can reveal a row the caller cannot see.
  - Set `row_security = off` in jobs that must never be silently filtered; filtering then raises an error.

## 12. Partitioning

- Partition only a very large table (rule of thumb: larger than the database server's physical memory).
- Choose the key from the columns that dominate `WHERE` clauses and from how old data is retired (drop, or `DETACH PARTITION CONCURRENTLY`, instead of bulk `DELETE`). Pruning uses partition bounds, not indexes.
- Check first: `PRIMARY KEY`, `UNIQUE`, and `EXCLUDE` on a partitioned table must include every partition key column. If a required uniqueness rule cannot, do not partition on that key.
- Keep the partition count modest (OLTP tolerates far fewer than a warehouse) and simulate the real workload first.
- Prefer hash over list when the number of distinct values will grow. Avoid sub-partitioning unless a single partition is itself too large.
- Never substitute a fan of non-overlapping partial indexes, or per-value cloned tables or columns (`orders_2026`, `orders_2027`), for partitioning.

## 13. Naming

All identifiers lower_snake_case, unquoted, starting with a letter, under 30 characters; no reserved keywords, and no trailing or doubled underscores (never `type_` or `user_` to dodge a keyword: pick another word).

| Object | Convention | Example |
|---|---|---|
| Table | Plural by default (singular only where the repo already uses it); never mix | `order_items` |
| Column | Singular, no table-name prefix | `email`, not `order_order_id` |
| Foreign key column | `<referenced entity>_id` | `customer_id` |
| Instant / calendar date | `_at` / `_date` | `cancelled_at`, `invoice_date` |
| Numeric roles | `_count`, `_total`, `_seq`, `_num`, `_size` | `retry_count`, `line_total` |
| Boolean | Positive predicate | `is_active`, `has_consent` |
| Primary key / unique / FK / check | `<table>_pkey`, `<table>_<columns>_key`, `<table>_<column>_fkey`, `<table>_<rule>_check` | `orders_pkey`, `users_email_key`, `orders_customer_id_fkey`, `orders_total_non_negative_check` |
| Index | `<table>_<columns>_idx`; `_key` when unique | `orders_tenant_id_created_at_idx` |

- Name every constraint and index explicitly (auto-generated names differ between environments, so a `DROP CONSTRAINT` by name breaks in some). The `pk_`/`uq_`/`fk_`/`ck_`/`ix_` prefix family is an acceptable alternative; one family per repository.
- No Hungarian prefixes (`tbl_`, `sp_`); no table named the same as one of its columns; always spell out `AS` for aliases.
- No table inheritance or rules: declarative partitioning and foreign keys instead of inheritance, triggers instead of rules.

## 14. Schema Gates

Migrations run in CI on every commit, with every developer and CI job on its own database instance. Record each gate's baseline on first run and gate on no regression; verify tool rule names and flags against the installed versions.

| Gate | How |
|---|---|
| Migrations reproduce the committed schema | Run all migrations on an empty database, `pg_dump --schema-only --no-owner --no-privileges`, diff against the checked-in schema; fail on any difference |
| Rollback works | Apply, reverse, re-apply; fail on any error or dump mismatch |
| Backward compatible during rollout | Run the previous release's test suite against the new schema |
| No migration can hang the database | Every migration file sets `lock_timeout` and states `statement_timeout` (a bound, or `0` with a one-line reason) |
| Rewrite detection | On a production-sized copy, compare `pg_relation_filenode('tbl')` before and after; a changed filenode means a full rewrite |
| Style and unsafe-DDL lint | sqlfluff for style and naming, squawk for unsafe Postgres DDL |

Before adding schema lint to review or CI, read `references/schema-gate-queries.sql` (tables without a PK, forbidden types, unindexed FK columns, never-used and INVALID indexes, unvalidated constraints, nullable-column ratio).

## 15. Agent Rules

1. Never edit an already-applied migration; add a new one.
2. Destructive DDL needs a sign-off note in the PR naming what is dropped, what reads it today, and how long the data has been unused. Ask; never assume the data is dead.
3. When proposing a multi-release change, say which expand / migrate / contract phase the current change is.
4. Never invent business rules: retention windows (including for any new PII column), allowed statuses, rounding and currency behaviour, tenancy boundaries, uniqueness rules. Ask.
5. State the engine and major version you assume.
