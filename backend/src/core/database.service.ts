import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Pool, PoolClient, QueryResultRow } from 'pg';

@Injectable()
export class DatabaseService implements OnModuleDestroy {
  readonly pool: Pool;
  constructor(config: ConfigService) {
    const connectionString = config.get<string>('DATABASE_URL');
    this.pool = new Pool({
      connectionString,
      host: config.get<string>('DB_HOST'),
      port: config.get<number>('DB_PORT') ?? 5432,
      database: config.get<string>('DB_NAME'),
      user: config.get<string>('DB_USER'),
      password: config.get<string>('DB_PASSWORD'),
      max: Number(config.get<string>('DB_POOL_MAX') ?? 10),
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 10000,
      ssl: config.get<string>('DB_SSL') === 'true' ? { rejectUnauthorized: false } : undefined,
    });
  }
  query<T extends QueryResultRow = any>(text: string, values: unknown[] = []) { return this.pool.query<T>(text, values); }
  async transaction<T>(fn: (client: PoolClient) => Promise<T>) {
    const client = await this.pool.connect();
    try { await client.query('BEGIN'); const result = await fn(client); await client.query('COMMIT'); return result; }
    catch (e) { await client.query('ROLLBACK'); throw e; }
    finally { client.release(); }
  }
  async onModuleDestroy() { await this.pool.end(); }
}
