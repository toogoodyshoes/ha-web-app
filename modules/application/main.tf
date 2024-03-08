# Network Module
module "network" {
  source = "../network"
}

# Data Module
module "data" {
  source = "../data"
}

# Application Load Balancer
resource "aws_security_group" "wp_alb_sg" {
  vpc_id = module.network.wp_vpc.id
  name   = "WP Load Balancer SG"
}

resource "aws_vpc_security_group_ingress_rule" "wp_alb_sg" {
  security_group_id = aws_security_group.wp_alb_sg.id

  ip_protocol = "http"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_lb_target_group" "wp_tg" {
  name     = "Wordpress-TargetGroup"
  port     = 80
  protocol = "HTTP"
}

resource "aws_lb" "wp_alb" {
  name               = "Wordpress-ALB"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  subnets = [
    module.network.zone_a_subnets[var.public_subnet_a_index].id,
    module.network.zone_b_subnets[var.public_subnet_b_index].id
  ]
  security_groups = [aws_security_group.wp_alb_sg.id]
}

resource "aws_lb_listener" "wp_alb_listener" {
  load_balancer_arn = aws_lb.wp_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.wp_tg.arn
    type             = "forward"
  }
}

resource "aws_security_group" "wp_wordpress_sg" {
  vpc_id = module.network.wp_vpc.id
  name   = "WP Wordpress SG"
}

resource "aws_vpc_security_group_ingress_rule" "wordpress_sg" {
  security_group_id = aws_security_group.wp_wordpress_sg.id

  ip_protocol                  = "http"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.wp_alb_sg.id
}

# Auto Scaling Group
resource "aws_launch_template" "wp_lt" {
  name          = "Wordpress-LT"
  image_id      = "ami-0ba259e664698cbf"
  instance_type = "t2.small"
  vpc_security_group_ids = [
    aws_security_group.wp_wordpress_sg.id,
    module.data.db_client_sg,
    module.data.wp_fs_client_sg.id
  ]
  user_data = filebase64("./modules/application/userdata.sh")
}

resource "aws_autoscaling_group" "wp-asg" {
  name             = "Wordpress-ASG"
  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  vpc_zone_identifier = [
    module.network.zone_a_subnets[var.application_subnet_a_index].id,
    module.network.zone_b_subnets[var.application_subnet_b_index].id
  ]
  target_group_arns = [aws_lb_target_group.wp_tg.arn]

  launch_template {
    id      = aws_launch_template.wp_lt.id
    version = "$latest"
  }
}
