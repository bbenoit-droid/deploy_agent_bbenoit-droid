#!/bin/bash

# ===============================
# Automated Project Bootstrapper
# ===============================

# ----- Global Variables -----
PROJECT_NAME=""
ARCHIVE_NAME=""

# ----- Trap Function -----
cleanup_on_interrupt() {
    echo ""
    echo "⚠️  SIGINT detected! Archiving current state..."

    if [ -d "$PROJECT_NAME" ]; then
        tar -czf "${ARCHIVE_NAME}.tar.gz" "$PROJECT_NAME"
        echo "📦 Archived as ${ARCHIVE_NAME}.tar.gz"

        rm -rf "$PROJECT_NAME"
        echo "🧹 Incomplete directory removed."
    fi

    exit 1
}

trap cleanup_on_interrupt SIGINT

# ----- Health Check -----
echo "🔎 Performing Python health check..."

if python3 --version &> /dev/null; then
    echo "✅ Python3 is installed."
else
    echo "❌ Python3 is NOT installed. Please install Python3."
    exit 1
fi

# ----- Input Validation -----
if [ -z "$1" ]; then
    echo "Usage: ./setup_project.sh <version_name>"
    exit 1
fi

INPUT=$1
PROJECT_NAME="attendance_tracker_${INPUT}"
ARCHIVE_NAME="attendance_tracker_${INPUT}_archive"

# ----- Directory Creation -----
if [ -d "$PROJECT_NAME" ]; then
    echo "❌ Directory already exists."
    exit 1
fi

mkdir -p "$PROJECT_NAME"/Helpers
mkdir -p "$PROJECT_NAME"/reports

echo "📁 Directory structure created."

# ----- Create Files -----

# attendance_checker.py
cat <<EOF > "$PROJECT_NAME/attendance_checker.py"
import csv
import json

def load_config():
    with open("Helpers/config.json") as f:
        return json.load(f)

def check_attendance():
    config = load_config()
    warning = config["warning_threshold"]
    failure = config["failure_threshold"]

    with open("Helpers/assets.csv") as file:
        reader = csv.DictReader(file)
        for row in reader:
            attendance = int(row["Attendance Count"])
            absence = int(row["Absence Count"])
            percentage = attendance / (attendance + absence) * 100

            if percentage < failure:
                status = "FAIL"
            elif percentage < warning:
                status = "WARNING"
            else:
                status = "OK"

            with open("reports/reports.log", "a") as log:
                log.write(f"{row['Names']} - {percentage:.2f}% - {status}\\n")

if __name__ == "__main__":
    check_attendance()
EOF

# assets.csv
cat <<EOF > "$PROJECT_NAME/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
john@example.com,John Doe,8,2
jane@example.com,Jane Smith,5,5
EOF

# config.json
cat <<EOF > "$PROJECT_NAME/Helpers/config.json"
{
    "warning_threshold": 75,
    "failure_threshold": 50
}
EOF

# reports.log
touch "$PROJECT_NAME/reports/reports.log"

echo "📄 Files generated."

# ----- Dynamic Configuration -----
echo ""
read -p "Do you want to update attendance thresholds? (y/n): " choice

if [[ "$choice" == "y" || "$choice" == "Y" ]]; then

    read -p "Enter new Warning threshold (%): " warning
    read -p "Enter new Failure threshold (%): " failure

    # Validate numeric input
    if ! [[ "$warning" =~ ^[0-9]+$ ]] || ! [[ "$failure" =~ ^[0-9]+$ ]]; then
        echo "❌ Invalid input. Must be numeric."
        exit 1
    fi

    sed -i "s/\"warning_threshold\": [0-9]*/\"warning_threshold\": $warning/" "$PROJECT_NAME/Helpers/config.json"
    sed -i "s/\"failure_threshold\": [0-9]*/\"failure_threshold\": $failure/" "$PROJECT_NAME/Helpers/config.json"

    echo "✅ Thresholds updated successfully."
fi

echo ""
echo "🚀 Setup complete!"

