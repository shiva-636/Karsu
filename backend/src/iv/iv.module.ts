import { Module } from '@nestjs/common';
import { IvController } from './iv.controller';
import { IvService } from './iv.service';
import { IvContextService } from './iv-context.service';
import { UsersModule } from '../users/users.module';
import { BusinessesModule } from '../businesses/businesses.module';
import { TasksModule } from '../tasks/tasks.module';
import { TrackingModule } from '../tracking/tracking.module';

@Module({ imports: [UsersModule, BusinessesModule, TasksModule, TrackingModule], controllers: [IvController], providers: [IvService, IvContextService], exports: [IvService] })
export class IvModule {}
