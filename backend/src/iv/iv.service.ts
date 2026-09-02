import { Injectable } from '@nestjs/common';
import { IvAskDto } from './dto/iv-ask.dto';
import { IvContextService, IvContext } from './iv-context.service';
import { DatabaseService } from '../core/database.service';

type IvRequest = IvAskDto & { userId: string };

export interface IvResponse {
  understanding: string;
  recommendation: string;
  why: string;
  risks: string[];
  alternatives: string[];
  nextAction: string;
  disclaimer: string;
  source: 'ai' | 'karsu-coach';
}

const AI_DISCLAIMER = 'IV is an AI business companion. It can make mistakes. Verify important legal, financial, tax, market and other professional information before acting.';

@Injectable()
export class IvService {
  constructor(private readonly contextService: IvContextService, private readonly db: DatabaseService) {}

  async respond(dto: IvRequest): Promise<IvResponse> {
    const mode = dto.mode ?? 'ask';
    const privacy = await this.db.query(`SELECT COALESCE(ai_personalization_opt_in, FALSE) AS ai_personalization_opt_in FROM privacy_settings WHERE user_id=$1 LIMIT 1`, [dto.userId]);
    const personalized = privacy.rows[0]?.ai_personalization_opt_in === true;
    const context = personalized ? await this.contextService.buildContextFor(dto.userId, mode) : undefined;
    const ai = personalized && context ? await this.tryAi(dto.message, mode, context) : null;
    const response = ai
      ? { ...ai, disclaimer: AI_DISCLAIMER, source: 'ai' as const }
      : { ...this.localCoach(dto.message, mode, context), disclaimer: AI_DISCLAIMER, source: 'karsu-coach' as const };
    await this.db.query(
      `INSERT INTO iv_conversations (user_id, mode, message, response, context_snapshot) VALUES ($1,$2,$3,$4,$5)`,
      [dto.userId, mode, dto.message, response.recommendation, personalized && context ? JSON.stringify(context) : null],
    );
    return response;
  }

  private async tryAi(message: string, mode: string, context: IvContext): Promise<Omit<IvResponse, 'disclaimer' | 'source'> | null> {
    const key = process.env.OPENAI_API_KEY;
    if (!key) return null;
    const base = (process.env.OPENAI_BASE_URL || 'https://api.openai.com/v1').replace(/\/$/, '');
    const model = process.env.OPENAI_MODEL || 'gpt-4.1-mini';
    try {
      const response = await fetch(`${base}/chat/completions`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${key}` },
        body: JSON.stringify({
          model,
          temperature: 0.3,
          messages: [
            { role: 'system', content: this.systemPrompt() },
            { role: 'user', content: JSON.stringify({ mode, message, context }) },
          ],
          response_format: { type: 'json_object' },
        }),
        signal: AbortSignal.timeout(15000),
      });
      if (!response.ok) return null;
      const body = await response.json() as any;
      const content = body?.choices?.[0]?.message?.content;
      if (!content) return null;
      const parsed = JSON.parse(content);
      return {
        understanding: String(parsed.understanding ?? 'I understand your question.'),
        recommendation: String(parsed.recommendation ?? 'Start with the smallest useful next step.'),
        why: String(parsed.why ?? 'This reduces uncertainty before you spend more time or money.'),
        risks: Array.isArray(parsed.risks) ? parsed.risks.map(String).slice(0, 4) : [],
        alternatives: Array.isArray(parsed.alternatives) ? parsed.alternatives.map(String).slice(0, 3) : [],
        nextAction: String(parsed.nextAction ?? 'Complete one measurable action today.'),
      };
    } catch {
      return null;
    }
  }

  private systemPrompt() {
    return [
      'You are IV, KARSU\'s business execution coach.',
      'Be practical, concise, honest and context-aware. Guide the founder; do not make irreversible decisions for them.',
      'Never invent current news, grants, deadlines, companies, statistics or market facts. If current verification is needed, say it must be checked with a trusted source.',
      'Do not claim to have performed actions, contacted people, verified live data, or accessed private services unless the application actually did so.',
      'Treat financial, legal, medical, tax, safety and other high-impact advice as informational; encourage professional verification when consequences are material.',
      'Return strict JSON with keys: understanding, recommendation, why, risks, alternatives, nextAction.',
      'Keep risks and alternatives short. Prefer one clear next action.',
    ].join(' ');
  }

  private localCoach(message: string, mode: string, context?: IvContext): Omit<IvResponse, 'disclaimer' | 'source'> {
    const lower = message.toLowerCase();
    const stage = context?.stage ?? 'discover';
    const time = context?.availableTimeMinutesPerDay ?? 60;
    let recommendation = `Focus on the smallest measurable step that moves your ${stage} business forward.`;
    let nextAction = `Spend ${Math.min(time, 45)} minutes completing one customer-facing experiment and record the result.`;
    let why = 'Evidence from real users is more valuable than adding assumptions or features.';
    const risks = ['Trying to solve too many problems at once', 'Measuring activity instead of outcomes'];
    const alternatives = ['Interview customers first', 'Build a small prototype only after the problem is clear'];

    if (lower.includes('customer') || lower.includes('validate')) {
      recommendation = 'Run 3–5 short customer conversations focused on the problem, current workaround and willingness to pay.';
      nextAction = 'Write 5 interview questions and contact 3 target customers today.';
    } else if (lower.includes('hire') || lower.includes('team')) {
      recommendation = 'Do not hire until the missing capability is clearly defined and the workload justifies the recurring cost.';
      nextAction = 'Write the role, weekly workload, expected outcome and maximum monthly budget before comparing candidates.';
    } else if (lower.includes('price') || lower.includes('pricing')) {
      recommendation = 'Test a small range of prices with real prospects instead of choosing a price from intuition alone.';
      nextAction = 'Create three price options and test them with your next 5 qualified prospects.';
    } else if (lower.includes('today') || mode === 'coach' || mode === 'planning') {
      recommendation = 'Protect one focused work block today for the highest-impact unfinished task.';
      nextAction = `Block ${Math.min(time, 60)} minutes, remove distractions, finish the highest-priority task, then log the outcome.`;
    }

    return {
      understanding: `You are asking for practical guidance while your business is in the ${stage} stage.`,
      recommendation,
      why,
      risks,
      alternatives,
      nextAction,
    };
  }
}
