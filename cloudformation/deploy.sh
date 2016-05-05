#!/bin/bash
set -x

# sync logstash config bucket
aws --region "$REGION" s3 sync "s3://$S3_BUCKET/" "/opt/docker-elk/logstash/config/"

# bounce docker containers
docker-compose -f docker-compose-production.yml pull
docker-compose -f docker-compose-production.yml down
docker-compose -f docker-compose-production.yml up --build -d