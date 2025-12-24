You are working on a product called LifeOS.

LifeOS is a personal life management system — a “digital operating system” for a person.
The goal is to help users consciously track, analyze, and improve their life using data.

Core idea:
LifeOS helps users manage:
- time
- energy
- money
- habits
- goals
- projects
- health & well-being
- gym
- personal growth

This is NOT a simple todo app.
This is a long-term evolving system that combines tracking, analytics, and reflection.

Target audience:
- Individuals focused on self-improvement
- Entrepreneurs, developers, creators
- People who want clarity, structure, and control over their life
- Power users who value data-driven decisions

Project structure (monorepo):
- lifeos_backend/ — Laravel (PHP) REST API
- lifeos_client/ — Flutter mobile app

Backend (lifeos_backend):
- Acts as the central brain of LifeOS.
- Stores structured life data (events, logs, metrics).
- Provides analytics, summaries, trends, and insights.
- Designed for scalability and long-term data storage.
- Uses clean architecture (Controllers → Services → Domain logic).
- API-first, JSON-only.
- Authentication is token-based (Sanctum or JWT).
- Future support for AI features (insights, recommendations, summaries).

Client (lifeos_client):
- Flutter mobile/desktop app.
- Primary interface for daily interaction.
- Fast input is critical (minimal friction).
- UI focuses on clarity, calmness, and productivity.
- Offline-first where possible, with sync to backend.
- Uses BLoC/Cubit for state management.
- Clear separation: data / domain / presentation.

Key product principles:
1. Minimal friction — quick logging is more important than perfect structure.
2. Data > feelings — decisions are based on tracked data.
3. Long-term thinking — data should be meaningful after months and years.
4. Modular system — features are independent but connected.
5. No magic — all insights should be explainable.

Initial core modules (MVP → evolving):
- Time tracking (manual + assisted)
- Money tracking (income, expenses, categories)
- Habit tracking
- Goals & projects
- Daily logs / reflections
- Basic analytics & charts

Future modules (keep in mind when designing):
- AI insights & summaries
- Predictions & trends
- Automation rules
- Integrations (calendar, banking, health data)
- Multi-device sync
- Web dashboard

Interaction rules for code generation:
- Always respect the separation between backend and client.
- If adding a feature, think in terms of:
  1. Data model
  2. API contract
  3. Client usage
- Prefer extensible schemas over hardcoded logic.
- Avoid overengineering, but never block future growth.
- Use consistent naming between backend responses and Flutter models.

Assume:
- Code quality and architecture matter more than speed hacks.

Use this context as permanent background for all future answers.