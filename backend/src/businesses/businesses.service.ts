import { Injectable } from '@nestjs/common';
import { RecordStoreService } from '../core/record-store.service';

@Injectable()
export class BusinessesService {
  constructor(private readonly store: RecordStoreService) {}

  async findAll(userId: string) {
    const businesses = await this.store.findAll('businesses', userId);

    for (const business of businesses) {
      await this.bootstrapBusinessWorkspace(userId, business);
    }

    return businesses;
  }

  async findOne(id: string, userId: string) {
    const business = await this.store.findOne(
      'businesses',
      id,
      userId,
    );

    if (business) {
      await this.bootstrapBusinessWorkspace(userId, business);
    }

    return business;
  }

  async create(userId: string, dto: Record<string, unknown>) {
    const existing = (
      await this.store.findAll('businesses', userId)
    )[0];

    const business = existing
      ? await this.store.update(
          'businesses',
          existing.id,
          userId,
          dto,
        )
      : await this.store.create(
          'businesses',
          userId,
          dto,
        );

    await this.bootstrapBusinessWorkspace(
      userId,
      business,
    );

    return business;
  }

  async update(
    id: string,
    userId: string,
    dto: Record<string, unknown>,
  ) {
    const business = await this.store.update(
      'businesses',
      id,
      userId,
      dto,
    );

    await this.bootstrapBusinessWorkspace(
      userId,
      business,
    );

    return business;
  }

  async remove(id: string, userId: string) {
    return await this.store.remove(
      'businesses',
      id,
      userId,
    );
  }

  private async bootstrapBusinessWorkspace(
    userId: string,
    business: Record<string, unknown>,
  ) {
    const roadmaps = await this.store.findAll(
      'roadmap',
      userId,
    );

    if (roadmaps.length === 0) {
      const stage = String(
        business['stage'] ?? 'idea',
      );

      await this.store.create('roadmap', userId, {
        stage,
        completionPct: 0,
      });
    }

    const tasks = await this.store.findAll(
      'tasks',
      userId,
    );

    if (tasks.length > 0) {
      return;
    }

    const today = new Date()
      .toISOString()
      .slice(0, 10);

    const idea = String(
      business['idea'] ?? 'your business idea',
    );

    const targetCustomer = String(
      business['targetCustomer'] ??
        'your target customer',
    );

    const problem = String(
      business['problem'] ??
        'the customer problem',
    );

    await this.store.create('tasks', userId, {
      title: 'Define your first measurable milestone',
      description:
        `Write one measurable outcome for ${idea} ` +
        `that you want to achieve next.`,
      estimatedMinutes: 30,
      difficulty: 'easy',
      purpose:
        'Turn your business idea into a measurable outcome.',
      status: 'pending',
      scheduledDate: today,
    });

    await this.store.create('tasks', userId, {
      title: 'Talk to 3 potential customers',
      description:
        `Speak with 3 people who could be ${targetCustomer} ` +
        `and learn how they currently handle ${problem}.`,
      estimatedMinutes: 45,
      difficulty: 'easy',
      purpose:
        'Validate that the problem is real and important.',
      status: 'pending',
      scheduledDate: today,
    });

    await this.store.create('tasks', userId, {
      title: 'Write your problem statement',
      description:
        'Describe the customer, their problem, the current ' +
        'alternative, and why your solution could be better.',
      estimatedMinutes: 30,
      difficulty: 'easy',
      purpose:
        'Create a clear foundation for validation.',
      status: 'pending',
      scheduledDate: today,
    });
  }
}
