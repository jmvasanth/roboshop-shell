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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "Installing redis remi repo"

yum module enable redis:remi-6.2 -y &>> $LOGFILE

VALIDATE $? "Enabling redis repo"

yum install redis -y &>> $LOGFILE

VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>> $LOGFILE

VALIDATE $? "Editing redis config"

systemctl enable redis &>> $LOGFILE

VALIDATE $? "Enabling redis"

systemctl start redis &>> $LOGFILE

VALIDATE $? "Starting redis"