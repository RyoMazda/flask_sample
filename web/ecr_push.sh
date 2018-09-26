#!/bin/bash

PROFILE=lecsum
REGION=ap-southeast-1
IMAGE_TAG=431120073761.dkr.ecr.ap-southeast-1.amazonaws.com/practice2018/flask-sample

aws ecr describe-repositories --profile ${PROFILE} --region ${REGION}
aws ecr get-login --no-include-email --profile ${PROFILE} --region ${REGION} | sh
docker build -t ${IMAGE_TAG} .
docker push ${IMAGE_TAG}
aws ecr describe-repositories --profile ${PROFILE} --region ${REGION}
