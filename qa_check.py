from pathlib import Path
import re, zipfile, sys
root=Path(__file__).resolve().parent
schema=(root/'database/schema.sql').read_text()
record=(root/'backend/src/core/record-store.service.ts').read_text()
auth=(root/'backend/src/auth/auth.service.ts').read_text()
app=(root/'backend/src/app.module.ts').read_text()
main=(root/'backend/src/main.ts').read_text()
mobile=(root/'mobile/lib/core/state/app_state.dart').read_text()
onboard=(root/'mobile/lib/features/onboarding/screens/onboarding_step1_screen.dart').read_text()
checks={
'users password_hash': 'password_hash' in schema,
'postgres database service': (root/'backend/src/core/database.service.ts').exists() and 'Pool' in (root/'backend/src/core/database.service.ts').read_text(),
'record store has postgres': "DatabaseService" in record and "INSERT INTO" in record,
'auth uses database': 'await this.users.findByEmail' in auth,
'expiring signed sessions': 'exp' in auth and 'timingSafeEqual' in auth,
'global config': 'ConfigModule.forRoot' in app,
'health endpoint': (root/'backend/src/health.controller.ts').exists(),
'cors enabled': 'enableCors' in main,
'password included on register': "'password':password" in mobile or "'password': password" in mobile,
'persisted token': 'SharedPreferences' in mobile and "setString('token'" in mobile,
'onboarding posts business profile': "'/businesses'" in onboard and 'businessType' in onboard,
'no old in-memory store': 'new Map' not in record,
'auth sessions table': 'CREATE TABLE auth_sessions' in (root/'database/schema.sql').read_text(),
'logout revokes sessions': 'revokeToken' in auth and 'revoked_at' in auth,
'safe legacy migration': "MIGRATION_REQUIRED" not in (root/'database/migrations/001_v03.sql').read_text(),
'docker initializes schema': './database/schema.sql:/docker-entrypoint-initdb.d/001-schema.sql:ro' in (root/'docker-compose.yml').read_text(),
'onboarding routing guard': "onboardingComplete" in (root/'mobile/lib/core/routing/app_router.dart').read_text(),
'AI respects privacy opt-out': 'ai_personalization_opt_in' in (root/'backend/src/iv/iv.service.ts').read_text() and 'personalized' in (root/'backend/src/iv/iv.service.ts').read_text() and 'context_snapshot' in (root/'backend/src/iv/iv.service.ts').read_text(),
'privacy default is opt-in': 'ai_personalization_opt_in BOOLEAN NOT NULL DEFAULT FALSE' in schema,
'auto migration runner': (root/'backend/src/core/migration.service.ts').exists() and 'schema_migrations' in (root/'backend/src/core/migration.service.ts').read_text(),
'privacy hardening migration': (root/'database/migrations/002_privacy_and_migration_hardening.sql').exists() and 'SET DEFAULT FALSE' in (root/'database/migrations/002_privacy_and_migration_hardening.sql').read_text(),
'backend version 0.3.4': '0.3.4' in (root/'backend/package.json').read_text(),
'mobile version 0.3.4': 'version: 0.3.4' in (root/'mobile/pubspec.yaml').read_text(),
'docker password not hard-coded': 'POSTGRES_PASSWORD: karsu' not in (root/'docker-compose.yml').read_text(),
'docker password required from env': 'POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?' in (root/'docker-compose.yml').read_text(),
'empty-db schema bootstrap': 'ensureBaseSchema' in (root/'backend/src/core/migration.service.ts').read_text() and 'information_schema.tables' in (root/'backend/src/core/migration.service.ts').read_text(),
'root env example exists': (root/'.env.example').exists() and 'POSTGRES_PASSWORD=' in (root/'.env.example').read_text(),
}
failed=[k for k,v in checks.items() if not v]
for k,v in checks.items(): print(('PASS' if v else 'FAIL'),k)
print(f'RESULT: {len(checks)-len(failed)}/{len(checks)} static checks passed')
if failed: sys.exit(1)
