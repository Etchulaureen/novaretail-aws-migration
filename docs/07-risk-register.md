# 07 — Risk Register

| ID | Risk | Probability | Impact | Mitigation | Owner |
|---|---|---|---|---|---|
| R1 | Data loss | Low | Critical | RDS snapshot restore tested; post-migration validation completed | DBA |
| R2 | Downtime exceeds window | Medium | High | Rehearsal, rollback deadline | Migration Lead |
| R3 | Missed dependency | Medium | Critical | Dependency mapping | App Owner |
| R4 | DNS cutover failure | Medium | High | Lower TTL, pre-test | Network |
| R5 | Security misconfiguration | Medium | Critical | Peer review, least privilege | Cloud Engineer |
| R6 | Performance degradation | Medium | High | Baseline + CloudWatch | Cloud Engineer |
| R7 | Missing stakeholder | Low | High | Backup contacts | PM |
| R8 | Higher-than-planned cost | Medium | Medium | Rightsizing review | FinOps |
| R9 | Backup cannot restore | Low | Critical | Manual RDS snapshot restore test completed successfully | DBA |
| R10 | User acceptance failure | Medium | High | Defined test cases | Business Owner |
