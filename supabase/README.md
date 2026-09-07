# Supabase Database & Migrations

This directory contains the database schema migrations, seed data, Row-Level Security (RLS) policies, and pgTAP regression tests for Hotelyn.

---

## Architecture & Layout

```text
supabase/
├── config.toml           # Supabase CLI configuration
├── functions/            # Isolated Deno Edge Functions (webhooks only)
├── migrations/           # Versioned, sequential SQL schema migrations
├── seed.sql              # Deterministic seed data for local development & testing
└── tests/                # pgTAP database unit tests (RLS, schema integrity)
```

---

## Automated Staging Migration Deployment

Database migrations are deployed automatically to the staging Supabase project via GitHub Actions:

- **Workflow**: [`.github/workflows/deploy-staging-migrations.yml`](../.github/workflows/deploy-staging-migrations.yml)
- **Trigger**:
  - Automatically on any `push` to the `main` branch affecting `supabase/migrations/**` or `.github/workflows/deploy-staging-migrations.yml`.
  - Manually via `workflow_dispatch` in the GitHub Actions UI.
- **Concurrency**:
  - Uses the `staging-db-deployment` concurrency group with `cancel-in-progress: false`.
  - Database schema migrations are strictly sequential and must **never** be cancelled mid-execution to avoid partial state or corrupted migrations.
- **Execution Mechanism**:
  - Authenticates using `SUPABASE_ACCESS_TOKEN`.
  - Links to the staging project reference using `supabase link --project-ref <REF> --password <PASSWORD>`.
  - Pushes all pending migrations with `supabase db push --include-all --password <PASSWORD>`.
  - Upon migration failure, the step aborts immediately with a non-zero exit code and publishes actionable log excerpts to the GitHub Step Summary.

---

## Required Repository Secrets

To enable automated staging deployments, the following secrets must be configured in GitHub repository settings (**Settings > Secrets and variables > Actions**):

| Secret Name | Purpose | How to Obtain |
|---|---|---|
| `SUPABASE_ACCESS_TOKEN` | Supabase CLI API access token for automation | Generated in Supabase Dashboard: **Account > Access Tokens** |
| `SUPABASE_PROJECT_ID` | Reference identifier of the staging project | Visible in Supabase Dashboard: **Project Settings > General > Reference ID** |
| `SUPABASE_DB_PASSWORD` | Postgres database password for staging | Set when creating the staging project, or reset in **Project Settings > Database > Database password** |

---

## Safe Migration Guidelines

All migrations applied to staging and production must adhere to safe database evolution practices to guarantee zero-downtime deployments and data integrity:

### 1. Transactional DDL & Atomic Operations
- PostgreSQL wraps most DDL statements inside transactions automatically. If any statement in a migration fails, all changes within that migration are rolled back.
- **Exception**: Statements such as `CREATE INDEX CONCURRENTLY` cannot execute inside an explicit transaction block. When adding large indexes on populated tables in production, evaluate whether concurrent index creation is necessary or if standard index creation within the migration transaction is preferred.

### 2. Backwards Compatibility & Expand/Contract
- Migrations deploy before or alongside application code. Never introduce breaking schema changes in a single step.
- **Never add a `NOT NULL` column without a `DEFAULT`**:
  - Adding a `NOT NULL` column without a default to an existing table with rows will fail immediately and lock the table.
  - Always provide a sensible `DEFAULT` value or create the column as `NULL`able, backfill data, and only then add the `NOT NULL` constraint.
- **Do not drop or rename active columns/tables**:
  - Follow the **Expand / Contract** (parallel run) pattern:
    1. **Expand**: Add the new column/table alongside the old one.
    2. **Dual-write / Migrate**: Update application code to read from/write to both or the new structure.
    3. **Contract**: Remove the obsolete column/table in a subsequent migration once older application instances are fully deprecated.

### 3. Lock Timeouts & High-Availability
- Schema changes take locks on tables (e.g. `ALTER TABLE` requests `ACCESS EXCLUSIVE` lock).
- Set an explicit lock timeout when running high-impact alterations on production tables to prevent blocking concurrent transactions:
  ```sql
  SET LOCAL lock_timeout = '5s';
  ```

### 4. Rollback & Remediation Procedures
- **Forward-Fix Principle**: In Supabase and modern GitOps workflows, rolling back by deleting migration history or running downward scripts directly is discouraged. Instead, write and commit a new forward migration that reverses the problematic schema change (e.g. `YYYYMMDDHHMMSS_revert_<feature>.sql`).
- **Emergency Manual Rollback**:
  - If a migration partially applies or causes immediate regression, prepare an antidote SQL script.
  - Apply the antidote using the Supabase CLI or SQL editor:
    ```bash
    supabase db push --include-all
    ```
  - Verify that the `supabase_migrations.schema_migrations` table correctly reflects the active migration state.

---

## Local Development & Testing

Run migrations and database tests locally using the Supabase CLI:

```bash
# Start local Supabase containers (Docker required)
supabase start

# Apply all migrations and execute seed.sql from scratch
supabase db reset

# Create a new timestamped migration file
supabase migration new <migration_name>

# Execute pgTAP unit tests (tests/ directory)
supabase test db
```
