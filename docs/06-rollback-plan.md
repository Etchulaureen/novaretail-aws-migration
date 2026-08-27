# 06 — Rollback Plan

## Triggers

- Critical business function unavailable
- Data integrity uncertain
- Security failure
- Persistent connectivity issue
- Severe performance regression
- Recovery exceeds migration window

## Sequence

1. Announce rollback
2. Stop traffic to AWS target
3. Revert DNS/routing to source
4. Stop target-side writes
5. Restart source services
6. Validate source application and database
7. Confirm business functionality
8. Inform stakeholders
9. Preserve logs
10. Open root-cause investigation

## Important data rule

If writes occurred on the target after cutover, data reconciliation must be planned before rollback.

## Communication template

```text
Subject: NovaRetail Migration — Rollback Initiated
Reason: <reason>
Current status: <status>
Customer impact: <impact>
Next update: <time>
```
