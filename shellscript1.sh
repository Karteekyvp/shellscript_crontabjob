#!/bin/bash

# Define the administrator's email
ADMIN_EMAIL="admin@example.com"

# Log file
LOG_FILE="/var/log/system_health.log"

# Function to check disk space usage
check_disk_space() {
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$DISK_USAGE" -ge 90 ]; then
        echo "Disk space usage is above threshold: ${DISK_USAGE}%" | tee -a $LOG_FILE
        return 1
    else
        echo "Disk space usage is normal: ${DISK_USAGE}%" | tee -a $LOG_FILE
        return 0
    fi
}

# Function to check memory usage
check_memory_usage() {
    MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    if [ "$(echo "$MEM_USAGE > 80" | bc)" -eq 1 ]; then
        echo "Memory usage is above threshold: ${MEM_USAGE}%" | tee -a $LOG_FILE
        return 1
    else
        echo "Memory usage is normal: ${MEM_USAGE}%" | tee -a $LOG_FILE
        return 0
    fi
}

# Function to check CPU load
check_cpu_load() {
    CPU_LOAD=$(uptime | awk -F 'load average:' '{ print $2 }' | cut -d ',' -f 1)
    if [ "$(echo "$CPU_LOAD > 2.0" | bc)" -eq 1 ]; then
        echo "CPU load is above threshold: ${CPU_LOAD}" | tee -a $LOG_FILE
        return 1
    else
        echo "CPU load is normal: ${CPU_LOAD}" | tee -a $LOG_FILE
        return 0
    fi
}

# Function to check for zombie processes
check_zombie_processes() {
    ZOMBIE_COUNT=$(ps aux | grep -w Z | wc -l)
    if [ "$ZOMBIE_COUNT" -gt 0 ]; then
        echo "There are zombie processes running: ${ZOMBIE_COUNT} zombies" | tee -a $LOG_FILE
        return 1
    else
        echo "No zombie processes found." | tee -a $LOG_FILE
        return 0
    fi
}

# Function to check for disk read/write errors in system logs
check_disk_errors() {
    ERROR_COUNT=$(grep -i 'error\|fail' /var/log/syslog | grep -i 'sd' | wc -l)
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "There are disk read/write errors in the logs: ${ERROR_COUNT} errors" | tee -a $LOG_FILE
        return 1
    else
        echo "No disk errors found in system logs." | tee -a $LOG_FILE
        return 0
    fi
}

# Main function to run all checks
run_checks() {
    check_disk_space
    DISK_STATUS=$?
    check_memory_usage
    MEM_STATUS=$?
    check_cpu_load
    CPU_STATUS=$?
    check_zombie_processes
    ZOMBIE_STATUS=$?
    check_disk_errors
    ERROR_STATUS=$?

    # Check if any of the checks failed
    if [ $DISK_STATUS -eq 1 ] || [ $MEM_STATUS -eq 1 ] || [ $CPU_STATUS -eq 1 ] || [ $ZOMBIE_STATUS -eq 1 ] || [ $ERROR_STATUS -eq 1 ]; then
        echo "One or more system health checks have failed. Notifying administrator." | tee -a $LOG_FILE
        echo "System Health Alert - $(date)" | mail -s "System Health Alert" $ADMIN_EMAIL
    else
        echo "All system health checks passed successfully." | tee -a $LOG_FILE
    fi
}

# Run the health checks
run_checks
