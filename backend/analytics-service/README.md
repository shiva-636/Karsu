# KARSU Analytics Service (Python)

Optional specialized service for advanced analytics, ML-based recommendation
models, and forecasting (spec section 5 / tech-stack section 15). The core
backend stays NestJS/TypeScript — this service is only invoked for
computationally heavy work the NestJS service delegates to it over HTTP.

## Suggested layout

```
analytics-service/
├── requirements.txt
├── app.py                 # FastAPI entrypoint
├── scoring/
│   ├── entrepreneur_score.py
│   └── business_health_score.py
└── forecasting/
    └── scenario_simulator.py
```

Keep this service stateless where possible — read from PostgreSQL, compute,
return JSON. Do not duplicate authorization logic here; only accept calls
from the trusted NestJS backend, not directly from the mobile app.
