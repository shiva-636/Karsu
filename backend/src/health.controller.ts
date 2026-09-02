import { Controller, Get } from '@nestjs/common';
import { DatabaseService } from './core/database.service';
@Controller('health')
export class HealthController {
  constructor(private readonly db: DatabaseService) {}
  @Get()
  async check() { const result = await this.db.query('SELECT NOW() AS time'); return { status: 'ok', database: 'ok', time: result.rows[0].time }; }
}
