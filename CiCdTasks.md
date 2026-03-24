# CI/CD Practical Tasks (GitHub Actions)

## General Requirements (apply to all tasks)

- Use GitHub Actions as the CI/CD platform.
- Workflows must be versioned in `.github/workflows/`.
- Use environments and GitHub Secrets for credentials.
- Pipelines must support repeatable execution and clear logs.
- Keep workflows modular and reusable where possible.
- Document all required secrets, variables, and execution steps.

---

## Task 1: Build Pipelines for Frontend and Backend (Push to Registry)

### Task 1 Objective

Create GitHub Actions build pipelines for frontend and backend applications, then push both images to a Docker registry.

### Task 1 Scope

- Frontend source: `Docker/Frontend/`
- Backend source: `Docker/Java/`
- Compose reference: `Docker/docker-compose.yaml`

### Task 1 Requirements

1. **Triggers**:

   - Run on every commit to `main`.
   - Run on every Git tag push.

2. **Build & Push**:

   - Build frontend and backend images.
   - Tag images with:
     - commit SHA
     - git tag (when pipeline runs for tag)
     - `latest` (only for `main`)
   - Push images to Docker registry (Docker Hub or GHCR).

3. **Authentication & Security**:

   - Use GitHub Secrets for registry credentials.
   - Do not hardcode credentials in workflow files.

4. **Quality Gates**:

   - Fail pipeline if build fails.
   - Print resulting image names/tags in workflow summary.

### Task 1 Deliverables

- GitHub Actions workflow file(s) in `.github/workflows/`.
- `README.md` section documenting:
  - Required secrets.
  - Image naming convention.
  - Trigger behavior for `main` and tags.

### Task 1 Suggested Validation

```bash
# Trigger on main
git checkout main
git commit --allow-empty -m "test ci build"
git push origin main

# Trigger on tag
git tag v1.0.0
git push origin v1.0.0
```

### Task 1 Evaluation Criteria

- Both frontend and backend images are built and pushed successfully.
- Correct tags are applied.
- Secrets are handled securely.
- Pipeline logs are clear and traceable.

---

## Task 2: Infrastructure Pipeline with Terraform (IaC)

### Task 2 Objective

Create a GitHub Actions Terraform pipeline that provisions infrastructure using the existing IaC code.

### Task 2 Scope

- Terraform root paths:
  - `IaC/envs/dev/`
  - `IaC/envs/stg/`
  - `IaC/envs/prod/`

### Task 2 Requirements

1. **Validation Stages**:

   - Run `terraform fmt -check`.
   - Run `terraform init`.
   - Run `terraform validate`.
   - Run `terraform plan`.

2. **Environment Strategy**:

   - Support at least `dev`, `stg`, and `prod`.
   - Use separate backend/state strategy per environment.
   - Run `plan` automatically on pull requests.

3. **Apply Rules**:

   - Apply to `dev` automatically on push to `main`.
   - Require manual approval/environment protection for `prod` apply.

4. **Secrets and Variables**:

   - Use GitHub Secrets for cloud credentials.
   - Use environment variables or `.tfvars` strategy documented in README.

### Task 2 Deliverables

- GitHub Actions Terraform workflow file in `.github/workflows/`.
- Environment configuration strategy documented in `README.md`.

### Task 2 Suggested Validation

```bash
terraform -chdir=IaC/envs/dev fmt -check
terraform -chdir=IaC/envs/dev init
terraform -chdir=IaC/envs/dev validate
terraform -chdir=IaC/envs/dev plan
```

### Task 2 Evaluation Criteria

- Terraform checks and plan run consistently.
- Environment separation is correctly implemented.
- Apply process is safe (approval for production).
- Pipeline is idempotent and reproducible.

---

## Task 3: Deploy Pipeline for Helm Charts (Frontend, Backend, Database)

### Task 3 Objective

Create a GitHub Actions deployment pipeline that deploys Helm charts for frontend, backend, and database.

### Task 3 Scope

- Helm charts location:
  - `K8S/helm/backend/`
  - `K8S/helm/users-stack/` (or equivalent chart structure for frontend/backend/database)

### Task 3 Requirements

1. **Deployment Trigger**:

   - Run deployment on successful completion of build pipeline from Task 1.
   - Allow manual execution (`workflow_dispatch`) for rollback/redeploy scenarios.

2. **Kubernetes Access**:

   - Authenticate to cluster using kubeconfig or cloud provider action.
   - Store kubeconfig/credentials in GitHub Secrets.

3. **Helm Deployment**:

   - Use `helm upgrade --install`.
   - Deploy frontend, backend, and database release(s).
   - Pass image tags from build pipeline artifacts/outputs.

4. **Post-Deploy Verification**:

   - Run `kubectl get pods` and `kubectl get svc`.
   - Fail pipeline if deployment/rollout is unsuccessful.

5. **Rollback Support**:

   - Provide workflow instructions to rollback using `helm rollback`.

### Task 3 Deliverables

- GitHub Actions deploy workflow file in `.github/workflows/`.
- `README.md` section with:
  - Required secrets.
  - Deploy, verify, and rollback commands.

### Task 3 Suggested Validation

```bash
helm lint K8S/helm/users-stack
helm upgrade --install users-stack K8S/helm/users-stack
kubectl get pods -n default
kubectl get svc -n default
```

### Task 3 Evaluation Criteria

- Helm deployments are automated and repeatable.
- Frontend, backend, and database are deployed successfully.
- Pipeline validates rollout status.
- Rollback procedure is documented and usable.
