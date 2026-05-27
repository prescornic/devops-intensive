# Kubernetes Deployment

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
