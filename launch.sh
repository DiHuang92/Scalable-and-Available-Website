#!/bin/bash

#indicate the number of instance to launch. 
#This N should correspond to the value of N in install.sh
N=3
war_file=
S3_BUCKET=
AMI=
Access_Key_ID=
Secret_Access_Key=
region_name=
key_pair=
security_group=
security_group_id=
domain_name=

#Configure aws credentials so that aws account and service can be used
aws configure set aws_access_key_id $Access_Key_ID
aws configure set aws_secret_access_key $Secret_Access_Key 
aws configure set default.region $region_name
aws configure set preview.sdb true

#upload .war and install.sh to s3 for instance to download during installation
aws s3 cp $war_file s3://${S3_BUCKET}/$war_file --grants full=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp install.sh s3://${S3_BUCKET}/install.sh --grants full=uri=http://acs.amazonaws.com/groups/global/AllUsers

#delete the domain, if there were such a domain with the same name before
#create a new domain in simpleDB
aws sdb delete-domain --domain-name $domain_name
aws sdb create-domain --domain-name $domain_name

#launch N instances
aws ec2 run-instances --image-id ${AMI} --count $N --instance-type t2.micro --key-name $key_pair --security-groups $security_group --security-group-ids $security_group_id --user-data file://install.sh
