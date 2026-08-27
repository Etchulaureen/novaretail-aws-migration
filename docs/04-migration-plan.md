# 04 — Migration Plan

## Lifecycle

Assessment → Planning → Target preparation → Pre-checks → Migration → Cutover → Validation → Business acceptance → Hypercare → Handover

## Waves

- **Wave 0:** AWS foundation
- **Wave 1:** low-risk pilot
- **Wave 2:** web/application tier
- **Wave 3:** database
- **Wave 4:** file service
- **Wave 5:** retire/retain decisions

## Roles

| Role | Responsibility |
|---|---|
| Migration Lead | Overall coordination |
| Cloud Engineer | Target infrastructure |
| App Owner | Application validation |
| DBA | Database migration |
| Network | Connectivity |
| Security | Security validation |
| Business Owner | Acceptance |
| Junior Migration Consultant | Inventory, runbook, tracking, checks, documentation and coordination support |

## Communications

- Daily readiness check in migration week
- Final go/no-go meeting
- Status every 30–60 minutes during cutover
- Immediate escalation for critical failure
