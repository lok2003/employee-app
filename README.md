# Employee Management Application — DevOps Project

A Kubernetes-based Employee Management Application deployed on **Amazon EKS** using **Helm**, with monitoring through **Prometheus and Grafana**.

## 🚀 Project Overview

This project demonstrates how to package, deploy, expose, and monitor an application on Kubernetes.

The application is deployed to an EKS cluster using a Helm chart. Prometheus collects metrics and Grafana is used to visualize CPU and memory usage.

## 🏗️ Architecture

```text
                         AWS
                          |
                       Amazon EKS
                          |
              +-----------+-----------+
              |                       |
        Employee Namespace       Monitoring Namespace
              |                       |
        +-----+------+          +-----+------+
        |            |          |            |
   Employee Pods   Service   Prometheus    Grafana
        |            |          |            |
        +------------+          +------------+
              |                       |
        AWS LoadBalancer       Node Exporter
                                      |
                               Kubelet / cAdvisor
                                      |
                               CPU / Memory Metrics
```

## 🛠️ Technologies Used

- AWS EKS
- Kubernetes
- Helm
- Docker
- Amazon ECR
- Prometheus
- Grafana
- Kubernetes Metrics Server
- Node Exporter
- kube-state-metrics
- Git & GitHub

## 📁 Project Structure

```text
employee-app/
├── Chart.yaml
├── values.yaml
├── charts/
├── templates/
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── pvc.yaml
│   └── storageclass.yaml
├── monitoring/
│   └── node-exporter-servicemonitor.yaml
└── README.md
```

## ☸️ Kubernetes Resources

The Helm chart creates/manages resources including:

- Namespace
- ConfigMap
- Secret
- StorageClass
- PersistentVolumeClaim
- Deployment
- Service
- Ingress

The application is deployed in:

```text
employee
```

The monitoring stack is deployed in:

```text
monitoring
```

## 📦 Helm Deployment

### 1. Validate the chart

```bash
helm lint .
```

### 2. Preview the Kubernetes manifests

```bash
helm template employee-app .
```

### 3. Install the application

```bash
helm install employee-app .   --namespace employee   --create-namespace
```

### 4. Check the deployment

```bash
kubectl get pods -n employee
kubectl get svc -n employee
```

## 🌐 Application Access

The Employee App Service is configured as an AWS `LoadBalancer`.

Check the external endpoint:

```bash
kubectl get svc -n employee
```

Open the LoadBalancer address in a browser using the exposed application port.

## 📊 Monitoring

Monitoring is implemented using:

```text
Application
    |
    v
Kubernetes / Kubelet
    |
    v
Prometheus
    |
    v
Grafana
```

### Prometheus and Grafana Installation

The monitoring stack is installed using the Prometheus Community Helm repository.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Install kube-prometheus-stack:

```bash
helm install monitoring prometheus-community/kube-prometheus-stack   --namespace monitoring   --create-namespace
```

If another Node Exporter DaemonSet already exists in the cluster, the kube-prometheus-stack Node Exporter can be disabled:

```bash
helm upgrade monitoring prometheus-community/kube-prometheus-stack   --namespace monitoring   --set nodeExporter.enabled=false
```

## 🔎 Node Exporter Monitoring

An existing Node Exporter Service is monitored by Prometheus through a `ServiceMonitor`.

File:

```text
monitoring/node-exporter-servicemonitor.yaml
```

The ServiceMonitor connects:

```text
Node Exporter Service
        |
        v
ServiceMonitor
        |
        v
Prometheus
```

Verify the targets in Prometheus:

```text
Prometheus → Status → Target health
```

The Node Exporter targets should show as:

```text
UP
```

## 📈 Grafana

Grafana can be accessed locally using port forwarding:

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Open:

```text
http://localhost:3000
```

Get the Grafana admin password:

```bash
kubectl get secret -n monitoring monitoring-grafana   -o jsonpath="{.data.admin-password}" | base64 -d
```

## 📊 Metrics Tested

### Node CPU

```promql
100 - (
  avg by (instance) (
    rate(node_cpu_seconds_total{mode="idle"}[5m])
  ) * 100
)
```

### Node Memory

```promql
100 * (
  1 - (
    node_memory_MemAvailable_bytes /
    node_memory_MemTotal_bytes
  )
)
```

### Node Disk

```promql
100 - (
  node_filesystem_avail_bytes{fstype!~"tmpfs|overlay",mountpoint="/"}
  /
  node_filesystem_size_bytes{fstype!~"tmpfs|overlay",mountpoint="/"}
  * 100
)
```

## 🖥️ Employee Application Monitoring

The Employee App CPU and memory usage can also be checked directly from Kubernetes.

### CPU and Memory using Metrics Server

```bash
kubectl top pods -n employee
```

Example:

```text
NAME                          CPU(cores)   MEMORY(bytes)
employee-app-xxxxx-xxxxx      2m           94Mi
employee-app-xxxxx-xxxxx      2m           94Mi
```

### Employee App CPU in Prometheus

```promql
container_cpu_usage_seconds_total{
  namespace="employee",
  container="employee-app"
}
```

CPU usage rate:

```promql
rate(
  container_cpu_usage_seconds_total{
    namespace="employee",
    container="employee-app"
  }[5m]
)
```

## 🔧 Useful Kubernetes Commands

Check application Pods:

```bash
kubectl get pods -n employee
```

Check Services:

```bash
kubectl get svc -n employee
```

Check Pod details:

```bash
kubectl describe pod <pod-name> -n employee
```

Check application logs:

```bash
kubectl logs <pod-name> -n employee
```

Check resource usage:

```bash
kubectl top pods -n employee
```

Check Helm releases:

```bash
helm list -A
```

## 🧹 Remove the Application

```bash
helm uninstall employee-app -n employee
```

Remove the namespace if required:

```bash
kubectl delete namespace employee
```

## 🧹 Remove Monitoring

```bash
helm uninstall monitoring -n monitoring
```

