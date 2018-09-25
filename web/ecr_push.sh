#!/bin/bash

aws ecr describe-repositories --profile lecsum --region ap-northeast-2
aws ecr get-login --no-include-email --profile lecsum --region ap-northeast-2 | sh
docker build -t flask_sample .
docker tag flask_sample:latest 431120073761.dkr.ecr.ap-northeast-2.amazonaws.com/flask_sample:latest
docker push 431120073761.dkr.ecr.ap-northeast-2.amazonaws.com/flask_sample:latest
aws ecr describe-repositories --profile lecsum --region ap-northeast-2
