````markdown
# Kubernetes Ingress — Implementation Notes

## 1. Objective

Expose the `devops-cicd-frontend` application through a Kubernetes Ingress instead of accessing the application directly through a NodePort or `kubectl port-forward`.

Target flow:

Browser
   ↓
NGINX Ingress Controller
   ↓
Ingress Resource
   ↓
Kubernetes Service
   ↓
Frontend Pods

---

## 2. Current Application

Application Deployment:

```text
devops-cicd-frontend
````

Service:

```text
devops-cicd-frontend
```

Service port:

```text
80
```

Frontend Pods:

```text
devops-cicd-frontend
```

---

## 3. Why Ingress?

Without Ingress:

```text
Client
  ↓
NodePort
  ↓
Service
  ↓
Pods
```

With Ingress:

```text
Client
  ↓
Ingress
  ↓
Service
  ↓
Pods
```

Ingress provides a centralized HTTP/HTTPS entry point and supports:

* Host-based routing
* Path-based routing
* TLS termination
* Routing to multiple Services
* Centralized external access

---

# 4. Ingress Controller vs Ingress Resource

These are two different things.

## Ingress Controller

The **Ingress Controller** is the component that actually processes incoming traffic.

We used:

```text
NGINX Ingress Controller
```

Architecture:

```text
External Request
      ↓
NGINX Ingress Controller
      ↓
Ingress Resource
      ↓
Service
```

## Ingress Resource

The Ingress resource contains the routing rules.

For example:

```text
devops.local
     ↓
devops-cicd-frontend:80
```

The Ingress resource alone does not route traffic. An Ingress Controller must process it.

---

# 5. Install NGINX Ingress Controller

For the local `kind` cluster, we used the kind-specific NGINX Ingress manifest:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

Verify:

```bash
kubectl get pods -n ingress-nginx
```

Expected:

```text
ingress-nginx-controller-xxxxx   1/1   Running
```

Check the IngressClass:

```bash
kubectl get ingressclass
```

Expected:

```text
NAME    CONTROLLER
nginx   k8s.io/ingress-nginx
```

---

# 6. Automate Ingress Controller Installation

We created:

```text
scripts/install-ingress.sh
```

The script:

1. Checks `kubectl`
2. Checks Kubernetes connectivity
3. Verifies that the current cluster is a `kind` cluster
4. Installs the NGINX Ingress Controller
5. Waits for the controller Pod to become Ready
6. Verifies the IngressClass
7. Displays the controller status

Run:

```bash
./scripts/install-ingress.sh
```

---

# 7. Local kind Networking

Initially, the kind cluster was created without host port mappings.

The control-plane container only exposed the Kubernetes API:

```text
127.0.0.1:<port> → 6443
```

Therefore the Ingress Controller could not be reached directly from the WSL host.

We created:

```text
kind/kind-config.yaml
```

with:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
  - role: control-plane

    extraPortMappings:
      - containerPort: 80
        hostPort: 8081
        protocol: TCP

      - containerPort: 443
        hostPort: 8443
        protocol: TCP
```

This creates:

```text
Host 8081 → kind port 80
Host 8443 → kind port 443
```

The cluster was recreated using:

```bash
kind create cluster \
  --name devops-cluster \
  --config kind/kind-config.yaml
```

Verify:

```bash
docker ps --filter "name=devops-cluster-control-plane"
```

Expected:

```text
0.0.0.0:8081->80/tcp
0.0.0.0:8443->443/tcp
```

---

# 8. Create the Ingress Resource

File:

```text
kubernetes/ingress.yaml
```

Configuration:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: devops-cicd-frontend

spec:
  ingressClassName: nginx

  rules:
    - host: devops.local

      http:
        paths:
          - path: /
            pathType: Prefix

            backend:
              service:
                name: devops-cicd-frontend
                port:
                  number: 80
```

Apply:

```bash
kubectl apply -f kubernetes/ingress.yaml
```

---

# 9. Verify Ingress

Check:

```bash
kubectl get ingress
```

Expected:

```text
NAME                   CLASS   HOSTS          ADDRESS
devops-cicd-frontend   nginx   devops.local   localhost
```

Detailed information:

```bash
kubectl describe ingress devops-cicd-frontend
```

Expected routing:

```text
Host: devops.local

Path:
/

Backend:
devops-cicd-frontend:80
```

The backend should show the frontend Pod endpoints.

---

# 10. Test Ingress Locally

Because the kind cluster maps:

```text
localhost:8081 → kind:80
```

test using:

```bash
curl -H "Host: devops.local" http://localhost:8081
```

Successful response:

```text
HTTP/1.1 200 OK
```

The response should contain the React application's HTML.

Detailed test:

```bash
curl -v \
  -H "Host: devops.local" \
  http://127.0.0.1:8081
```

---

# 11. Final Local Architecture

```text
                    Windows / WSL
                         │
                         │
                  localhost:8081
                         │
                         ▼
                 kind host mapping
                         │
                         │ :80
                         ▼
              NGINX Ingress Controller
                         │
                         ▼
                  Ingress Resource
                         │
                   Host: devops.local
                         │
                         ▼
              devops-cicd-frontend
                    Kubernetes Service
                         │
                    Port: 80
                         │
                ┌────────┴────────┐
                ▼                 ▼
             Pod 1             Pod 2
             React             React
             NGINX             NGINX
```

---

# 12. Verification Commands

Check cluster:

```bash
kubectl get nodes
```

Check Pods:

```bash
kubectl get pods
```

Check Service:

```bash
kubectl get svc
```

Check Ingress Controller:

```bash
kubectl get pods -n ingress-nginx
```

Check IngressClass:

```bash
kubectl get ingressclass
```

Check Ingress:

```bash
kubectl get ingress
```

Check detailed routing:

```bash
kubectl describe ingress devops-cicd-frontend
```

Test application:

```bash
curl -H "Host: devops.local" http://localhost:8081
```

---

# 13. Troubleshooting

## `kubectl get ingressclass`

If:

```text
No resources found
```

the Ingress Controller has not been installed.

Install:

```bash
./scripts/install-ingress.sh
```

---

## Ingress Controller is not Running

Check:

```bash
kubectl get pods -n ingress-nginx
```

Then:

```bash
kubectl describe pod \
  -n ingress-nginx \
  <pod-name>
```

Check logs:

```bash
kubectl logs \
  -n ingress-nginx \
  <pod-name>
```

---

## `curl http://localhost`

If the response shows:

```text
Apache/2.4.58
```

the request is reaching Apache on WSL port `80`, not the Kubernetes Ingress.

Check:

```bash
sudo ss -ltnp | grep ':80'
```

In our environment:

```text
*:80 → apache2
```

Therefore we used:

```text
localhost:8081
```

for the kind Ingress.

---

## NodePort Doesn't Work From Host

The Ingress Service may show:

```text
80:31562/TCP
```

but the NodePort is inside the kind networking environment.

The kind cluster therefore needs host port mappings:

```text
8081 → 80
8443 → 443
```

configured through:

```text
kind/kind-config.yaml
```

---

# 14. Local Hostname

For local development we use:

```text
devops.local
```

Windows can resolve it using the hosts file:

```text
C:\Windows\System32\drivers\etc\hosts
```

Entry:

```text
127.0.0.1 devops.local
```

The local URL is:

```text
http://devops.local:8081
```

For the project, the WSL `curl` test is sufficient to verify the Kubernetes Ingress path.

---

# 15. Production Direction

The local setup is:

```text
devops.local
    ↓
kind
    ↓
NGINX Ingress
    ↓
Service
    ↓
Pods
```

The production environment will use the real domain and AWS infrastructure.

Conceptually:

```text
chanchalkhatua.in
        ↓
DNS
        ↓
AWS Load Balancer
        ↓
EKS
        ↓
Kubernetes
        ↓
Service
        ↓
Pods
```

The local `devops.local` configuration is only for development/testing.

---

# 16. Project Files

Ingress implementation added:

```text
kind/
└── kind-config.yaml

kubernetes/
└── ingress.yaml

scripts/
└── install-ingress.sh
```

These provide:

```text
kind configuration
       ↓
Ingress networking
       ↓
Ingress Controller installation
       ↓
Ingress routing
```

# 17. Implementation Result

```text
NGINX Ingress Controller       ✅
IngressClass                   ✅
Ingress Resource               ✅
Host-based routing             ✅
Service routing                ✅
kind host port mapping         ✅
Local HTTP access              ✅
Application response           ✅
```

Verified request:

```bash
curl -H "Host: devops.local" http://localhost:8081
```

Result:

```text
HTTP/1.1 200 OK
```

```
```

