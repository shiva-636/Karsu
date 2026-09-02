import { Injectable } from '@nestjs/common';
import { RecordStoreService } from '../core/record-store.service';

@Injectable()
export class NotificationsService {
  constructor(private readonly store: RecordStoreService) {}
  async findAll(userId: string) { return await this.store.findAll('notifications', userId); }
  async findOne(id: string, userId: string) { return await this.store.findOne('notifications', id, userId); }
  async create(userId: string, dto: Record<string, unknown>) { return await this.store.create('notifications', userId, dto); }
  async update(id: string, userId: string, dto: Record<string, unknown>) { return await this.store.update('notifications', id, userId, dto); }
  async remove(id: string, userId: string) { return await this.store.remove('notifications', id, userId); }
}
