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

yum install maven -y &>> $LOGFILE

VALIDATE $? "Installing Maven"

useradd roboshop &>> $LOGFILE

VALIDATE $? "Add user roboshop"

mkdir /app &>> $LOGFILE

VALIDATE $? "mkdir app"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Download shipping.zip"

cd /app &>> $LOGFILE

VALIDATE $? "Navigate to app dir"

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzip shipping.zip"

cd /app &>> $LOGFILE

VALIDATE $? "Navigate to app dir"

mvn clean package &>> $LOGFILE

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "Move Shipping JAR"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Create Shipping Service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon Reload"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "Enable Shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Start Shipping"

yum install mysql -y &>> $LOGFILE

VALIDATE $? "Install mysql"

mysql -h mysql.vgsk.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Load the schema to mysql DB"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restart Shipping"
