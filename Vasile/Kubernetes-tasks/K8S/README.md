# 1. Users Manifests Deployment Guide

## Apply name space manifest

```bash
kubectl apply -f K8S/users-manifests/namespace.yaml
```

## Apply all the other manifests

```bash
kubectl apply -f K8S/users-manifests/
```

## Verify pods

```bash
kubectl get pods -n color-app
```

## Verify services

```bash
kubectl get svc -n color-app
```

## Access frontend

```txt
http://localhost
```

## Backend logs

```bash
kubectl logs deployment/backend -n color-app
```

## On every circle click, a new color is being created
### To ensure that services are wired correctly (frontend -> backend -> database), check the DB after a round of clicks:

```bash
kubectl exec -it postgres-0 -n color-app -- psql -U postgres -d colorsdb
```

```bash
SELECT * FROM color_entity;
```

# Evidence

![5](<../evidence/5.png>)

![6](<../evidence/6.png>)

---

# 2. Users Stacks Deployment Guide

## Apply name space manifest

```bash
kubectl apply -f K8S/users-manifests/namespace.yaml
```

## Lint Helm Chart

```bash
helm lint /Users/vasile.durlesteanu/Projects/devops-intensive/Vasile/Kubernetes-tasks/K8S/users-stack
```

## Install Application Stack

```bash
helm install users-stack /Users/vasile.durlesteanu/Projects/devops-intensive/Vasile/Kubernetes-tasks/K8S/users-stack -n color-app
```

## Check Helm Release Status

```bash
helm status users-stack -n color-app
```

## View Application Pods

```bash
kubectl get pods -n color-app
```

## View Application Services

```bash
kubectl get svc -n color-app
```

## Install Nginx Ingress Controller
### To make http://localhost respond, execute the official community command to spin up the Nginx Ingress Controller tailored specifically for Docker Desktop. This will create a separate deployment that binds right to your local network ports.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

## Access frontend

```txt
http://localhost
```

## Backend logs

```bash
kubectl logs deployment/backend -n color-app
```

## On every circle click, a new color is being created
### To ensure that services are wired correctly (frontend -> backend -> database), check the DB after a round of clicks:

```bash
kubectl exec -it users-stack-database-0 -n color-app -- psql -U postgres -d colorsdb
```

```bash
SELECT * FROM color_entity;
```

# Evidence

![7](<../evidence/7.png>)

![8](<../evidence/8.png>)

![9](<../evidence/9.png>)
