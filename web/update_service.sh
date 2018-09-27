#!/bin/bash

PROFILE=lecsum
REGION=ap-southeast-1
CLUSTER=flask-sample-cluster
SERVICE=fs-service

# task stopしないとダメかなぁ？

aws ecs update-service --cluster ${CLUSTER} --service ${SERVICE} --profile ${PROFILE} --region ${REGION} --force-new-deployment
