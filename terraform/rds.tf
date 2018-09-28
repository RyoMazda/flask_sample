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

resource "aws_rds_cluster_parameter_group" "rds_cluster_pg" {
  name        = "fs-rds-cluster-pg"
  family      = "aurora-mysql5.7"
  description = "flask sample RDS cluster parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_connection"
    value = "utf8mb4_general_ci"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_general_ci"
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }

  tags {
    "Name"    = "flask-sample-db-cluster-pg"
  }
}

resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier           = "fs-db-cluster"
  engine                       = "aurora-mysql"  // Aurora (MySQL 5.7)
  database_name                = "${var.db_name}"
  master_username              = "${var.rds_master_username}"
  master_password              = "${var.rds_master_password}"
  backup_retention_period      = 14
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "wed:03:00-wed:04:00"
  db_subnet_group_name         = "${aws_db_subnet_group.db_subnet_group.name}"
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.rds_cluster_pg.id}"
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
