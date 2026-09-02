import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { BusinessesService } from '../businesses/businesses.service';
import { TasksService } from '../tasks/tasks.service';
import { TrackingService } from '../tracking/tracking.service';
import { KarsuRecord } from '../core/record-store.service';

export interface IvContext {
  user?: { name?: string; country?: string; preferredLanguage?: string };
  business?: Record<string, unknown>;
  stage?: string;
  goals?: string[];
  availableTimeMinutesPerDay?: number;
  currentTasks?: Array<Record<string, unknown>>;
  recentActivitySummary?: string;
  weaknesses?: string[];
}

@Injectable()
export class IvContextService {
  constructor(
    private readonly users: UsersService,
    private readonly businesses: BusinessesService,
    private readonly tasks: TasksService,
    private readonly tracking: TrackingService,
  ) {}

  async buildContextFor(userId: string, _mode: string): Promise<IvContext> {
    const user = await this.users.findOne(userId);
    const businessRecords = await this.businesses.findAll(userId);
    const taskRecords = await this.tasks.findAll(userId);
    const activity = await this.tracking.findAll(userId);
    const business = businessRecords[0];
    const recent = activity.slice(-7);
    const completed = taskRecords.filter((t: KarsuRecord) => t.status === 'completed').length;
    const pending = taskRecords.filter((t: KarsuRecord) => t.status !== 'completed').length;
    return {
      user: user ? { name: user.name, country: user.country, preferredLanguage: user.preferredLanguage } : undefined,
      business,
      stage: String(business?.stage ?? 'discover'),
      goals: Array.isArray(business?.goals) ? business?.goals as string[] : [],
      availableTimeMinutesPerDay: Number(business?.availableTimeMinutesPerDay ?? 60),
      currentTasks: taskRecords.slice(-5),
      recentActivitySummary: `${completed} completed tasks, ${pending} open tasks, ${recent.length} recent activity entries.`,
      weaknesses: Array.isArray(business?.weaknesses) ? business?.weaknesses as string[] : [],
    };
  }
}
