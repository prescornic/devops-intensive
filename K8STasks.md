# Kubernetes Practical Tasks

## Task 1: Convert Docker Compose App to Kubernetes

### Objective
Prepare Kubernetes manifests for the applications previously developed in Docker and currently configured in the docker-compose file.

### Source
Use the existing Docker Compose file as the source of truth:
- `Docker/docker-compose.yaml`

### Requirements
1. **Workloads**
	- Create Kubernetes manifests for:
	  - Frontend (nginx-frontend)
	  - Backend (java-backend)
	  - Database (postgres)
	- Use `Deployment` for frontend and backend.
	- Use `StatefulSet` for the database.

2. **Service Discovery and Networking**
	- Create a `Service` for each workload.
	- Frontend should be accessible from outside the cluster using a `NodePort` or `LoadBalancer` service.
	- Backend and database should be internal services (`ClusterIP`).
	- Ensure backend connects to database via service DNS name.

3. **Configuration and Secrets**
	- Move environment variables from docker-compose into:
	  - `ConfigMap` for non-sensitive values.
	  - `Secret` for credentials (database password).
	- Reference ConfigMap and Secret in the pod specs.

4. **Persistence**
	- Create a `PersistentVolumeClaim` for the database data.
	- Mount the PVC to `/var/lib/postgresql/data`.

5. **Health Checks**
	- Define `livenessProbe` and `readinessProbe` for frontend and backend.
	- Use appropriate HTTP endpoints or TCP checks.

6. **Resource Limits**
	- Add `resources.requests` and `resources.limits` for CPU and memory on all containers.

7. **Manifests Structure**
	- Place all manifests under `K8S/users-manifests/`.
	- Use separate files for each resource (e.g., `frontend-deployment.yaml`, `backend-service.yaml`).

### Deliverables
- Kubernetes YAML manifests for all resources listed above.
- `README.md` in `K8S/` with:
  - Steps to apply manifests.
  - How to access the frontend.
  - How to verify all pods and services are healthy.

### Testing Requirements
```bash
kubectl apply -f K8S/users-manifests/
kubectl get pods
kubectl get svc
kubectl describe deployment frontend
kubectl logs deployment/backend
```

### Evaluation Criteria
- Manifests correctly mirror docker-compose configuration.
- Services wired correctly (frontend -> backend -> database).
- Secrets used for credentials.
- Persistent storage configured and mounted.
- Health checks and resource limits present.
- Clear documentation and reproducible setup.

## Task 2: Convert Docker Compose App to Helm (with Subcharts)

### Objective
Package the same application stack as a Helm chart using subcharts for each component.

### Source
Use the existing Docker Compose file as the source of truth:
- `Docker/docker-compose.yaml`

### Requirements
1. **Chart Structure**
	- Create a parent chart named `users-stack`.
	- Create subcharts for:
	  - `frontend`
	  - `backend`
	  - `database`
	- Use `Chart.yaml` dependencies to include subcharts.

2. **Templates**
	- Each subchart must include:
	  - Workload (`Deployment` for frontend/backend, `StatefulSet` for database).
	  - `Service` definition.
	  - Probes and resource limits.
	- Parent chart should provide shared labels and common values.

3. **Values and Configuration**
	- Define defaults in the parent `values.yaml` and override in subcharts.
	- Move environment variables into:
	  - `ConfigMap` templates.
	  - `Secret` templates for credentials.
	- Backend must read database host from the database service name.

4. **Persistence**
	- Database subchart must provision a `PersistentVolumeClaim` and mount it to `/var/lib/postgresql/data`.

5. **Ingress or Service Exposure**
	- Expose the frontend via `NodePort` or `LoadBalancer`.
	- Keep backend and database internal (`ClusterIP`).

6. **Helm Best Practices**
	- Use `_helpers.tpl` for reusable naming and labels.
	- Support `fullnameOverride` and `nameOverride`.
	- Include a `NOTES.txt` with access instructions.

7. **Chart Location**
	- Place the Helm chart under `K8S/helm/app-stack/`.

### Deliverables
- Helm chart with parent and subcharts as specified above.
- `README.md` in `K8S/helm/` with:
	- Install, upgrade, and uninstall commands.
	- Values that users should override.
	- Access instructions for the frontend.

### Testing Requirements
```bash
helm lint K8S/helm/users-stack
helm install users-stack K8S/helm/users-stack
helm status users-stack
kubectl get pods
kubectl get svc
helm uninstall users-stack
```

### Evaluation Criteria
- Chart structure follows Helm conventions with subcharts.
- Values properly wired from parent to subcharts.
- Services and probes match the docker-compose intent.
- Database persistence configured correctly.
- Documentation is clear and reproducible.
