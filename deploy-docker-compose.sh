#!/bin/bash

# Event Management System Docker Compose Deployment Script
# This script will deploy the Event Management System using Docker Compose
# This is an alternative when Kubernetes is not available

set -e

echo "🚀 Starting Event Management System Deployment with Docker Compose..."
echo "==============================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if Docker is running
print_status "Checking Docker status..."
if ! docker version >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop first."
    exit 1
fi

# Check if Docker Compose is available
print_status "Checking Docker Compose..."
if ! docker compose version >/dev/null 2>&1; then
    print_warning "Docker Compose might not be available. Trying alternative..."
    if ! docker-compose --version >/dev/null 2>&1; then
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
fi

# Navigate to project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

print_status "Building and starting services..."

# Use docker compose (new syntax) or docker-compose (old syntax)
if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

print_status "Building Docker images..."
$COMPOSE_CMD build

print_status "Starting services..."
$COMPOSE_CMD up -d

print_status "Waiting for services to be ready..."
echo "This may take a few minutes..."

# Wait for MySQL
print_status "Waiting for MySQL to be ready..."
timeout=60
while ! docker exec event-mysql mysqladmin ping -h localhost --silent; do
    sleep 2
    timeout=$((timeout - 2))
    if [ $timeout -le 0 ]; then
        print_warning "MySQL may still be starting..."
        break
    fi
done

# Wait for Backend
print_status "Waiting for Backend to be ready..."
timeout=60
while ! curl -s "http://localhost:2025/back2" >/dev/null 2>&1; do
    sleep 2
    timeout=$((timeout - 2))
    if [ $timeout -le 0 ]; then
        print_warning "Backend may still be starting..."
        break
    fi
done

# Wait for Frontend
print_status "Waiting for Frontend to be ready..."
timeout=60
while ! curl -s "http://localhost:3000" >/dev/null 2>&1; do
    sleep 2
    timeout=$((timeout - 2))
    if [ $timeout -le 0 ]; then
        print_warning "Frontend may still be starting..."
        break
    fi
done

print_status "Deployment Status:"
$COMPOSE_CMD ps

echo ""
echo "🎉 Event Management System deployed successfully with Docker Compose!"
echo "==============================================================="
echo ""
echo "📋 Access URLs:"
echo "   • Frontend: http://localhost:3000"
echo "   • Backend API: http://localhost:2025/back2"
echo "   • Database: MySQL on localhost:3306"
echo ""
echo "🔧 Useful Commands:"
echo "   • View logs: $COMPOSE_CMD logs -f"
echo "   • Stop services: $COMPOSE_CMD down"
echo "   • Restart services: $COMPOSE_CMD restart"
echo "   • View status: $COMPOSE_CMD ps"
echo ""
echo "⏱️  Note: Services may take a few more minutes to be fully ready."

# Test connectivity
print_status "Testing backend connectivity..."
if curl -s "http://localhost:2025/back2" >/dev/null 2>&1; then
    print_status "✅ Backend is accessible!"
else
    print_warning "⚠️  Backend may still be starting. Please wait a moment and try: curl http://localhost:2025/back2"
fi

print_status "Testing frontend connectivity..."
if curl -s "http://localhost:3000" >/dev/null 2>&1; then
    print_status "✅ Frontend is accessible!"
else
    print_warning "⚠️  Frontend may still be starting. Please wait a moment and try: curl http://localhost:3000"
fi