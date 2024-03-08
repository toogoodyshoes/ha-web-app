module "network" {
  source = "../network"
}


# Aurora Cluster Security Group
resource "aws_security_group" "db_client_sg" {
  name   = "WP Databse Client SG"
  vpc_id = module.network.wp_vpc.id
}

resource "aws_security_group" "db_sg" {
  name   = "WP Database SG"
  vpc_id = module.network.wp_vpc.id
}

resource "aws_vpc_security_group_egress_rule" "db_sg" {
  security_group_id = aws_security_group.db_sg.id

  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.db_client_sg.id
}

# Aurora Cluster
resource "aws_db_subnet_group" "aurora_wp_sng" {
  name = "aurora-wordpress"
  subnet_ids = [
    module.network.zone_a_subnets[var.data_subnet_a_index].id,
    module.network.zone_b_subnets[var.data_subnet_b_index].id
  ]
}

resource "aws_rds_cluster" "wp_aurora_rds" {
  engine                 = "aurora-mysql"
  engine_version         = "5.7.mysql_aurora.2.11.4"
  availability_zones     = ["ap-south-1a", "ap-south-1c"]
  network_type           = "IPV4"
  db_subnet_group_name   = aws_db_subnet_group.aurora_wp_sng.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  port                   = 3306
  database_name          = "wordpress"
  cluster_identifier     = "wordpress-workshop"
  master_username        = "wpadmin"
  master_password        = "wpadminat123"
  skip_final_snapshot    = true
}

resource "aws_rds_cluster_instance" "wp_rds_cluster_instance" {
  cluster_identifier   = aws_rds_cluster.wp_aurora_rds.id
  db_subnet_group_name = aws_db_subnet_group.aurora_wp_sng.name
  engine               = "aurora-mysql"
  engine_version       = "5.7.mysql_aurora.2.11.4"
  instance_class       = "db.t3.small"
}

resource "aws_rds_cluster_instance" "ws_rds_cluster_instance_reader" {
  cluster_identifier   = aws_rds_cluster.wp_aurora_rds.id
  db_subnet_group_name = aws_db_subnet_group.aurora_wp_sng.name
  engine               = "aurora-mysql"
  engine_version       = "5.7.mysql_aurora.2.11.4"
  instance_class       = "db.t3.small"
}

# EFS Cluster
resource "aws_security_group" "wp_fs_client_sg" {
  name   = "WP File Server Client SG"
  vpc_id = module.network.wp_vpc.id
}

resource "aws_security_group" "wp_fs_sg" {
  name   = "WP File Server SG"
  vpc_id = module.network.wp_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "wp_fs_sg" {
  security_group_id = aws_security_group.wp_fs_sg.id

  ip_protocol                  = "tcp"
  from_port                    = 2049
  to_port                      = 2049
  referenced_security_group_id = aws_security_group.wp_fs_client_sg.id
}

resource "aws_efs_file_system" "wp_efs" {
  throughput_mode = "elastic"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    name = "Wordpress-EFS"
  }
}

resource "aws_efs_mount_target" "app-a-mt" {
  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = module.network.zone_a_subnets[var.application_subnet_a_index].id
  security_groups = [aws_security_group.wp_fs_sg.id]
}

resource "aws_efs_mount_target" "app-b-mt" {
  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = module.network.zone_b_subnets[var.application_subnet_b_index].id
  security_groups = [aws_security_group.wp_fs_sg.id]
}
