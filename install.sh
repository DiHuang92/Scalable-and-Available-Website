#!/bin/bash

#user can define the value of N and F as long as N>=2*F+1
#This N should correspond to the value of N in launch.sh
N=3
F=1
war_file=
S3_BUCKET=
Access_Key_ID=
Secret_Access_Key=
region_name=
domain_name=
attribute_name=

#Configure aws credentials so that aws account and service can be used
aws configure set aws_access_key_id $Access_Key_ID
aws configure set aws_secret_access_key $Secret_Access_Key 
aws configure set default.region $region_name
aws configure set preview.sdb true

#Change the java version installed on instance from java7 to java8
#Install Tomcat8 
sudo yum -y remove java-1.7.0-openjdk
sudo yum -y install java-1.8.0 
sudo yum -y install tomcat8-webapps tomcat8-docs-webapp tomcat8-admin-webapps

#copy the .war from s3 to tomcat server if the .war file does not exist
sudo chmod 777 /usr/share/tomcat8/webapps
if [ -e /usr/share/tomcat8/webapps/$war_file ]
    then :
else
    aws s3 cp s3://${S3_BUCKET}/$war_file /usr/share/tomcat8/webapps/$war_file 
fi

#If there is not a file indicating N and F, save N (number of launched instances) 
#and F (fault-tolerance) to a file so that they can be read by Java codes and set variables correspondingly
if [ -e /NF_info.txt ]
    then :
else
    echo -e "$N\n$F" > NF_info.txt
    sudo chmod 777 /NF_info.txt  
fi                 

#If there is not a file indicating this instance’s ServerID and IP, 
#save this instance’s ServerID and IP to a file and upload that file to simpleDB
if [ -e /server_info.txt ]
    then :
else
    IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
    item=$(curl http://169.254.169.254/latest/meta-data/ami-launch-index)
    item_name=$domain_name-$item-$attribute_name
    aws sdb put-attributes --domain-name $domain_name --item-name $item_name --attributes Name=$attribute_name,Value=$IP
    echo -e "$item\n-1" > server_info.txt
    sudo chmod 777 /server_info.txt  
fi

#If there is not a file indicating all of instances’ IPs, wait until all instances’ IPs have 
#been uploaded to simpleDB.
#download the whole IP information from simpleDB, and save it in a file. 
if [ -e /server_mapping.txt ]
    then :
else
    item_num=$(aws sdb select --select-expression "select count(*) from mydomain" --output text | grep -o '[0-9].*')
    while [ $item_num -ne $N ]; do
	    sleep 15
        item_num=$(aws sdb select --select-expression "select count(*) from mydomain" --output text | grep -o '[0-9].*')
    done
    all_info=$(aws sdb select --select-expression "select * from mydomain" --output text)
    echo "$all_info" > server_mapping.txt 
    sudo chmod 777 /server_mapping.txt
fi

#Start tomcat server.
sudo service tomcat8 start