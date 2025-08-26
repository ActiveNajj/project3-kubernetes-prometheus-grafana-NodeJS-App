Kubernetes NodeJS Application Monitoring with Prometheus and Grafana





Overview
This project demonstrates a comprehensive end-to-end monitoring solution for Node.js applications deployed on Kubernetes using Prometheus for metrics collection and Grafana for visualization. The setup includes automated alerting through AlertManager with Slack integration, making it production-ready for modern cloud-native environments.
Architecture
The monitoring stack consists of:
•	Node.js Application: Custom metrics integration using prom-client
•	Kubernetes Cluster: Container orchestration with kubeadm
•	Prometheus Server: Metrics collection and storage
•	Grafana: Dashboard visualization and analytics
•	AlertManager: Intelligent alerting with Slack notifications
•	Helm: Package management for Kubernetes deployments
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Node.js App   │───>│  Prometheus      │───>│    Grafana      │
│   (Port 3000)   │    │  (Metrics)       │    │  (Dashboard)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                         
                       ┌──────────────────┐              
                       │  AlertManager    │              
                       │  (Slack Alerts)  │              
                       └──────────────────┘              

Components
Application Layer
•	Node.js App: Express server with custom HTTP request metrics
•	Docker Image: activemo/nodejs-app:v1
•	Custom Metrics: HTTP request counters and system monitoring
Kubernetes Resources
•	Deployment: 3 replicas for high availability
•	Service: NodePort exposure for external access
•	ServiceMonitor: Automatic metrics discovery
•	PrometheusRule: Custom alerting rules
Monitoring Stack
•	Prometheus: Time-series metrics database
•	Grafana: Visualization and dashboarding
•	AlertManager: Alert routing and notifications
Prerequisites
Before getting started, ensure you have:
•	Kubernetes cluster (minikube, kubeadm, or cloud provider)
•	kubectl configured and connected to your cluster
•	Helm 3.x installed
•	Docker (for building custom images)
•	Slack webhook URL (for alerting)
Quick Start
1. Clone the Repository
git clone https://github.com/ActiveNajj/project3-kubernetes-prometheus-grafana-NodeJS-App.git
cd project3-kubernetes-prometheus-grafana-NodeJS-App

2. Deploy the Node.js Application
# Create the deployment
kubectl apply -f nodejs-app.yaml

# Create the service
kubectl apply -f nodejs-svc.yaml

# Verify deployment
kubectl get pods,svc

3. Install Prometheus Stack using Helm
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install Prometheus stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123

4. Configure Monitoring Resources
# Apply ServiceMonitor for metrics discovery
kubectl apply -f nodejs-monitor.yaml

# Apply PrometheusRule for alerting
kubectl apply -f nodejs-rule.yaml

# Configure AlertManager (update webhook URL first)
kubectl apply -f nodejs-alert-manager.yaml

5. Access the Dashboards
# Get Grafana admin password
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Port forward to access Grafana
kubectl port-forward --namespace monitoring svc/prometheus-grafana 3000:80

# Port forward to access Prometheus
kubectl port-forward --namespace monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

Access the applications:
•	Grafana: http://localhost:3000 (admin/admin123)
•	Prometheus: http://localhost:9090
•	Node.js App: http://cluster-ip:nodeport
Load Testing
Generate traffic to trigger alerts:
# Make the script executable
chmod +x send.sh

# Run load testing script (15 concurrent processes)
./send.sh

This script sends requests every 67ms to exceed the 10 requests/5min alert threshold.
Configuration Files
Key Files Structure
├── index.js                    # Node.js application with metrics
├── Dockerfile                  # Container image definition
├── nodejs-app.yaml            # Kubernetes deployment
├── nodejs-svc.yaml            # Kubernetes service
├── nodejs-monitor.yaml        # ServiceMonitor for Prometheus
├── nodejs-rule.yaml           # PrometheusRule for alerting
├── nodejs-alert-manager.yaml  # AlertManager configuration
└── send.sh                    # Load testing script

Application Metrics
The Node.js application exposes the following custom metrics:
•	http_requests_root_total: Counter for HTTP requests to root path
•	nodejs_*: Default Node.js process metrics (memory, CPU, GC, etc.)
Alert Rules
•	HighRequestRate_NodeJS: Triggers when rate(http_requests_root_total[5m]) > 10
•	Slack Integration: Sends alerts to #high-cpu-channel
Grafana Dashboards
Recommended Dashboards
1.	Node.js Application Dashboard (ID: 11159)
2.	Kubernetes Cluster Monitoring (ID: 7249)
3.	Prometheus Stats (ID: 2)
Import via Grafana UI: Dashboards → Import → Enter Dashboard ID
Custom Panels
Create custom panels for:
•	HTTP Request Rate
•	Response Time Distribution
•	Memory Usage Trends
•	Error Rate Monitoring
🚨 Alerting Setup
Slack Integration
1.	Create a Slack webhook in your workspace
2.	Update nodejs-alert-manager.yaml with your webhook URL:
apiURL:
  key: webhook
  name: slack-secret

3.	Create the secret:
kubectl create secret generic slack-secret \
  --from-literal=webhook=YOUR_SLACK_WEBHOOK_URL \
  -n monitoring

🛠️ Troubleshooting
Common Issues
Pods not starting:
kubectl describe pod <pod-name>
kubectl logs <pod-name>

Metrics not appearing:
# Check ServiceMonitor
kubectl get servicemonitor -n monitoring

# Verify service labels match
kubectl get svc nodejs-svc --show-labels

Alerts not firing:
# Check PrometheusRule
kubectl get prometheusrule -n monitoring

# Verify alert conditions in Prometheus UI

Validation Commands
# Check all monitoring components
kubectl get all -n monitoring

# Verify metrics endpoint
curl http://nodejs-service-ip:3000/metrics

# Test alert webhook
curl -X POST YOUR_SLACK_WEBHOOK_URL -d '{"text":"Test alert"}'

🔒 Production Considerations
Security
•	 Enable RBAC for service accounts
•	Use TLS for metric endpoints
•	Secure Grafana with LDAP/OAuth
•	Network policies for pod communication
Performance
•	Configure resource limits for all pods
•	Set up persistent volumes for Prometheus data
•	Configure retention policies
•	Enable metric relabeling for optimization
High Availability
•	Deploy Prometheus in HA mode
•	Use external storage (S3, GCS) for long-term retention
•	Set up Grafana clustering
•	Configure AlertManager clustering
