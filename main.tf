provider "aws" {
  region = "ap-south-1"
}


module "network" {
  source = "./modules/network"
}

# # DATA Tier

# resource "aws_security_group" "db_client_sg" {
#   name   = "WP Database Client SG"
#   vpc_id = aws_vpc.ha-web-app.id
# }

# resource "aws_security_group" "db_sg" {
#   name   = "WP Database SG"
#   vpc_id = aws_vpc.ha-web-app.id
# }

# resource "aws_vpc_security_group_ingress_rule" "db_sg" {
#   security_group_id = aws_security_group.db_sg.id

#   ip_protocol                  = "tcp"
#   from_port                    = 3306
#   to_port                      = 3306
#   referenced_security_group_id = aws_security_group.db_client_sg.id
# }

# resource "aws_db_subnet_group" "aurora_wp_sng" {
#   name       = "aurora-wordpress"
#   subnet_ids = [aws_subnet.data-a.id, aws_subnet.data-b.id]
# }

# resource "aws_rds_cluster" "wp_rds" {
#   engine                 = "aurora-mysql"
#   engine_version         = "5.7.mysql_aurora.2.11.4"
#   availability_zones     = ["ap-south-1a", "ap-south-1c"]
#   network_type           = "IPV4"
#   db_subnet_group_name   = aws_db_subnet_group.aurora_wp_sng.name
#   vpc_security_group_ids = [aws_security_group.db_sg.id]
#   port                   = 3306
#   database_name          = "wordpress"
#   cluster_identifier     = "wordpress-workshop"
#   master_username        = "wpadmin"
#   master_password        = "wpadminat123"
#   skip_final_snapshot    = true
# }

# resource "aws_rds_cluster_instance" "ws_rds_cluster_instance" {
#   cluster_identifier   = aws_rds_cluster.wp_rds.id
#   db_subnet_group_name = aws_db_subnet_group.aurora_wp_sng.name
#   engine               = "aurora-mysql"
#   engine_version       = "5.7.mysql_aurora.2.11.4"
#   instance_class       = "db.t3.small"
# }

# resource "aws_rds_cluster_instance" "ws_rds_cluster_instance_reader" {
#   cluster_identifier   = aws_rds_cluster.wp_rds.id
#   db_subnet_group_name = aws_db_subnet_group.aurora_wp_sng.name
#   engine               = "aurora-mysql"
#   engine_version       = "5.7.mysql_aurora.2.11.4"
#   instance_class       = "db.t3.small"
# }

# resource "aws_security_group" "wp_fs_client_sg" {
#   name   = "WP FS Client SG"
#   vpc_id = aws_vpc.ha-web-app.id
# }

# resource "aws_security_group" "wp_fs_sg" {
#   name   = "WP FS SG"
#   vpc_id = aws_vpc.ha-web-app.id
# }

# resource "aws_vpc_security_group_ingress_rule" "wp_fs_sg" {
#   security_group_id = aws_security_group.wp_fs_sg.id

#   ip_protocol                  = "tcp"
#   from_port                    = 2049
#   to_port                      = 2049
#   referenced_security_group_id = aws_security_group.wp_fs_client_sg.id
# }

# resource "aws_efs_file_system" "wp-efs" {
#   throughput_mode = "elastic"

#   lifecycle_policy {
#     transition_to_ia = "AFTER_30_DAYS"
#   }

#   tags = {
#     name = "Wordpress-EFS"
#   }
# }

# resource "aws_efs_mount_target" "app-a-mt" {
#   file_system_id  = aws_efs_file_system.wp-efs.id
#   subnet_id       = aws_subnet.app-a.id
#   security_groups = [aws_security_group.wp_fs_sg.id]
# }

# resource "aws_efs_mount_target" "app-b-mt" {
#   file_system_id  = aws_efs_file_system.wp-efs.id
#   subnet_id       = aws_subnet.app-b.id
#   security_groups = [aws_security_group.wp_fs_sg.id]
# }

# Application Tier

# resource "aws_security_group" "wp_alb_sg" {
#   vpc_id = aws_vpc.ha-web-app.id
#   name   = "WP Load Balancer SG"
# }

# resource "aws_vpc_security_group_ingress_rule" "wp_alb_sg" {
#   security_group_id = aws_security_group.wp_alb_sg.id

#   ip_protocol = "http"
#   from_port   = 80
#   to_port     = 80
#   cidr_ipv4   = "0.0.0.0/0"
# }

# resource "aws_lb_target_group" "wp_tg" {
#   name     = "Wordpress-TargetGroup"
#   port     = 80
#   protocol = "HTTP"
# }

# resource "aws_lb" "wp_alb" {
#   name               = "Wordpress-ALB"
#   ip_address_type    = "ivp4"
#   load_balancer_type = "application"
#   subnets            = [aws_subnet.public-a.id, aws_subnet.public-b.id]
#   security_groups    = [aws_security_group.wp_alb_sg.id]
# }

# resource "aws_lb_listener" "wp_alb_listener" {
#   load_balancer_arn = aws_lb.wp_alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_lb_target_group.wp_tg.arn
#     type             = "forward"
#   }
# }

# resource "aws_security_group" "wp_wordpress_sg" {
#   vpc_id = aws_vpc.ha-web-app.id
#   name   = "WP Wordpress SG"
# }

# resource "aws_vpc_security_group_ingress_rule" "wp_alb_sg" {
#   security_group_id = aws_security_group.wp_wordpress_sg.id

#   ip_protocol                  = "http"
#   from_port                    = 80
#   to_port                      = 80
#   referenced_security_group_id = aws_security_group.wp_alb_sg.id
# }

# resource "aws_launch_template" "wp_lt" {
#   name                   = "Wordpress-LT"
#   image_id               = "ami-0ba259e664698cbf"
#   instance_type          = "t2.small"
#   vpc_security_group_ids = [aws_security_group.wp_wordpress_sg.id, aws_security_group.db_client_sg.id, aws_security_group.wp_fs_client_sg.id]
#   user_data              = filebase64("userdata.sh")
# }

# resource "aws_autoscaling_group" "wp-asg" {
#   name                = "Wordpress-ASG"
#   min_size            = 2
#   max_size            = 4
#   desired_capacity    = 2
#   vpc_zone_identifier = [aws_subnet.app-a.id, aws_subnet.app-b.id]
#   target_group_arns   = [aws_lb_target_group.wp_tg.arn]

#   launch_template {
#     id      = aws_launch_template.wp_lt.id
#     version = "$latest"
#   }
# }
