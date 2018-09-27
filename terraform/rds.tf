resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "db_subnet_group"
  description = "Allowed subnets for RDS cluster instances"

  subnet_ids = [
    "${aws_subnet.private-1.id}",
    "${aws_subnet.private-2.id}",
  ]

  tags {
    Name = "tf-test"
  }
}

resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier           = "fs-db-cluster"
  engine                       = "aurora-mysql"
  database_name                = "${var.db_name}"
  master_username              = "${var.rds_master_username}"
  master_password              = "${var.rds_master_password}"
  backup_retention_period      = 14
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "wed:03:00-wed:04:00"
  db_subnet_group_name         = "${aws_db_subnet_group.db_subnet_group.name}"
  final_snapshot_identifier    = "fs-db-cluster-snapshot"

  vpc_security_group_ids = ["${aws_security_group.rds-sg.id}"]

  tags {
    Name = "tf-test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_instance" "db_instance" {
  count                = "${var.db_instance_count}"
  engine               = "aurora-mysql"
  identifier           = "db-instance-${count.index}"
  cluster_identifier   = "${aws_rds_cluster.db_cluster.id}"
  instance_class       = "${var.db_instance_type}"
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet_group.name}"
  publicly_accessible  = false

  tags {
    Name = "tf-test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "db_cluster_endpoint" {
  value = "${aws_rds_cluster.db_cluster.endpoint}"
}

output "db_instance_endpoint" {
  value = "${aws_rds_cluster_instance.db_instance.*.endpoint}"
}
