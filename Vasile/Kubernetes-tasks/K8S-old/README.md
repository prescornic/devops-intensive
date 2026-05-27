# Kubernetes Deployment

## Apply manifests

```bash
kubectl apply -f K8S/users-manifests/
```

## Verify pods

```bash
kubectl get pods -n fullstack-app
```

## Verify services

```bash
kubectl get svc -n fullstack-app
```

## Access frontend

```txt
http://localhost
```

## Backend logs

```bash
kubectl logs deployment/backend -n fullstack-app
```

# Evidence

![1](<../evidence/1.png>)

![2](<../evidence/2.png>)

![3](<../evidence/3.png>)

![4](<../evidence/4.png>)