# IV Model Architecture

IV is designed as a **context-first decision assistant**, not a generic chatbot.

## Context hierarchy

1. User profile — only the minimum relevant fields.
2. Business — type, industry, stage, idea, problem, customer and goals.
3. Execution — open tasks, recent activity and available time.
4. Capability — skills/weaknesses when available.
5. Intelligence — only verified/current information when a retrieval layer is connected.

## Response contract

Every recommendation follows:

- Understanding
- Recommendation
- Why
- Risks
- Alternatives
- Next action

The model is instructed not to invent current facts, opportunities, deadlines, statistics or companies.

## Model strategy

- **AI mode:** an OpenAI-compatible chat completion is used when `OPENAI_API_KEY` is configured.
- **Fallback mode:** KARSU Coach uses deterministic business heuristics so the app remains useful during development and offline from the model provider.
- **Temperature:** low for execution/decision guidance to reduce variability.
- **Server-side key:** model credentials never enter Flutter.
- **User control:** IV recommends; it never spends money, hires, applies, publishes or deletes data.

## Next model upgrades

For the production version, add retrieval-augmented generation for verified industry/news/opportunity data, an evaluation set for response quality, structured tool calls, model/version logging, prompt-injection isolation for external content, and PostgreSQL-backed long-term business memory.
