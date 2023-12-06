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

yum install nginx -y &>> $LOGFILE

VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "Enabling nginx"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "Delete default html files of nginx"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "Copy web.zip"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "Navigate to nginx html directory"

unzip /tmp/web.zip &>> $LOGFILE

VALIDATE $? "Unzip web files"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "Restarting nginx"


