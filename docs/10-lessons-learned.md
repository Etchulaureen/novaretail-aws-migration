# 10 — Lessons Learned and Known Issues

## Purpose

This document captures technical issues, remediation actions, and lessons learned during the NovaRetail AWS migration lab. These findings are intended to improve future migration planning, testing, and operational handover.

## 1. EC2 Bootstrap Failure — AWS CLI Package

### Issue

The initial EC2 bootstrap failed on Ubuntu 24.04 because the expected `awscli` package was not available through the configured APT repositories.

Because the bootstrap script used `set -e`, the package installation failure stopped the remaining user-data process. Docker was therefore not configured and the Flask application was not started.

### Impact

The Application Load Balancer registered both EC2 instances as unhealthy because nothing was listening on the expected application port `8080`.

### Resolution

The bootstrap process was changed to:

- Install Docker, curl, and unzip through APT.
- Download and install AWS CLI v2 using the official AWS CLI installer.
- Retrieve application artifacts from Amazon S3.
- Build the application Docker image.
- Start the Flask container on port `8080`.

Terraform was also configured with `user_data_replace_on_change = true` so changes to bootstrap configuration replace the affected EC2 instances.

### Lesson Learned

Bootstrap dependencies should be validated against the exact operating-system version before migration. User-data changes should also have an explicit replacement/redeployment strategy.

---

## 2. Application Load Balancer Health Checks

### Issue

The ALB initially reported unhealthy targets while the application deployment was incomplete.

### Resolution

The application and load-balancer configuration were aligned around:

- Application port: `8080`
- Health endpoint: `/health`
- Target group health checks against the Flask service

After bootstrap remediation, both EC2 targets reported healthy.

### Lesson Learned

Application listening ports, container configuration, security groups, target groups, and health-check paths must be validated together before cutover.

---

## 3. RDS Snapshot Restore — Subnet Group

### Issue

The first RDS snapshot restore attempt failed because the automatically selected subnet configuration did not provide the required Availability Zone coverage.

### Resolution

The restore operation was repeated using the Terraform-managed NovaRetail database subnet group spanning two Availability Zones.

The restored database subsequently reached `Available` status.

### Lesson Learned

Recovery procedures should explicitly define the target VPC, subnet group, security groups, and other network dependencies instead of relying on service defaults.

---

## 4. Restored RDS Connectivity — Security Group

### Issue

The restored RDS instance was initially associated with a different security group, preventing connectivity from the application tier.

### Resolution

The restored database was associated with the NovaRetail database security group.

Connectivity from an application EC2 instance to the restored PostgreSQL endpoint on TCP port `5432` then passed successfully.

### Lesson Learned

A successful database restore does not automatically prove application connectivity. Network and security controls must be validated as part of recovery testing.

---

## 5. Local Browser Access Anomaly

### Issue

A local browser experienced a timeout when accessing the ALB endpoint even though AWS target health was healthy.

### Validation

Independent tests confirmed:

- ALB state was active.
- Both targets were healthy.
- DNS resolution succeeded.
- HTTP requests using `curl` returned `200 OK`.
- The `/health` endpoint returned a healthy response.
- The automated post-migration validation script passed all checks.

### Lesson Learned

Client-specific failures should be isolated from infrastructure failures by validating the service through multiple independent methods.

---

## 6. Backup and Restore Validation Scope

The migration included a manual Amazon RDS snapshot and restoration into a separate temporary RDS instance.

The test validated:

- Snapshot creation
- Snapshot availability
- RDS instance restoration
- Private subnet placement
- Security-group configuration
- TCP `5432` connectivity from the application tier
- Cleanup of temporary recovery resources

PostgreSQL authentication and row-level data-integrity validation were outside the scope of this lab and were not claimed as completed.

### Lesson Learned

Recovery documentation should clearly distinguish infrastructure restoration, network validation, database authentication, and application/data-level validation.

---

## Known Limitations and Future Improvements

The following improvements would be appropriate for a production implementation:

- Terminate TLS at the ALB using HTTPS `443` and AWS Certificate Manager.
- Redirect HTTP traffic to HTTPS.
- Store database credentials in AWS Secrets Manager or Systems Manager Parameter Store.
- Use least-privilege IAM policies instead of broad administrative permissions.
- Perform PostgreSQL authentication and data-integrity validation after restore.
- Evaluate Multi-AZ RDS for production availability requirements.
- Test CloudWatch alarm notifications and escalation workflows.
- Define formal patch-management and support processes.
- Perform cost optimization and rightsizing after the migration stabilizes.

## Outcome

The troubleshooting process demonstrated that migration success depends on more than successful infrastructure provisioning. Application bootstrap, network segmentation, health checks, recovery dependencies, monitoring, and post-migration validation must all be tested as part of an end-to-end migration process.
