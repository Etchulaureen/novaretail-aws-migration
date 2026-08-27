output "vpc_id" { value=aws_vpc.main.id }
output "alb_dns_name" { value=aws_lb.app.dns_name }
output "application_url" { value="http://${aws_lb.app.dns_name}" }
output "rds_endpoint" { value=aws_db_instance.postgres.address }
output "s3_bucket_name" { value=aws_s3_bucket.migration.bucket }
output "app_instance_ids" { value=values(aws_instance.app)[*].id }
