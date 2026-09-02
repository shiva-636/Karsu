import { Injectable } from '@nestjs/common';
import { RecordStoreService } from '../core/record-store.service';

@Injectable()
export class SurveysService {
  constructor(private readonly store: RecordStoreService) {}
  async findAll(userId: string) { return await this.store.findAll('surveys', userId); }
  async findOne(id: string, userId: string) { return await this.store.findOne('surveys', id, userId); }
  async create(userId: string, dto: Record<string, unknown>) { return await this.store.create('surveys', userId, dto); }
  async update(id: string, userId: string, dto: Record<string, unknown>) { return await this.store.update('surveys', id, userId, dto); }
  async remove(id: string, userId: string) { return await this.store.remove('surveys', id, userId); }
}
