# ----------
# ELB
# ----------
//resource "aws_elb" "fs-elb" {
//  name = "fs-elb"
//
//  listener {
//    instance_port     = 80
//    instance_protocol = "http"
//    lb_port           = 80
//    lb_protocol       = "http"
//  }
//
//  health_check {
//    healthy_threshold   = 3
//    unhealthy_threshold = 3
//    timeout             = 30
//    target              = "HTTP:80/"
//    interval            = 60
//  }
//
//  cross_zone_load_balancing   = true
//  idle_timeout                = 400
//  connection_draining         = true
//  connection_draining_timeout = 400
//
//  subnets         = ["${aws_subnet.public.id}"]
//  security_groups = ["${aws_security_group.elb-sg.id}"]
//
//  tags {
//    Name = "fs-elb"
//  }
//}
//
//output "elb-dns-name" {
//  value = "${aws_elb.fs-elb.dns_name}"
//}

