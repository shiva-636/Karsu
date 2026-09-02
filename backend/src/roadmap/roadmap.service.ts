import { Injectable } from '@nestjs/common';
import { RecordStoreService } from '../core/record-store.service';

@Injectable()
export class RoadmapService {
  constructor(private readonly store: RecordStoreService) {}
  async findAll(userId: string) { return await this.store.findAll('roadmap', userId); }
  async findOne(id: string, userId: string) { return await this.store.findOne('roadmap', id, userId); }
  async create(userId: string, dto: Record<string, unknown>) { return await this.store.create('roadmap', userId, dto); }
  async update(id: string, userId: string, dto: Record<string, unknown>) { return await this.store.update('roadmap', id, userId, dto); }
  async remove(id: string, userId: string) { return await this.store.remove('roadmap', id, userId); }
}
