import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { DatabaseService } from './database.service';
import { readdir, readFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { join, resolve } from 'node:path';

@Injectable()
export class MigrationService implements OnModuleInit {
  private readonly logger = new Logger(MigrationService.name);
  constructor(private readonly db: DatabaseService) {}

  async onModuleInit() {
    // Bootstrap a completely empty database before applying incremental migrations.
    // This makes first-run deployments work even when PostgreSQL has no base schema.
    await this.ensureBaseSchema();
    await this.db.query(`CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT now())`);
    const dir = this.findMigrationsDir();
    if (!dir) {
      this.logger.warn('Migration directory not found; skipping automatic migrations.');
      return;
    }
    const files = (await readdir(dir)).filter(f => /^\d+_.+\.sql$/.test(f)).sort();
    for (const file of files) {
      const version = file.split('_', 1)[0];
      const applied = await this.db.query(`SELECT 1 FROM schema_migrations WHERE version=$1`, [version]);
      if (applied.rowCount) continue;
      const sql = await readFile(join(dir, file), 'utf8');
      await this.db.transaction(async client => {
        await client.query(sql);
        await client.query(`INSERT INTO schema_migrations (version) VALUES ($1)`, [version]);
      });
      this.logger.log(`Applied migration ${file}`);
    }
  }

  private async ensureBaseSchema() {
    const result = await this.db.query(`
      SELECT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'users'
      ) AS exists
    `);
    if (result.rows[0]?.exists) return;

    const schemaPath = this.findBaseSchemaPath();
    if (!schemaPath) {
      throw new Error('KARSU base schema not found. Set KARSU_SCHEMA_FILE or place database/schema.sql in the repository.');
    }

    this.logger.log(`No KARSU base schema detected; bootstrapping ${schemaPath}`);
    const sql = await readFile(schemaPath, 'utf8');
    await this.db.query(sql);
  }

  private findBaseSchemaPath() {
    const candidates = [
      process.env.KARSU_SCHEMA_FILE,
      resolve(process.cwd(), 'database/schema.sql'),
      resolve(process.cwd(), '../database/schema.sql'),
      resolve(__dirname, '../../../database/schema.sql'),
    ].filter((x): x is string => Boolean(x));
    return candidates.find(existsSync);
  }

  private findMigrationsDir() {
    const candidates = [
      process.env.KARSU_MIGRATIONS_DIR,
      resolve(process.cwd(), 'database/migrations'),
      resolve(process.cwd(), '../database/migrations'),
      resolve(__dirname, '../../../database/migrations'),
    ].filter((x): x is string => Boolean(x));
    return candidates.find(existsSync);
  }
}
