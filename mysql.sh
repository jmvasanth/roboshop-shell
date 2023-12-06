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

yum module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disable default mysql version"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Edit mysql.repo to point to mysql 5.7"

yum install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Install mysql community server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling mysql" &>> $LOGFILE

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting mysql" &>> $LOGFILE

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "Set mysql root passwd"

mysql -uroot -pRoboShop@1 &>> $LOGFILE

VALIDATE $? "Verify mysql root login"