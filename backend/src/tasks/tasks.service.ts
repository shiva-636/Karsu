import { Injectable } from '@nestjs/common';
import { RecordStoreService } from '../core/record-store.service';

@Injectable()
export class TasksService {
  constructor(private readonly store: RecordStoreService) {}
  async findAll(userId: string) { return await this.store.findAll('tasks', userId); }
  async findOne(id: string, userId: string) { return await this.store.findOne('tasks', id, userId); }
  async create(userId: string, dto: Record<string, unknown>) { return await this.store.create('tasks', userId, dto); }
  async update(id: string, userId: string, dto: Record<string, unknown>) { return await this.store.update('tasks', id, userId, dto); }
  async remove(id: string, userId: string) { return await this.store.remove('tasks', id, userId); }
}
