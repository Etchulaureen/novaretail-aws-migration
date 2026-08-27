# 02 — Current-State Assessment

A migration starts with discovery, not with building cloud resources.

| Workload | Platform | Role | Criticality | Dependencies | Concern |
|---|---|---|---|---|---|
| WEB01 | Ubuntu VM | Public web server | High | APP01 | Ageing VM |
| APP01 | Ubuntu VM | Python application | Critical | DB01 | Limited scalability |
| DB01 | PostgreSQL | Transaction database | Critical | APP01 | Backup / HA |
| FILE01 | Linux VM | Shared documents | Medium | Users | Storage growth |
| LEGACY01 | Windows Server | Old reporting | Low | None | No longer used |
| HR01 | Windows Server | HR system | Medium | Local directory | Contract dependency |

## Discovery questions

### Business
- Who owns the workload?
- How critical is it?
- What downtime is acceptable?
- When are peak periods?
- Are there regulatory/contractual constraints?

### Technical
- OS/version?
- CPU/RAM/storage?
- Network and database dependencies?
- Authentication dependencies?
- Backup and monitoring methods?
- External integrations?

## Baseline metrics

Capture CPU, memory, disk, network, latency, request volume, error rate, database size and backup duration before migration.
