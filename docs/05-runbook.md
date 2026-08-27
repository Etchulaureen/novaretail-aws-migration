# 05 — Migration Runbook

**Scope:** WEB01 / APP01

## Pre-migration

- [ ] Change approved
- [ ] Stakeholders informed
- [ ] Backup completed and restore tested
- [ ] Source health validated
- [ ] Target infrastructure deployed
- [ ] Security groups validated
- [ ] DNS values documented
- [ ] Database connectivity tested
- [ ] Monitoring enabled
- [ ] Rollback reviewed
- [ ] Business validation ready

Run:

```bash
./scripts/pre_migration_check.sh <source-host> <backup-file>
```

## Execution

1. Announce migration start
2. Confirm no unexpected production activity
3. Enter maintenance mode
4. Stop write traffic
5. Final data synchronisation
6. Start target services
7. Test database connectivity
8. Smoke-test application
9. Change DNS / load-balancer target
10. Start business validation

## Validation

Technical:
- [ ] HTTP success
- [ ] Application healthy
- [ ] Database reachable
- [ ] No critical log errors
- [ ] CloudWatch visible
- [ ] ALB targets healthy

Business:
- [ ] Login works
- [ ] Key transaction works
- [ ] Expected data visible
- [ ] Business owner approves

## Rollback criteria

Rollback if a critical function fails, data is inconsistent, a security control breaks, downtime exceeds the approved window, or root cause cannot be fixed before the rollback deadline.
