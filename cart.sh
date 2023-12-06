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

sh nsolid_setup_rpm.sh 18

VALIDATE $? "Setup NodeJS"

yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1

# yum install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS"

useradd roboshop &>> $LOGFILE

VALIDATE $? "Add user roboshop"

mkdir /app &>> $LOGFILE

VALIDATE $? "Create app dir"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Artifact download"

cd /app &>> $LOGFILE

VALIDATE $? "Navigate to app dir"

unzip /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "Unzipping cart"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "Copying cart.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reload"

systemctl enable cart

VALIDATE $? "Enabling cart service"

systemctl start cart

VALIDATE $? "Starting cart Service"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying MongoDB repo"

yum install mongodb-org-shell -y

VALIDATE $? "Installing MongoDB shell"

mongo --host mongodb.vgsk.online </app/schema/cart.js

VALIDATE $? "Loading MongoDB schema"
