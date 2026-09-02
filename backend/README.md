# KARSU Backend

NestJS + PostgreSQL API for KARSU.

## Quick start

1. Create a PostgreSQL database named `karsu`.
2. Run `database/schema.sql` from the repository root.
3. Copy `.env.example` to `.env` and set a random `AUTH_SECRET` with 32+ characters.
4. Install and run:

```bash
npm install
npm run typecheck
npm run build
npm run start:dev
```

Health check: `GET /api/health`.

The API now persists users and user-owned application data in PostgreSQL. Passwords are salted with Node's `scrypt`; API sessions are signed and expire using `AUTH_TOKEN_TTL_SECONDS`.
