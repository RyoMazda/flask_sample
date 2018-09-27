resource "aws_ecr_repository" "flask-sample" {
  name = "practice2018/flask-sample"
}

output "ecr-repository-URL" {
  value = "${aws_ecr_repository.flask-sample.repository_url}"
}
