
#suppose instance has already been connected

S3_BUCKET=

#supply aws credentials
Access_Key_ID=
Secret_Access_Key=
region_name=

aws configure set aws_access_key_id $Access_Key_ID
aws configure set aws_secret_access_key $Secret_Access_Key 
aws configure set default.region $region_name

#get the installation script
aws s3 cp s3://${S3_BUCKET}/install.sh install.sh

#re_run the installation script
chmod +x *.sh
./install.sh