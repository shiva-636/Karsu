import { Injectable } from '@nestjs/common';
import { RecordStoreService } from '../core/record-store.service';

@Injectable()
export class PrivacyService {
  constructor(private readonly store: RecordStoreService) {}
  async findAll(userId: string) { return await this.store.findAll('privacy', userId); }
  async findOne(id: string, userId: string) { return await this.store.findOne('privacy', id, userId); }
  async create(userId: string, dto: Record<string, unknown>) { return await this.store.create('privacy', userId, dto); }
  async update(id: string, userId: string, dto: Record<string, unknown>) { return await this.store.update('privacy', id, userId, dto); }
  async remove(id: string, userId: string) { return await this.store.remove('privacy', id, userId); }
}
