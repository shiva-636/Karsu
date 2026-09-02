import { Injectable } from '@nestjs/common';
import { RecordStoreService } from '../core/record-store.service';

@Injectable()
export class BusinessesService {
  constructor(private readonly store: RecordStoreService) {}
  async findAll(userId: string) { return await this.store.findAll('businesses', userId); }
  async findOne(id: string, userId: string) { return await this.store.findOne('businesses', id, userId); }
  async create(userId: string, dto: Record<string, unknown>) {
    const existing = (await this.findAll(userId))[0];
    return existing ? this.store.update('businesses', existing.id, userId, dto) : this.store.create('businesses', userId, dto);
  }
  async update(id: string, userId: string, dto: Record<string, unknown>) { return await this.store.update('businesses', id, userId, dto); }
  async remove(id: string, userId: string) { return await this.store.remove('businesses', id, userId); }
}
