#!/bin/bash

# Event Management System Kubernetes Deployment Script
# This script will deploy the Event Management System on Docker Desktop Kubernetes

set -e

echo "🚀 Starting Event Management System Deployment..."
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if Docker is running
print_status "Checking Docker Desktop status..."
if ! docker version >/dev/null 2>&1; then
    print_error "Docker Desktop is not running. Please start Docker Desktop first."
    exit 1
fi

# Check if Kubernetes is enabled and running
print_status "Checking Kubernetes cluster..."
if ! kubectl cluster-info >/dev/null 2>&1; then
    print_error "Cannot connect to Kubernetes cluster. Please ensure Docker Desktop Kubernetes is enabled and running."
    print_warning "Go to Docker Desktop Settings > Kubernetes > Enable Kubernetes"
    exit 1
fi

# Navigate to project directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/Event-Management-System/backend"
FRONTEND_DIR="$SCRIPT_DIR/Event-Management-System/frontend"
K8S_MANIFEST="$SCRIPT_DIR/Event-Management-System/k8s-deployment.yaml"

print_status "Building Backend Docker image..."
cd "$BACKEND_DIR"
docker build -t event-management-backend:latest .

print_status "Building Frontend Docker image..."
cd "$FRONTEND_DIR"
docker build -t event-management-frontend:latest .

print_status "Applying Kubernetes manifests..."
kubectl apply -f "$K8S_MANIFEST"

print_status "Waiting for deployments to be ready..."
echo "This may take a few minutes..."

# Wait for MySQL
print_status "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql-event --timeout=300s || print_warning "MySQL deployment may still be starting..."

# Wait for Backend
print_status "Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend-event --timeout=300s || print_warning "Backend deployment may still be starting..."

# Wait for Frontend
print_status "Waiting for Frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend-event --timeout=300s || print_warning "Frontend deployment may still be starting..."

print_status "Deployment Status:"
kubectl get all

print_status "Service Information:"
kubectl get svc

echo ""
echo "🎉 Event Management System deployed successfully!"
echo "=============================================="
echo ""
echo "📋 Access URLs:"
echo "   • Frontend: http://localhost:30080"
echo "   • Backend API: http://localhost:30025/back2"
echo "   • Database: MySQL on port 3306 (internal)"
echo ""
echo "🔧 Useful Commands:"
echo "   • View logs: kubectl logs -f deployment/frontend-event"
echo "   • Check pods: kubectl get pods"
echo "   • Delete deployment: kubectl delete -f $K8S_MANIFEST"
echo ""
echo "⏱️  Note: It may take a few more minutes for all services to be fully ready."
echo "   You can check the status with: kubectl get pods"

# Test connectivity
print_status "Testing backend connectivity..."
if curl -s "http://localhost:30025/back2" >/dev/null 2>&1; then
    print_status "✅ Backend is accessible!"
else
    print_warning "⚠️  Backend may still be starting. Please wait a moment and try: curl http://localhost:30025/back2"
fi