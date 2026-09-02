import { Injectable } from '@nestjs/common';
import { RecordStoreService } from '../core/record-store.service';

@Injectable()
export class TrackingService {
  constructor(private readonly store: RecordStoreService) {}
  async findAll(userId: string) { return await this.store.findAll('tracking', userId); }
  async findOne(id: string, userId: string) { return await this.store.findOne('tracking', id, userId); }
  async create(userId: string, dto: Record<string, unknown>) { return await this.store.create('tracking', userId, dto); }
  async update(id: string, userId: string, dto: Record<string, unknown>) { return await this.store.update('tracking', id, userId, dto); }
  async remove(id: string, userId: string) { return await this.store.remove('tracking', id, userId); }
}
