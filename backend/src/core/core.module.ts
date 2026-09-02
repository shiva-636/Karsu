import { Global, Module } from '@nestjs/common';
import { DatabaseService } from './database.service';
import { RecordStoreService } from './record-store.service';
import { MigrationService } from './migration.service';

@Global()
@Module({ providers: [DatabaseService, RecordStoreService, MigrationService], exports: [DatabaseService, RecordStoreService] })
export class CoreModule {}
