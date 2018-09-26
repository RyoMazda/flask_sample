output "ecr-repository-URL" {
  value = "${aws_ecr_repository.flask-sample.repository_url}"
}
