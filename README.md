Link to my Video that explains the functionality of program : https://www.loom.com/share/7855b4bb9c4c4ad6bbb53c2da4252662
# Attendance Tracker Automation Script

## Overview

This script automatically creates a structured attendance tracking project.  
It sets up directories, generates required files, performs environment checks, and handles interruptions safely.

The goal is to demonstrate Infrastructure as Code principles using Bash scripting.

---

## How to Run

Make the script executable:

chmod +x setup_project.sh

Run the script with a version name:

./setup_project.sh v1

Example:
./setup_project.sh v2

---

## What the Script Does

- Checks if Python3 is installed
- Validates user input (version argument)
- Creates required directory structure
- Generates:
  - attendance_checker.py
  - Helpers/assets.csv
  - Helpers/config.json
  - reports/reports.log
- Allows user to update attendance thresholds
- Validates numeric input
- Updates config.json using sed
- Handles Ctrl + C using trap
- Archives incomplete project if interrupted

---

## Testing the Trap

Run the script and press:

Ctrl + C

The script will:
- Create a .tar.gz archive
- Remove the incomplete directory

