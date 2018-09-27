# ----------
# ECR
# ----------
resource "aws_ecr_repository" "flask-sample" {
  name = "practice2018/flask-sample"
}

output "ecr-repository-URL" {
  value = "${aws_ecr_repository.flask-sample.repository_url}"
}

# ----------
# Key for ssh
# ----------
resource "aws_key_pair" "ecs-key" {
  key_name   = "ecs-key"
  public_key = "${file("${var.path_to_public_key}")}"

  lifecycle {
    ignore_changes = ["public_key"]
  }
}

# ----------
# Cluster
# ----------
resource "aws_ecs_cluster" "flask-sample-cluster" {
  name = "flask-sample-cluster"
}

# Auto Scaling for ECS cluster
resource "aws_launch_configuration" "ecs-launchconfig" {
  name_prefix          = "ecs-launchconfig"
  image_id             = "${lookup(var.ecs_image_id, var.AWS_REGION)}"
  instance_type        = "${var.ecs_instance_type}"
  key_name             = "${aws_key_pair.ecs-key.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-ec2-role.id}"
  security_groups      = ["${aws_security_group.ecs-ec2-instance-sg.id}"]
  user_data            = "#!/bin/bash\necho 'ECS_CLUSTER=${aws_ecs_cluster.flask-sample-cluster.name}' > /etc/ecs/ecs.config\nstart ecs"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs-fs-autoscaling" {
  name                 = "ecs-fs-autoscaling"
  vpc_zone_identifier  = ["${aws_subnet.public.id}"]
  launch_configuration = "${aws_launch_configuration.ecs-launchconfig.name}"
  min_size             = 1
  max_size             = 1

  tag {
    key                 = "Name"
    value               = "ec2-by-ecs-autoscaling"
    propagate_at_launch = true
  }
}

# ----------
# Task Definision
# ----------
data "template_file" "fs-container-definition-template" {
  template = "${file("templates/container_definition.json")}"

  vars {
    REPOSITORY_URL = "${replace("${aws_ecr_repository.flask-sample.repository_url}", "https://", "")}"
    container_name = "${var.container_name}"
    DB_HOST        = "mysql://${var.rds_master_username}:${var.rds_master_password}@${aws_rds_cluster.db_cluster.endpoint}:3306/${var.db_name}?charset=utf8"
  }
}

resource "aws_ecs_task_definition" "fs-task-definition" {
  family                = "fs-task-definition"
  container_definitions = "${data.template_file.fs-container-definition-template.rendered}"
}

# ----------
# Service
# ----------
# without ELB
resource "aws_ecs_service" "fs-service" {
  name            = "fs-service"
  cluster         = "${aws_ecs_cluster.flask-sample-cluster.id}"
  task_definition = "${aws_ecs_task_definition.fs-task-definition.arn}"
  desired_count   = 1
}

# with ELB version
/*
resource "aws_ecs_service" "fs-service" {
  name            = "fs-service"
  cluster         = "${aws_ecs_cluster.flask-sample-cluster.id}"
  task_definition = "${aws_ecs_task_definition.fs-task-definition.arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.ecs-service-role.arn}"
  depends_on      = ["aws_iam_policy_attachment.ecs-service-attach1"]

  load_balancer {
    elb_name       = "${aws_elb.fs-elb.name}"
    container_name = "${var.container_name}"
    container_port = 5000
  }

  lifecycle {
    ignore_changes = ["task_definition"]
  }
}

# ----------
# ELB
# ----------
# ecs service role for ELB
/*
resource "aws_iam_role" "ecs-service-role" {
  name = "ecs-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs-service-attach1" {
  name       = "ecs-service-attach1"
  roles      = ["${aws_iam_role.ecs-service-role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_elb" "fs-elb" {
  name = "fs-elb"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    target              = "HTTP:80/"
    interval            = 60
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  subnets         = ["${aws_subnet.public.id}"]
  security_groups = ["${aws_security_group.elb-sg.id}"]

  tags {
    Name = "fs-elb"
  }
}

output "elb-dns-name" {
  value = "${aws_elb.fs-elb.dns_name}"
}
*/

