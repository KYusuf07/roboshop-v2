#!/bin/bash

app_name=dispatch
source ./common.sh
check_root


app_setup
golang_setup


# Build the Go Application
go build -o dispatch . &>> $logs_file
validate $? "Building Dispatch Application (Go)"

# Copy SystemD Service File from your scripts directory
cp "$scripts_dir/dispatch.service" /etc/systemd/system/dispatch.service
validate $? "Copying dispatch.service file"

systemd_setup

restart

# ==========================================
# VERIFICATIONS
# ==========================================

# 1. Check Service Status
echo -e "\n${Y}--- Dispatch Service Status ---${N}"
systemctl status dispatch --no-pager

# 2. Check Recent Logs (last 20 lines)
echo -e "\n${Y}--- Recent Dispatch Logs ---${N}"
journalctl -u dispatch -n 20 --no-pager

total_time