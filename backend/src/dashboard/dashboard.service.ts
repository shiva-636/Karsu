import { Injectable } from '@nestjs/common';
import { BusinessesService } from '../businesses/businesses.service';
import { TasksService } from '../tasks/tasks.service';
import { TrackingService } from '../tracking/tracking.service';
import { SkillsService } from '../skills/skills.service';
import { KarsuRecord } from '../core/record-store.service';

@Injectable()
export class DashboardService {
  constructor(private readonly businesses: BusinessesService, private readonly tasks: TasksService, private readonly tracking: TrackingService, private readonly skills: SkillsService) {}

  async snapshot(userId: string) {
    const business = (await this.businesses.findAll(userId))[0] ?? {};
    const tasks = await this.tasks.findAll(userId);
    const tracking = await this.tracking.findAll(userId);
    const skills = await this.skills.findAll(userId);
    const done = tasks.filter((t: KarsuRecord) => t.status === 'completed').length;
    const total = tasks.length;
    const health = Math.max(0, Math.min(100, Math.round((total ? done / total : 0.35) * 70 + Math.min(tracking.length, 10) * 3)));
    const entrepreneur = Math.max(0, Math.min(100, Math.round(Math.min(tracking.length * 6, 60) + Math.min(skills.length * 4, 40))));
    return {
      business,
      stage: business.stage ?? 'discover',
      nextAction: tasks.find((t: KarsuRecord) => t.status !== 'completed') ?? { title: 'Define your first measurable milestone', estimatedMinutes: 30 },
      metrics: { tasksCompleted: done, tasksTotal: total, activityEntries: tracking.length, skillsTracked: skills.length },
      scores: { businessHealth: health, entrepreneurDevelopment: entrepreneur },
    };
  }
}
