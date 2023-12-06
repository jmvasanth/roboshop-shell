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

yum install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing Python 3.6"

useradd roboshop &>> $LOGFILE

VALIDATE $? "Create roboshop user"

mkdir /app &>> $LOGFILE

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Download Artifact"

cd /app &>> $LOGFILE

VALIDATE $? "Moving to app dir"

unzip /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Unzipping payment"

cd /app &>> $LOGFILE

VALIDATE $? "Moving to app dir"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "Copying payment service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "Enabling payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "Starting payment"