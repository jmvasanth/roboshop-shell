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

yum install golang -y &>> $LOGFILE

useradd roboshop &>> $LOGFILE

VALIDATE $? "Create roboshop user"

mkdir /app &>> $LOGFILE

VALIDATE $? "Create directory app"

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE

VALIDATE $? "Downloading Artifact"

cd /app &>> $LOGFILE

VALIDATE $? "Navigating to dir /app"

unzip /tmp/dispatch.zip &>> $LOGFILE

VALIDATE $? "Unzip dispatch.zip"

cd /app &>> $LOGFILE

VALIDATE $? "Navigating to dir /app"

go mod init dispatch &>> $LOGFILE

go get &>> $LOGFILE

go build &>> $LOGFILE

VALIDATE $? "Download dependencies & build the software"

cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE

VALIDATE $? "Copying dispatch service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reload"

systemctl enable dispatch &>> $LOGFILE

VALIDATE $? "Enabling dispatch"

systemctl start dispatch &>> $LOGFILE

VALIDATE $? "Starting dispatch"