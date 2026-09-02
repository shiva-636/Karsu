# KARSU Setup — v0.3

## Backend

Requirements: Node.js 20+ and PostgreSQL 14+. For Docker, use a strong PostgreSQL password in the root `.env` file.

```bash
createdb karsu
psql -d karsu -f database/schema.sql
cd backend
npm install
cp .env.example .env
# Set DATABASE_URL/DB_* and a random AUTH_SECRET (32+ chars)
npm run typecheck
npm run build
npm run start:dev
```

API: `http://localhost:3000/api`
Health: `http://localhost:3000/api/health`

## Android emulator

```bash
flutter pub get
flutter run --dart-define=KARSU_API_URL=http://10.0.2.2:3000/api
```

## Physical Android device

```bash
flutter run --dart-define=KARSU_API_URL=http://YOUR_COMPUTER_IP:3000/api
```

## Security

- Never commit `.env` or production secrets.
- Use HTTPS in production.
- Keep PostgreSQL private and enable backups.
- Set a long random `AUTH_SECRET`.
- Configure `CORS_ORIGIN` to trusted application origins only.
- IV treats user context as private and includes an uncertainty disclaimer.

## Storage

KARSU v0.3 uses PostgreSQL for user accounts, business profiles, tasks, skills, tracking, surveys, experiments, finance, team data, roadmap data, notifications, privacy settings, IV history support, and user-scoped intelligence.

### v0.3.4 deployment notes

- A fresh PostgreSQL container initializes `database/schema.sql` automatically.
- Docker PostgreSQL credentials come from the root `.env`; never commit that file.
- The backend automatically bootstraps `database/schema.sql` when connected to a completely empty database, then applies pending migrations.
- Existing databases are upgraded automatically at backend startup; do not manually rerun migrations unless troubleshooting.
- The migration intentionally does **not** invent old passwords. Existing accounts with no recoverable password hash cannot log in until their password is reset through a verified administrative/user-reset flow.
- Authentication sessions are stored server-side and are revoked on logout.


### Automatic database migrations

KARSU v0.3.4 applies the base schema to an empty database and then applies SQL files in `database/migrations/` automatically at backend startup and records applied versions in `schema_migrations`. For an existing database, restart the backend after upgrading. Do not delete `schema_migrations` in a live installation.

### IV privacy

IV personalization is **opt-in**. When `ai_personalization_opt_in` is false, IV does not load the user's business/task/activity context, does not send personalized context to the AI provider, and stores no `context_snapshot` for that conversation.
