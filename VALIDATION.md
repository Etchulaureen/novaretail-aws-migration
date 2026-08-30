# NovaRetail AWS Migration - Validation Report

## Terraform Validation

The Terraform configuration was validated locally before deployment.

- `terraform init`: PASS
- `terraform fmt`: PASS
- `terraform validate`: PASS
- `terraform apply`: PASS
- AWS infrastructure deployed successfully in `eu-west-3` (Europe - Paris)

## Application Validation

Post-migration validation was performed against the public Application Load Balancer using:

`python scripts/post_migration_validation.py --url <application-url>`

Results:

- DNS resolution: PASS
- HTTP response: PASS (`200 OK`)
- Application health endpoint `/health`: PASS
- ALB target health: PASS
- Both EC2 application targets reported healthy

## EC2 / Container Validation

The application was deployed as a Docker container on two private EC2 instances.

Validation through AWS Systems Manager confirmed:

- Docker service available: PASS
- `novaretail-app` container running on EC2 instance 1: PASS
- `novaretail-app` container running on EC2 instance 2: PASS
- Flask application listening on port `8080`: PASS
- Local `/health` request from EC2: PASS

## Database Network Validation

Connectivity from the application tier to the private Amazon RDS PostgreSQL instance was tested on TCP port `5432`.

- EC2 application tier -> RDS PostgreSQL port `5432`: PASS

This test validates network reachability and security-group routing to the database tier. It does not validate PostgreSQL authentication or application-level database queries.

## Infrastructure Validation

The deployed architecture was verified to include:

- VPC spanning two Availability Zones
- Public subnets for the Application Load Balancer
- Private application subnets for EC2
- Private database subnets for Amazon RDS
- Internet Gateway and NAT Gateway
- Application Load Balancer
- Two EC2 application instances
- Amazon RDS PostgreSQL
- Amazon S3 migration artifact bucket
- IAM role and instance profile for EC2
- AWS Systems Manager access
- CloudWatch CPU alarms
- Security-group segmentation between ALB, application, and database tiers

## Troubleshooting Performed

During migration validation, the initial EC2 bootstrap failed because the Ubuntu 24.04 package repositories did not provide the expected `awscli` package.

The bootstrap process was corrected to:

1. Install Docker, curl, and unzip.
2. Install AWS CLI v2 using the official AWS CLI installer.
3. Retrieve application artifacts from Amazon S3.
4. Build the Flask application Docker image.
5. Run the container on port `8080`.
6. Configure the ALB target group to use port `8080` and `/health`.
7. Replace EC2 instances when Terraform user data changes.

After remediation, both ALB targets became healthy and external HTTP validation returned `200 OK`.

## Backup and Restore Validation

A manual Amazon RDS snapshot was created from the NovaRetail PostgreSQL database and restored into a separate temporary RDS instance.

Validation performed:

- Manual RDS snapshot creation: PASS
- Snapshot reached `available` state: PASS
- Restore into a separate private RDS instance: PASS
- Restored instance reached `available` state: PASS
- Correct database subnet group applied: PASS
- Database security group applied to restored instance: PASS
- EC2 application tier -> restored RDS port `5432`: PASS

The initial restore connectivity test failed because the restored instance was attached to a different security group. After applying the original database security group, connectivity from the application tier to the restored database succeeded.

This validates the RDS snapshot and infrastructure recovery process. PostgreSQL authentication and application-level data validation were not performed.
- Temporary restored RDS instance and manual recovery-test snapshot removed after validation: PASS

## Overall Result

**Migration validation: PASS**

The NovaRetail lab environment successfully demonstrated infrastructure provisioning, application migration, troubleshooting, load-balanced application delivery, private-tier network segmentation, and post-migration validation.

