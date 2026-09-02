import { Module } from '@nestjs/common';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';
import { BusinessesModule } from '../businesses/businesses.module';
import { TasksModule } from '../tasks/tasks.module';
import { TrackingModule } from '../tracking/tracking.module';
import { SkillsModule } from '../skills/skills.module';

@Module({ imports: [BusinessesModule, TasksModule, TrackingModule, SkillsModule], controllers: [DashboardController], providers: [DashboardService] })
export class DashboardModule {}
