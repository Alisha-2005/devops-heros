#!/bin/bash

# Store system information in variables
current_date=$(date)
hostname_info=$(hostname)
username=$(whoami)

# Ask the user for a directory name
read -p "Enter a directory name: " dir_name

# Create the directory
mkdir -p "$dir_name"

# Create a file inside the directory
file_name="$dir_name/running_processes.txt"
touch "$file_name"

echo "===== SYSTEM INFORMATION ====="
echo "Current Date: $current_date"
echo "Hostname: $hostname_info"
echo "Username: $username"

echo ""
echo "===== DISK USAGE ====="
df -h

echo ""
echo "===== RUNNING PROCESSES ====="
ps aux

# Store running processes in the file using output redirection
ps aux > "$file_name"

echo ""
echo "Running processes have been saved to: $file_name"
