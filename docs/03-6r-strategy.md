# 03 — Migration Strategy (6R)

| Workload | Strategy | Target | Reason |
|---|---|---|---|
| WEB01 | Rehost | Amazon EC2 | Minimal change, fast move |
| APP01 | Replatform | EC2 + managed services | Improve hosting without rewriting |
| DB01 | Replatform | Amazon RDS PostgreSQL | Managed database operations |
| FILE01 | Replatform | Amazon S3 | Remove file-server maintenance |
| LEGACY01 | Retire | Decommission | No business value |
| HR01 | Retain | On-premises | Temporary contractual dependency |

## Definitions

- **Rehost:** move with minimal modification.
- **Replatform:** limited change to use managed cloud services.
- **Refactor/Re-architect:** redesign for cloud-native patterns.
- **Retire:** remove obsolete workloads.
- **Retain:** leave a workload where it is for now.

## Decision criteria

Business criticality, dependencies, downtime tolerance, security, complexity, cost, timeline and long-term operating model.
