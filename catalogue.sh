#! /bin/bash

DATE=$(date +%F)
LOGSDIR=/home/centos/shellscript-logs
#/home/centos/shellscript-logs/scriptname-date.log

SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR: Please execute this script with root access $N"
    exit 1
fi 

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi 
}


#curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE

curl -SLO https://rpm.nodesource.com/nsolid_setup_rpm.sh

chmod 500 nsolid_setup_rpm.sh

sh nsolid_setup_rpm.sh 21

VALIDATE $? "Setup NodeJS"

yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1

# yum install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS"

useradd roboshop &>> $LOGFILE

VALIDATE $? "Add user roboshop"

mkdir /app &>> $LOGFILE

VALIDATE $? "Create app dir"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Artifact download"

cd /app &>> $LOGFILE

VALIDATE $? "Navigate to app dir"

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping catalogue"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Copying catalogue.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reload"

systemctl enable catalogue

VALIDATE $? "Enabling Catalogue service"

systemctl start catalogue

VALIDATE $? "Starting Catalogue Service"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying MongoDB repo"

yum install mongodb-org-shell -y

VALIDATE $? "Installing MongoDB shell"

mongo --host mongodb.vgsk.online </app/schema/catalogue.js

VALIDATE $? "Loading MongoDB schema"
