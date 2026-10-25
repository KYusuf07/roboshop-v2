#!/bin/bash

#!/bin/bash

app_name=user
source ./common.sh
check_root

app_setup
nodejs_setup
systemd_setup

restart

# 1. Check Service Status
echo -e "\n${Y}--- User Service Status ---${N}"
systemctl status user --no-pager

# Give the app a few seconds to start up before curling
echo -e "\n${Y}--- Waiting 5 seconds for application to start... ---${N}"
sleep 5

# 2. Health Check Endpoint
echo -e "\n${Y}--- Health Check (http://localhost:8080/health) ---${N}"
curl -s http://localhost:8080/health
echo "" # Add a newline for clean formatting


# Define Bold/Thick Green (add this to the top of your script with your other colors)
BG="\e[1;32m"

# Get only the HTTP status code and silence the rest of the output
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)

if [ "$STATUS_CODE" -eq 200 ]; then
    echo -e "${BG}SUCCESS${N}: User service is running (Status Code: ${BG}200${N})"
else
    echo -e "${R}FAILED${N}: User service is not running (Status Code: ${R}$STATUS_CODE${N})"
    exit 1
fi

total_time