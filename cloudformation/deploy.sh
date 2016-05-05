#!/bin/bash
set -x

# try curling the endpoint, if it fails we assume that the access policy needs updating
if curl http://search-docker-elk-l36mttokyybzicxf5p23dxb234.us-east-1.es.amazonaws.com | grep 'not authorized' ; then

read -r -d '' POLICY <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "$(curl http://169.254.169.254/latest/meta-data/public-ipv4)"
          ]
        }
      },
      "Resource": ["$ELASTICSEARCH_ARN/*", "$ELASTICSEARCH_ARN/", "$ELASTICSEARCH_ARN"]
    }
  ]
}
EOF

  aws --region "$REGION" es update-elasticsearch-domain-config \
    --domain-name "$ELASTICSEARCH_DOMAIN_NAME" \
    --access-policies "$POLICY"
fi

# sync logstash config bucket
aws --region "$REGION" s3 sync "s3://$S3_BUCKET/" "/opt/docker-elk/logstash/config/"

# bounce docker containers
docker-compose -f docker-compose-production.yml pull
docker-compose -f docker-compose-production.yml build
docker-compose -f docker-compose-production.yml down
docker-compose -f docker-compose-production.yml up -d