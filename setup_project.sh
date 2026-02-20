#!/bin/bash

# ============================
# Attendance Project Factory
# ============================

echo "Starting setup..."
# ----------------------------
# Python Health Check
# ----------------------------

echo "Checking if Python3 is installed..."

if ! command -v python3 &> /dev/null
then
    echo "Error: Python3 is not installed."
    exit 1
fi

echo "Python3 detected successfully."
if [ -z "$1" ]; then

    echo "How to Run program: ./setup_project.sh (version name)"

    exit 1
fi

VERSION=$1
Project_Name="attendance_tracker_${VERSION}"

ARCHIVE_NAME="${Project_Name}_archive"

# ----------------------------
# Trap for Ctrl + C (SIGINT)
# ----------------------------

cleanup() {
    echo ""
    echo "Interrupt detected. Archiving project..."

    if [ -d "$Project_Name" ]; then
        tar -czf "${ARCHIVE_NAME}.tar.gz" "$Project_Name"
        echo "Project archived as ${ARCHIVE_NAME}.tar.gz"

        rm -rf "$Project_Name"
        echo "Incomplete directory removed."
    fi

    exit 1
}

trap cleanup SIGINT

echo "Creating project: $Project_Name"
# Check if directory already exists
if [ -d "$Project_Name" ]; then
    echo "Error: Directory already exists."
    exit 1
fi

# Create directory structure
mkdir -p "$Project_Name/Helpers"
mkdir -p "$Project_Name/reports"

echo "Directory structure created successfully."
cat <<EOF > "$Project_Name/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat <<EOF > "$Project_Name/Helpers/assets.csv"
Email ,Names, Attendance Count, Absence Count
alice@example.com ,Alice Johnson ,14, 1
bob@example.com ,Bob Smith ,7, 8
charlie@example.com ,Charlie Davis ,4 ,11
diana@example.com ,Diana Prince ,15 ,0
EOF
cat <<EOF > "$Project_Name/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}

EOF
cat <<EOF > "$Project_Name/reports/reports.log)"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your
attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie
Davis, your attendance is 26.7%. You will fail this class.
EOF
echo "Project files generated successfully."
echo ""
read -p "Do you want to update attendance thresholds? (y/n): " answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then

    read -p "Enter new warning threshold (%): " new_warning
    read -p "Enter new failure threshold (%): " new_failure

    # Validate numeric input
    if ! [[ "$new_warning" =~ ^[0-9]+$ ]] || ! [[ "$new_failure" =~ ^[0-9]+$ ]]; then
        echo "Error: Thresholds must be numeric values."
        exit 1
    fi

    # Update JSON using sed
    sed -i "s/\"warning_threshold\": [0-9]*/\"warning_threshold\": $new_warning/" "$Project_Name/Helpers/config.json"
    sed -i "s/\"failure_threshold\": [0-9]*/\"failure_threshold\": $new_failure/" "$Project_Name/Helpers/config.json"

    echo "Thresholds updated successfully."
fi

