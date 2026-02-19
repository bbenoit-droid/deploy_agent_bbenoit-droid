#!/bin/bash

# ============================
# Attendance Project Factory
# ============================

echo "Starting setup..."
if [ -z "$1" ]; then
    echo "Usage: ./setup_project.sh <version>"
    exit 1
fi

VERSION=$1
PROJECT_DIR="attendance_tracker_${VERSION}"

echo "Creating project: $PROJECT_DIR"

