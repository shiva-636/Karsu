import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../core/database.service';

type UserRecord = { id: string; name: string; email: string; country?: string; preferredLanguage?: string; passwordHash: string; createdAt: string; updatedAt: string; profile?: Record<string, unknown> };

@Injectable()
export class UsersService {
  constructor(private readonly db: DatabaseService) {}
  async createAccount(input: { name: string; email: string; passwordHash: string; country?: string; preferredLanguage?: string }) {
    const r = await this.db.query(`INSERT INTO users (name,email,password_hash,country,preferred_language) VALUES ($1,$2,$3,$4,$5) RETURNING *`, [input.name.trim(), input.email.trim().toLowerCase(), input.passwordHash, input.country ?? null, input.preferredLanguage ?? null]);
    await this.db.query(`INSERT INTO privacy_settings (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`, [r.rows[0].id]);
    return this.map(r.rows[0]);
  }
  async findByEmail(email: string) { const r = await this.db.query(`SELECT * FROM users WHERE email=$1 LIMIT 1`, [email.trim().toLowerCase()]); return r.rows[0] ? this.map(r.rows[0]) : undefined; }
  async findOne(id: string) { const r = await this.db.query(`SELECT * FROM users WHERE id=$1 LIMIT 1`, [id]); return r.rows[0] ? this.map(r.rows[0]) : undefined; }
  publicProfile(user: UserRecord | undefined) { if (!user) throw new NotFoundException('User not found'); const { passwordHash: _passwordHash, ...safe } = user; return safe; }
  async update(id: string, dto: Record<string, unknown>) {
    const sets: string[] = []; const vals: unknown[] = [];
    const add = (column: string, value: unknown) => { vals.push(value); sets.push(`${column}=$${vals.length}`); };
    if (typeof dto.name === 'string' && dto.name.trim().length >= 2) add('name', dto.name.trim());
    if (typeof dto.country === 'string') add('country', dto.country.trim());
    if (typeof dto.preferredLanguage === 'string') add('preferred_language', dto.preferredLanguage.trim());
    if (!sets.length) { const user = await this.findOne(id); return this.publicProfile(user); }
    vals.push(id); const r = await this.db.query(`UPDATE users SET ${sets.join(', ')} WHERE id=$${vals.length} RETURNING *`, vals); if (!r.rowCount) throw new NotFoundException('User not found'); return this.publicProfile(this.map(r.rows[0]));
  }
  private map(row: any): UserRecord { return { id: row.id, name: row.name, email: row.email, country: row.country ?? undefined, preferredLanguage: row.preferred_language ?? undefined, passwordHash: row.password_hash, createdAt: row.created_at, updatedAt: row.updated_at }; }
}
