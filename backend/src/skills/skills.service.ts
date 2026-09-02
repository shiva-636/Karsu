import { Injectable } from '@nestjs/common';
import { RecordStoreService } from '../core/record-store.service';

@Injectable()
export class SkillsService {
  constructor(private readonly store: RecordStoreService) {}
  async findAll(userId: string) { return await this.store.findAll('skills', userId); }
  async findOne(id: string, userId: string) { return await this.store.findOne('skills', id, userId); }
  async create(userId: string, dto: Record<string, unknown>) { return await this.store.create('skills', userId, dto); }
  async update(id: string, userId: string, dto: Record<string, unknown>) { return await this.store.update('skills', id, userId, dto); }
  async remove(id: string, userId: string) { return await this.store.remove('skills', id, userId); }
}
