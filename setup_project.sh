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
# Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
    echo "Error: Directory already exists."
    exit 1
fi

# Create directory structure
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

echo "Directory structure created successfully."

