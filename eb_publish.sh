#!/bin/bash

# usage:  -c ./deploy.sh ${EB_APP_NAME} ${GO_PIPELINE_LABEL} ${S3_BUCKET} ${AWS_ACCOUNT_ID} ${NODE_ENV} ${PORT} ${BRANCH} ${NEWRELIC_KEY} ${PROXY_URL}

EB_APP_NAME=$1
SHA1=$2
EB_BUCKET=$3
AWS_ACCOUNT_ID=$4
NODE_ENV=$5
PORT=$6
BRANCH=$7
#NEWRELIC_KEY=$8
#PROXY_URL=$9

VERSION=$EB_APP_NAME-$SHA1
ZIP=$VERSION.zip

existing_app=`aws elasticbeanstalk describe-application-versions --application-name "$EB_APP_NAME" --version-label "$VERSION" --query "ApplicationVersions[*].VersionLabel" --output text`
if [ "$existing_app" != "$VERSION" ]; then
	sed -i "s/<NAME>/$EB_APP_NAME/" Dockerrun.aws.json
	#sed -i "s/<PORT>/$PORT/" Dockerrun.aws.json
	sed -i "s/<TAG>/$SHA1/" Dockerrun.aws.json
	#sed -i "s,<PROXY_URL>,$PROXY_URL," .ebextensions/newrelic.config
	#sed -i "s/<NR_LICENSE_KEY>/$NEWRELIC_KEY/" .ebextensions/newrelic.config
	#sed -i "s/<NAME>/$EB_APP_NAME/" .ebextensions/newrelic.config
	
	cp Dockerrun.aws.json template.Dockerrun

	sed -i "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/" Dockerrun.aws.json

	zip -r $ZIP Dockerrun.aws.json template.Dockerrun .ebextensions/*

	aws s3 cp $ZIP s3://$EB_BUCKET/$ZIP

	# Create a new application version with the zipped up Dockerrun file
	aws elasticbeanstalk create-application-version --application-name $EB_APP_NAME \
	    --version-label $VERSION --description "Automated build ($BRANCH)" --source-bundle S3Bucket=$EB_BUCKET,S3Key=$ZIP
fi
