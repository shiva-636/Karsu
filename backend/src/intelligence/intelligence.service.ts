import { Injectable } from '@nestjs/common';
import { RecordStoreService } from '../core/record-store.service';

@Injectable()
export class IntelligenceService {
  constructor(private readonly store: RecordStoreService) {}
  async findAll(userId: string) { return await this.store.findAll('intelligence', userId); }
  async findOne(id: string, userId: string) { return await this.store.findOne('intelligence', id, userId); }
  async create(userId: string, dto: Record<string, unknown>) { return await this.store.create('intelligence', userId, dto); }
  async update(id: string, userId: string, dto: Record<string, unknown>) { return await this.store.update('intelligence', id, userId, dto); }
  async remove(id: string, userId: string) { return await this.store.remove('intelligence', id, userId); }
}
