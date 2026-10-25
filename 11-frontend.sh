#!/bin/bash

source ./common.sh
check_root


dnf module disable nginx -y &>>$logs_file
dnf module enable nginx:1.26 -y &>>$logs_file
dnf install nginx -y &>>$logs_file
validate $? "Installing nginx"

systemctl enable nginx &>>$logs_file
systemctl start nginx &>>$logs_file
validate $? "Enable and start nginx"

rm -rf /usr/share/nginx/html/* &>>$logs_file
validate $? "Removing default nginx content"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>>$logs_file
cd /usr/share/nginx/html &>> $logs_file
unzip /tmp/frontend.zip &>> $logs_file
validate $? "Downloading and unzipping frontend code"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/roboshop.conf"
cp "$scripts_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf
validate $? "Copied roboshop config"

nginx -t &>> $logs_file
validate $? "Nginx Configuration"

systemctl restart nginx
validate $? "Restarting nginx"


# 1. Check Service Status
echo -e "\n${Y}--- Nginx Service Status ---${N}"
systemctl status nginx --no-pager

# Give the app a few seconds to start up before curling
echo -e "\n${Y}--- Waiting 5 seconds for application to start... ---${N}"
sleep 5

# 2. Health Check Endpoint
echo -e "\n${Y}--- Health Check (http://localhost/health) ---${N}"

# Get only the HTTP status code and silence the rest of the output
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health)

if [ "$STATUS_CODE" -eq 200 ]; then
    echo -e "${G}SUCCESS${N}: Nginx service is running (Status Code: ${G}200${N})"
else
    echo -e "${R}FAILED${N}: Nginx service is not running (Status Code: ${R}$STATUS_CODE${N})"
    exit 1
fi

total_time