import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from './database.service';

export type KarsuRecord = Record<string, unknown> & { id: string; userId: string; createdAt: string; updatedAt?: string };

type ResourceConfig = { table: string; columns: Record<string, string>; orderBy?: string };

const RESOURCES: Record<string, ResourceConfig> = {
  businesses: { table: 'business_profiles', columns: { type: 'business_type', businessType: 'business_type', industry: 'industry', idea: 'idea', problem: 'problem', targetCustomer: 'target_customer', proposedSolution: 'proposed_solution', stage: 'stage', existingCustomers: 'existing_customers', existingPrototype: 'existing_prototype', existingRevenue: 'existing_revenue', shortTermGoal30d: 'short_term_goal_30d', longTermGoal1y: 'long_term_goal_1y', vision5y: 'vision_5y', budgetAvailable: 'budget_available', hoursPerDay: 'hours_per_day', daysPerWeek: 'days_per_week', availableTimeMinutesPerDay: 'available_time_minutes_per_day' }, orderBy: 'created_at DESC' },
  skills: { table: 'skills', columns: { category: 'category', skillName: 'skill_name', skill_name: 'skill_name', score: 'score', assessmentDate: 'assessment_date' }, orderBy: 'created_at DESC' },
  tasks: { table: 'tasks', columns: { milestoneId: 'milestone_id', title: 'title', description: 'description', estimatedMinutes: 'estimated_minutes', difficulty: 'difficulty', purpose: 'purpose', status: 'status', scheduledDate: 'scheduled_date' }, orderBy: 'scheduled_date ASC, created_at DESC' },
  tracking: { table: 'daily_activities', columns: { activityDate: 'activity_date', tasksCompleted: 'tasks_completed', hoursWorked: 'hours_worked', learningHours: 'learning_hours', customersContacted: 'customers_contacted', meetings: 'meetings', networkingCount: 'networking_count', ideasGenerated: 'ideas_generated', experimentsRun: 'experiments_run', revenue: 'revenue', expenses: 'expenses', confidenceLevel: 'confidence_level', motivationLevel: 'motivation_level', reflection: 'reflection' }, orderBy: 'activity_date DESC' },
  surveys: { table: 'surveys', columns: { surveyDate: 'survey_date', questions: 'questions', responses: 'responses' }, orderBy: 'survey_date DESC' },
  experiments: { table: 'experiments', columns: { hypothesis: 'hypothesis', experimentDesc: 'experiment_desc', target: 'target', actualResult: 'actual_result', evidence: 'evidence', conclusion: 'conclusion', nextAction: 'next_action', startDate: 'start_date', endDate: 'end_date' }, orderBy: 'created_at DESC' },
  finance: { table: 'finance_records', columns: { recordType: 'record_type', category: 'category', amount: 'amount', recordDate: 'record_date', notes: 'notes' }, orderBy: 'record_date DESC' },
  team: { table: 'team_members', columns: { name: 'name', role: 'role', responsibilities: 'responsibilities', skills: 'skills', availability: 'availability' }, orderBy: 'created_at DESC' },
  intelligence: { table: 'user_intelligence', columns: { title: 'title', type: 'type', summary: 'summary', source: 'source', url: 'url', priority: 'priority', status: 'status' }, orderBy: 'created_at DESC' },
  notifications: { table: 'notifications', columns: { type: 'type', title: 'title', body: 'body', readAt: 'read_at' }, orderBy: 'created_at DESC' },
  roadmap: { table: 'roadmaps', columns: { stage: 'stage', completionPct: 'completion_pct' }, orderBy: 'updated_at DESC' },
  privacy: { table: 'privacy_settings', columns: { analyticsOptIn: 'analytics_opt_in', aiPersonalizationOptIn: 'ai_personalization_opt_in', marketingOptIn: 'marketing_opt_in', dataSharingOptIn: 'data_sharing_opt_in' }, orderBy: 'updated_at DESC' },
};

const toCamel = (key: string) => key.replace(/_([a-z])/g, (_, c) => c.toUpperCase());

@Injectable()
export class RecordStoreService {
  constructor(private readonly db: DatabaseService) {}
  private config(resource: string) { const cfg = RESOURCES[resource]; if (!cfg) throw new Error(`Unknown resource: ${resource}`); return cfg; }
  private mapRow(row: any): KarsuRecord { const out: any = {}; for (const [k, v] of Object.entries(row)) out[toCamel(k)] = v; return out as KarsuRecord; }
  async findAll(resource: string, userId: string) { const c = this.config(resource); const r = await this.db.query(`SELECT * FROM ${c.table} WHERE user_id = $1 ORDER BY ${c.orderBy ?? 'created_at DESC'}`, [userId]); return r.rows.map((x: any) => this.mapRow(x)); }
  async findOne(resource: string, id: string, userId: string) { const c = this.config(resource); const r = await this.db.query(`SELECT * FROM ${c.table} WHERE id = $1 AND user_id = $2 LIMIT 1`, [id, userId]); if (!r.rowCount) throw new NotFoundException('Record not found'); return this.mapRow(r.rows[0]); }
  async create(resource: string, userId: string, dto: Record<string, unknown>) {
    const c = this.config(resource); const entries = Object.entries(dto).filter(([k, v]) => c.columns[k] && v !== undefined);
    const cols = ['user_id', ...entries.map(([k]) => c.columns[k])]; const vals: unknown[] = [userId, ...entries.map(([, v]) => v)];
    const placeholders = vals.map((_, i) => `$${i + 1}`).join(', ');
    const r = await this.db.query(`INSERT INTO ${c.table} (${cols.join(', ')}) VALUES (${placeholders}) RETURNING *`, vals); return this.mapRow(r.rows[0]);
  }
  async update(resource: string, id: string, userId: string, dto: Record<string, unknown>) {
    const c = this.config(resource); const entries = Object.entries(dto).filter(([k, v]) => c.columns[k] && v !== undefined);
    if (!entries.length) return this.findOne(resource, id, userId);
    const set = entries.map(([k], i) => `${c.columns[k]} = $${i + 1}`).join(', '); const vals = entries.map(([, v]) => v);
    const r = await this.db.query(`UPDATE ${c.table} SET ${set} WHERE id = $${vals.length + 1} AND user_id = $${vals.length + 2} RETURNING *`, [...vals, id, userId]); if (!r.rowCount) throw new NotFoundException('Record not found'); return this.mapRow(r.rows[0]);
  }
  async remove(resource: string, id: string, userId: string) { const c = this.config(resource); const r = await this.db.query(`DELETE FROM ${c.table} WHERE id = $1 AND user_id = $2 RETURNING id`, [id, userId]); if (!r.rowCount) throw new NotFoundException('Record not found'); return { id, deleted: true }; }
}
