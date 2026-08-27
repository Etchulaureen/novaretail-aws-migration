data "aws_availability_zones" "available" { state="available" }
data "aws_ami" "ubuntu" {
  most_recent=true
  owners=["099720109477"]
  filter { name="name"; values=["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"] }
  filter { name="virtualization-type"; values=["hvm"] }
}

locals {
  azs=slice(data.aws_availability_zones.available.names,0,2)
  public_subnets={ az1={cidr="10.20.1.0/24",az=local.azs[0]}, az2={cidr="10.20.2.0/24",az=local.azs[1]} }
  app_subnets={ az1={cidr="10.20.11.0/24",az=local.azs[0]}, az2={cidr="10.20.12.0/24",az=local.azs[1]} }
  db_subnets={ az1={cidr="10.20.21.0/24",az=local.azs[0]}, az2={cidr="10.20.22.0/24",az=local.azs[1]} }
}

resource "aws_vpc" "main" { cidr_block=var.vpc_cidr; enable_dns_support=true; enable_dns_hostnames=true; tags={Name="${var.project_name}-vpc"} }
resource "aws_internet_gateway" "main" { vpc_id=aws_vpc.main.id; tags={Name="${var.project_name}-igw"} }
resource "aws_subnet" "public" { for_each=local.public_subnets; vpc_id=aws_vpc.main.id; cidr_block=each.value.cidr; availability_zone=each.value.az; map_public_ip_on_launch=true; tags={Name="${var.project_name}-public-${each.key}",Tier="public"} }
resource "aws_subnet" "app" { for_each=local.app_subnets; vpc_id=aws_vpc.main.id; cidr_block=each.value.cidr; availability_zone=each.value.az; tags={Name="${var.project_name}-app-${each.key}",Tier="application"} }
resource "aws_subnet" "db" { for_each=local.db_subnets; vpc_id=aws_vpc.main.id; cidr_block=each.value.cidr; availability_zone=each.value.az; tags={Name="${var.project_name}-db-${each.key}",Tier="database"} }
resource "aws_route_table" "public" { vpc_id=aws_vpc.main.id; route { cidr_block="0.0.0.0/0"; gateway_id=aws_internet_gateway.main.id }; tags={Name="${var.project_name}-public-rt"} }
resource "aws_route_table_association" "public" { for_each=aws_subnet.public; subnet_id=each.value.id; route_table_id=aws_route_table.public.id }
resource "aws_eip" "nat" { count=var.enable_nat_gateway ? 1 : 0; domain="vpc"; tags={Name="${var.project_name}-nat-eip"} }
resource "aws_nat_gateway" "main" { count=var.enable_nat_gateway ? 1 : 0; allocation_id=aws_eip.nat[0].id; subnet_id=aws_subnet.public["az1"].id; depends_on=[aws_internet_gateway.main]; tags={Name="${var.project_name}-nat"} }
resource "aws_route_table" "app" {
  vpc_id=aws_vpc.main.id
  dynamic "route" { for_each=var.enable_nat_gateway ? [1] : []; content { cidr_block="0.0.0.0/0"; nat_gateway_id=aws_nat_gateway.main[0].id } }
  tags={Name="${var.project_name}-app-rt"}
}
resource "aws_route_table_association" "app" { for_each=aws_subnet.app; subnet_id=each.value.id; route_table_id=aws_route_table.app.id }
resource "aws_route_table" "db" { vpc_id=aws_vpc.main.id; tags={Name="${var.project_name}-db-rt"} }
resource "aws_route_table_association" "db" { for_each=aws_subnet.db; subnet_id=each.value.id; route_table_id=aws_route_table.db.id }

resource "aws_security_group" "alb" {
  name="${var.project_name}-alb-sg"; description="Allow HTTP from internet"; vpc_id=aws_vpc.main.id
  ingress { description="HTTP"; from_port=80; to_port=80; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}
resource "aws_security_group" "app" {
  name="${var.project_name}-app-sg"; description="Allow HTTP from ALB"; vpc_id=aws_vpc.main.id
  ingress { from_port=80; to_port=80; protocol="tcp"; security_groups=[aws_security_group.alb.id] }
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}
resource "aws_security_group" "db" {
  name="${var.project_name}-db-sg"; description="Allow PostgreSQL from app"; vpc_id=aws_vpc.main.id
  ingress { from_port=5432; to_port=5432; protocol="tcp"; security_groups=[aws_security_group.app.id] }
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_iam_role" "ec2" {
  name="${var.project_name}-ec2-role"
  assume_role_policy=jsonencode({Version="2012-10-17",Statement=[{Effect="Allow",Principal={Service="ec2.amazonaws.com"},Action="sts:AssumeRole"}]})
}
resource "aws_iam_role_policy_attachment" "ssm" { role=aws_iam_role.ec2.name; policy_arn="arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" }
resource "aws_iam_instance_profile" "ec2" { name="${var.project_name}-ec2-profile"; role=aws_iam_role.ec2.name }

resource "aws_s3_bucket" "migration" { bucket_prefix="${var.project_name}-artifacts-"; tags={Name="${var.project_name}-artifacts"} }
resource "aws_s3_bucket_versioning" "migration" { bucket=aws_s3_bucket.migration.id; versioning_configuration { status="Enabled" } }
resource "aws_s3_bucket_public_access_block" "migration" { bucket=aws_s3_bucket.migration.id; block_public_acls=true; block_public_policy=true; ignore_public_acls=true; restrict_public_buckets=true }
resource "aws_iam_role_policy" "s3_access" {
  name="${var.project_name}-s3-policy"; role=aws_iam_role.ec2.id
  policy=jsonencode({Version="2012-10-17",Statement=[{Effect="Allow",Action=["s3:GetObject","s3:PutObject","s3:ListBucket"],Resource=[aws_s3_bucket.migration.arn,"${aws_s3_bucket.migration.arn}/*"]}]})
}

resource "aws_lb" "app" { name=substr(replace("${var.project_name}-alb","_","-"),0,32); internal=false; load_balancer_type="application"; security_groups=[aws_security_group.alb.id]; subnets=values(aws_subnet.public)[*].id }
resource "aws_lb_target_group" "app" {
  name=substr(replace("${var.project_name}-tg","_","-"),0,32); port=80; protocol="HTTP"; vpc_id=aws_vpc.main.id
  health_check { path="/"; healthy_threshold=2; unhealthy_threshold=3; timeout=5; interval=30; matcher="200" }
}
resource "aws_lb_listener" "http" { load_balancer_arn=aws_lb.app.arn; port=80; protocol="HTTP"; default_action { type="forward"; target_group_arn=aws_lb_target_group.app.arn } }

resource "aws_instance" "app" {
  for_each=aws_subnet.app
  ami=data.aws_ami.ubuntu.id
  instance_type=var.instance_type
  subnet_id=each.value.id
  vpc_security_group_ids=[aws_security_group.app.id]
  iam_instance_profile=aws_iam_instance_profile.ec2.name
  associate_public_ip_address=false
  user_data=templatefile("${path.module}/user_data.sh",{project_name=var.project_name})
  metadata_options { http_endpoint="enabled"; http_tokens="required" }
  root_block_device { encrypted=true; volume_size=12; volume_type="gp3" }
  tags={Name="${var.project_name}-app-${each.key}"}
  depends_on=[aws_nat_gateway.main]
}
resource "aws_lb_target_group_attachment" "app" { for_each=aws_instance.app; target_group_arn=aws_lb_target_group.app.arn; target_id=each.value.id; port=80 }

resource "aws_db_subnet_group" "main" { name="${var.project_name}-db-subnets"; subnet_ids=values(aws_subnet.db)[*].id }
resource "aws_db_instance" "postgres" {
  identifier=substr(replace("${var.project_name}-postgres","_","-"),0,63)
  engine="postgres"; engine_version="16"; instance_class=var.db_instance_class
  allocated_storage=20; max_allocated_storage=50; storage_type="gp3"; storage_encrypted=true
  db_name="novaretail"; username=var.db_username; password=var.db_password
  db_subnet_group_name=aws_db_subnet_group.main.name; vpc_security_group_ids=[aws_security_group.db.id]
  publicly_accessible=false; skip_final_snapshot=true; deletion_protection=false; backup_retention_period=1
  tags={Name="${var.project_name}-postgres"}
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  for_each=aws_instance.app; alarm_name="${var.project_name}-${each.key}-high-cpu"; comparison_operator="GreaterThanThreshold"; evaluation_periods=2
  metric_name="CPUUtilization"; namespace="AWS/EC2"; period=300; statistic="Average"; threshold=80
  dimensions={InstanceId=each.value.id}
}
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name="${var.project_name}-rds-high-cpu"; comparison_operator="GreaterThanThreshold"; evaluation_periods=2
  metric_name="CPUUtilization"; namespace="AWS/RDS"; period=300; statistic="Average"; threshold=80
  dimensions={DBInstanceIdentifier=aws_db_instance.postgres.id}
}
