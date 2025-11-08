# Event Management System - Kubernetes Deployment

This repository contains the Event Management System deployed on Kubernetes using Docker Desktop and Ansible.

## 📋 Prerequisites

- Docker Desktop installed and running
- Kubernetes enabled in Docker Desktop (Settings > Kubernetes > Enable Kubernetes)
- kubectl installed and configured
- Git installed

## 🚀 Quick Deployment

### Option 1: Using the Deployment Script (Recommended)

1. **Clone the repositories:**
   ```bash
   git clone https://github.com/suneethabulla/Event-Management-System
   git clone https://github.com/srithars/Sample-Ansible-Playbook-template
   ```

2. **Make the deployment script executable:**
   ```bash
   chmod +x deploy-event-management.sh
   ```

3. **Run the deployment script:**
   ```bash
   ./deploy-event-management.sh
   ```

### Option 2: Using Ansible

1. **Install Ansible:**
   ```bash
   # On Windows with WSL or Linux/macOS
   pip install ansible
   ```

2. **Run the Ansible playbook:**
   ```bash
   ansible-playbook event-management-deploy.yaml
   ```

### Option 3: Manual Deployment

1. **Build Docker images:**
   ```bash
   # Build backend
   cd Event-Management-System/backend
   docker build -t event-management-backend:latest .
   
   # Build frontend
   cd ../frontend
   docker build -t event-management-frontend:latest .
   ```

2. **Apply Kubernetes manifests:**
   ```bash
   kubectl apply -f Event-Management-System/k8s-deployment.yaml
   ```

## 📊 Application Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   (React)       │◄──►│   (Spring Boot) │◄──►│   (MySQL)       │
│   Port: 30080   │    │   Port: 30025   │    │   Port: 3306    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔗 Access URLs

After successful deployment, access your application at:

- **Frontend:** http://localhost:30080
- **Backend API:** http://localhost:30025/back2
- **Database:** MySQL on port 3306 (internal cluster access only)

## 🔧 Configuration

### Backend Configuration
- **Port:** 2025
- **Context Path:** /back2
- **Database:** MySQL 8.0
- **Database Name:** event
- **Credentials:** root/root

### Frontend Configuration
- **Port:** 8080 (served by nginx)
- **Backend URL:** Automatically configured to connect to backend service

### Kubernetes Services
- **Frontend Service:** NodePort on 30080
- **Backend Service:** NodePort on 30025
- **MySQL Service:** ClusterIP on 3306

## 📊 Monitoring and Management

### Check Deployment Status
```bash
kubectl get all
kubectl get pods
kubectl get services
```

### View Logs
```bash
# Frontend logs
kubectl logs -f deployment/frontend-event

# Backend logs
kubectl logs -f deployment/backend-event

# MySQL logs
kubectl logs -f deployment/mysql-event
```

### Scale Applications
```bash
# Scale frontend to 3 replicas
kubectl scale deployment frontend-event --replicas=3

# Scale backend to 4 replicas
kubectl scale deployment backend-event --replicas=4
```

### Delete Deployment
```bash
kubectl delete -f Event-Management-System/k8s-deployment.yaml
```

## 🛠️ Troubleshooting

### Common Issues

1. **Pods not starting:**
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. **Services not accessible:**
   ```bash
   kubectl get services
   kubectl describe service <service-name>
   ```

3. **Database connection issues:**
   ```bash
   kubectl exec -it deployment/mysql-event -- mysql -u root -p
   ```

4. **Image pull errors:**
   - Ensure Docker images are built locally
   - Check image names and tags in Kubernetes manifests

### Docker Desktop Specific Issues

1. **Kubernetes not starting:**
   - Restart Docker Desktop
   - Check Docker Desktop settings for Kubernetes
   - Ensure sufficient resources (CPU/Memory) allocated

2. **Port conflicts:**
   - Ensure ports 30080, 30025, and 3306 are not in use
   - Modify NodePort values in `k8s-deployment.yaml` if needed

## 📁 Project Structure

```
cicd-semin2/
├── Event-Management-System/
│   ├── backend/                 # Spring Boot application
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   │   └── src/
│   ├── frontend/                # React application
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── src/
│   └── k8s-deployment.yaml      # Kubernetes manifests
├── Sample-Ansible-Playbook-template/
│   ├── ansible/
│   └── k8s/
├── deploy-event-management.sh   # Deployment script
└── event-management-deploy.yaml # Ansible playbook
```

## 🔒 Security Considerations

- Database credentials are currently hardcoded for development
- Consider using Kubernetes Secrets for production deployments
- Implement proper ingress controllers for production
- Use TLS certificates for HTTPS in production

## 🚀 Next Steps

- Implement CI/CD pipeline
- Add monitoring and logging (Prometheus, Grafana)
- Implement proper ingress with TLS
- Add health checks and readiness probes
- Configure resource limits and requests
- Implement horizontal pod autoscaling

## 📞 Support

For issues related to:
- **Event Management System:** Check the original repository
- **Deployment Issues:** Review the troubleshooting section
- **Kubernetes Issues:** Consult Kubernetes documentation

## 📄 License

This deployment configuration is provided as-is for educational purposes.