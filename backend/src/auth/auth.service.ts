import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac, randomBytes, randomUUID, scrypt as scryptCallback, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { UsersService } from '../users/users.service';
import { DatabaseService } from '../core/database.service';

const scrypt = promisify(scryptCallback);

type TokenPayload = { sub: string; sid: string; exp: number };

@Injectable()
export class AuthService {
  private readonly secret: string;
  private readonly ttlSeconds: number;
  constructor(private readonly users: UsersService, private readonly db: DatabaseService, config: ConfigService) {
    this.secret = config.get<string>('AUTH_SECRET') ?? '';
    this.ttlSeconds = Math.max(300, Number(config.get<string>('AUTH_TOKEN_TTL_SECONDS') ?? 604800));
    if (this.secret.length < 32) throw new Error('AUTH_SECRET must be at least 32 characters');
  }
  async register(dto: RegisterDto) {
    if (await this.users.findByEmail(dto.email)) throw new ConflictException('An account with this email already exists');
    const passwordHash = await this.hashPassword(dto.password);
    try {
      const user = await this.users.createAccount({ ...dto, passwordHash });
      return { user: this.users.publicProfile(user), token: await this.createSession(user.id) };
    } catch (e: any) {
      if (e?.code === '23505') throw new ConflictException('An account with this email already exists');
      throw e;
    }
  }
  async login(dto: LoginDto) {
    const user = await this.users.findByEmail(dto.email);
    if (!user?.passwordHash || user.passwordHash === 'MIGRATION_REQUIRED' || !(await this.verifyPassword(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('Invalid email or password');
    }
    return { user: this.users.publicProfile(user), token: await this.createSession(user.id) };
  }
  async logout(token: string | undefined) {
    if (token) await this.revokeToken(token);
    return { success: true };
  }
  async verifyToken(token: string) {
    const [payload, signature] = token.split('.');
    if (!payload || !signature) throw new UnauthorizedException('Invalid session');
    const expected = this.signature(payload);
    if (signature.length !== expected.length || !timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) throw new UnauthorizedException('Invalid session');
    let decoded: TokenPayload;
    try { decoded = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')); } catch { throw new UnauthorizedException('Invalid session'); }
    if (!decoded.sub || !decoded.sid || !decoded.exp || decoded.exp < Math.floor(Date.now() / 1000)) throw new UnauthorizedException('Session expired');
    const r = await this.db.query(`SELECT user_id FROM auth_sessions WHERE token_id=$1 AND user_id=$2 AND revoked_at IS NULL AND expires_at > now() LIMIT 1`, [decoded.sid, decoded.sub]);
    if (!r.rowCount) throw new UnauthorizedException('Session expired or revoked');
    if (!(await this.users.findOne(decoded.sub))) throw new UnauthorizedException('User no longer exists');
    return { userId: decoded.sub, sessionId: decoded.sid };
  }
  private async createSession(userId: string) {
    const sid = randomUUID();
    const exp = Math.floor(Date.now() / 1000) + this.ttlSeconds;
    await this.db.query(`INSERT INTO auth_sessions (user_id, token_id, expires_at) VALUES ($1,$2,to_timestamp($3))`, [userId, sid, exp]);
    const payload = Buffer.from(JSON.stringify({ sub: userId, sid, exp })).toString('base64url');
    return `${payload}.${this.signature(payload)}`;
  }
  private async revokeToken(token: string) {
    const [payload] = token.split('.');
    if (!payload) return;
    try { const decoded = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')) as TokenPayload; if (decoded.sid) await this.db.query(`UPDATE auth_sessions SET revoked_at=now() WHERE token_id=$1`, [decoded.sid]); } catch { /* logout is intentionally idempotent */ }
  }
  private signature(payload: string) { return createHmac('sha256', this.secret).update(payload).digest('hex'); }
  private async hashPassword(password: string) { const salt = randomBytes(16).toString('hex'); const derived = (await scrypt(password, salt, 64, { N: 16384, r: 8, p: 1 })) as Buffer; return `${salt}:${derived.toString('hex')}`; }
  private async verifyPassword(password: string, stored: string) { const [salt, hex] = stored.split(':'); if (!salt || !hex) return false; const derived = (await scrypt(password, salt, 64, { N: 16384, r: 8, p: 1 })) as Buffer; const expected = Buffer.from(hex, 'hex'); return expected.length === derived.length && timingSafeEqual(expected, derived); }
}
