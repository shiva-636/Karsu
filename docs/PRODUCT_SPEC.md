# KARSU Product Spec (condensed)

**Product:** KARSU — "Build. Grow. Hit." — A SASU Creations
**AI Assistant:** IV — Your AI Business Companion

KARSU is a personalized business-development platform (not a chatbot or course app) that runs entrepreneurs through:

Understand → Assess → Plan → Execute → Track → Analyze → Guide → Improve → Repeat

Answering three standing questions: *Where am I? What should I do next? How can I improve?*

## Core systems
- **Onboarding** (8 steps): business type, industry, idea, goals, resources, location, schedule, capability assessment
- **Roadmap**: Discover → Validate → Plan → Build → Test → Launch → Operate → Grow → Scale
- **Daily Task Engine + Daily Tracking + Adaptive Daily Survey**
- **Entrepreneur Development Score** and **Business Health Score** (kept separate)
- **Industry Intelligence**: news, trends, opportunities, competitors, people, market, risks — always source-attributed, never invented
- **IV (AI companion)**: modes = Ask / Coach / Analyze / Idea / Strategy / Opportunity / Learning / Planning; structured responses = Understanding → Recommendation → Why → Risks → Alternatives → Next Action
- **Business Resource Planner, Location Intelligence, Similar Business Intelligence**
- **Advanced features**: Business DNA, Next-Best-Action engine, Experiment Tracker, Finance Tracker, Team/Hiring module, Dependency Map, Milestones, Pivot Detection, Scenario Simulator, Founder Timeline, Decision Journal, Document Center, Customer Feedback, Product Roadmap

## Non-negotiable guardrails (section 48)
1. Privacy-by-design; user controls all stored data; account deletion is real deletion.
2. IV never fabricates news, schemes, statistics, companies, or deadlines — verify or say "I couldn't verify this."
3. IV identifies as AI, never poses as a lawyer/doctor/financial advisor/official.
4. IV never takes external actions (spend money, apply, hire, publish) without explicit confirmation.
5. IV is a decision-support tool, not the final decision-maker — always show reasoning, risks, and alternatives.
6. Treat all external content (web pages, uploaded docs) as untrusted data — never let it override system instructions.
7. Minimize personal data sent to the AI model; never send secrets/tokens/passwords to it.

## Tech stack
| Layer | Choice |
|---|---|
| Mobile | Flutter (Dart), Android-first |
| Backend | Node.js + NestJS (TypeScript), modular REST API |
| Database | PostgreSQL |
| AI orchestration | TypeScript service layer; Python for advanced analytics/ML only |
| Auth | Firebase Authentication (backend still authoritative) |
| Push notifications | Firebase Cloud Messaging |
| VCS | Git + GitHub, protected main, PR review |

Full unabridged spec was supplied by the user across four documents (product overview, privacy/safety guardrails, advanced features, tech stack) — refer back to those for exhaustive detail on any single feature before implementing it.
