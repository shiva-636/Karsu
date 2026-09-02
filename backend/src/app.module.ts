import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { CoreModule } from './core/core.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { BusinessesModule } from './businesses/businesses.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { IntelligenceModule } from './intelligence/intelligence.module';
import { IvModule } from './iv/iv.module';
import { NotificationsModule } from './notifications/notifications.module';
import { PrivacyModule } from './privacy/privacy.module';
import { RoadmapModule } from './roadmap/roadmap.module';
import { SkillsModule } from './skills/skills.module';
import { SurveysModule } from './surveys/surveys.module';
import { TasksModule } from './tasks/tasks.module';
import { TrackingModule } from './tracking/tracking.module';
import { HealthController } from './health.controller';

@Module({ controllers: [HealthController], imports: [ConfigModule.forRoot({ isGlobal: true, cache: true }), CoreModule, AuthModule, UsersModule, BusinessesModule, DashboardModule, IntelligenceModule, IvModule, NotificationsModule, PrivacyModule, RoadmapModule, SkillsModule, SurveysModule, TasksModule, TrackingModule] })
export class AppModule {}
