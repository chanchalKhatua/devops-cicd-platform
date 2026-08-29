
# Kubernetes Metrics Server & HPA

## 1. Metrics Server

Metrics Server collects CPU and memory usage metrics from Kubernetes nodes and Pods.

It provides metrics through the Kubernetes Metrics API.

### Main Commands

Check Metrics Server:

```bash
kubectl get pods -n kube-system | grep metrics
````

Check node metrics:

```bash
kubectl top nodes
```

Check Pod metrics:

```bash
kubectl top pods
```

---

## 2. Install Metrics Server

Install Metrics Server:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Check:

```bash
kubectl get pods -n kube-system | grep metrics
```

---

## 3. Kind TLS Issue

In the local `kind` cluster, Metrics Server failed to scrape the kubelet because of a certificate validation error:

```text
tls: failed to verify certificate
x509: cannot validate certificate for <node-ip>
because it doesn't contain any IP SANs
```

For the local kind environment, configure Metrics Server with:

```bash
kubectl patch deployment metrics-server \
  -n kube-system \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

Check rollout:

```bash
kubectl rollout status deployment/metrics-server -n kube-system
```

Verify:

```bash
kubectl top nodes
kubectl top pods
```

Expected:

```text
CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
```

---

# 4. HPA

**HPA = Horizontal Pod Autoscaler**

HPA automatically increases or decreases the number of Pods based on resource utilization.

Our configuration:

```text
Minimum replicas: 2
Maximum replicas: 5
CPU target:       50%
```

Architecture:

```text
Pods
  ↓
Metrics Server
  ↓
Metrics API
  ↓
HPA
  ↓
Deployment
  ↓
Pods
```

---

# 5. HPA Configuration

File:

```text
kubernetes/hpa.yaml
```

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler

metadata:
  name: devops-cicd-frontend

spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: devops-cicd-frontend

  minReplicas: 2
  maxReplicas: 5

  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 60

    scaleDown:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60

  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

Apply:

```bash
kubectl apply -f kubernetes/hpa.yaml
```

Check:

```bash
kubectl get hpa
```

Example:

```text
NAME                   TARGETS       MINPODS   MAXPODS   REPLICAS
devops-cicd-frontend   cpu: 1%/50%   2         5         2
```

---

# 6. CPU Requests

Our Deployment contains:

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"

  limits:
    cpu: "500m"
    memory: "256Mi"
```

HPA CPU utilization is calculated based on the CPU request.

Example:

```text
CPU usage    = 50m
CPU request  = 100m

50 / 100 × 100 = 50%
```

Therefore:

```text
50% CPU utilization
        ↓
HPA target reached
```

---

# 7. HPA Demonstration

Our initial state:

```text
Deployment
    ↓
2 Pods
```

Check HPA:

```bash
kubectl get hpa
```

Check Pods:

```bash
kubectl get pods
```

Check CPU:

```bash
kubectl top pods
```

---

## Generate CPU Load

First check that `yes` exists inside the container:

```bash
kubectl exec -it $(kubectl get pod \
  -l app=devops-cicd-frontend \
  -o jsonpath='{.items[0].metadata.name}') \
  -- sh -c 'which yes'
```

Output:

```text
/usr/bin/yes
```

Generate CPU load:

```bash
kubectl exec -it $(kubectl get pod \
  -l app=devops-cicd-frontend \
  -o jsonpath='{.items[0].metadata.name}') \
  -- sh -c 'yes > /dev/null'
```

The command continuously consumes CPU.

Stop it with:

```text
Ctrl+C
```

`exit code 130` is expected because the process was interrupted with `Ctrl+C`.

---

# 8. Watch HPA Scale Up

Open another terminal:

```bash
kubectl get hpa -w
```

Watch Pods:

```bash
kubectl get pods -w
```

Check CPU:

```bash
kubectl top pods
```

Our demonstration:

```text
2 Pods
   ↓
CPU increases
   ↓
Metrics Server
   ↓
HPA detects high CPU
   ↓
Deployment scales
   ↓
3 Pods
   ↓
4 Pods
   ↓
5 Pods
```

Maximum replicas:

```text
5
```

because:

```yaml
maxReplicas: 5
```

---

# 9. HPA Scale Down

Stop the CPU load:

```text
Ctrl+C
```

CPU usage decreases.

Watch:

```bash
kubectl get hpa -w
```

and:

```bash
kubectl get pods -w
```

Our scale-down process:

```text
5 Pods
   ↓
CPU decreases
   ↓
HPA detects lower utilization
   ↓
4 Pods
   ↓
3 Pods
   ↓
2 Pods
```

Minimum replicas:

```text
2
```

because:

```yaml
minReplicas: 2
```

---

# 10. Complete Process

```text
                    Kubernetes
                         │
                         ▼
                       Pods
                         │
                  CPU / Memory
                         │
                         ▼
                  Metrics Server
                         │
                  Metrics API
                         │
                         ▼
                        HPA
                         │
                  Scaling Decision
                         │
                         ▼
                    Deployment
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
          Scale Up              Scale Down
              │                     │
        2 → 3 → 4 → 5          5 → 4 → 3 → 2
```

# 11. Commands Used

```bash
# Metrics Server
kubectl get pods -n kube-system | grep metrics

kubectl top nodes

kubectl top pods

# HPA
kubectl apply -f kubernetes/hpa.yaml

kubectl get hpa

kubectl get hpa -w

# Deployment / Pods
kubectl get deployment

kubectl get pods

kubectl get pods -w

# CPU load
kubectl exec -it $(kubectl get pod \
  -l app=devops-cicd-frontend \
  -o jsonpath='{.items[0].metadata.name}') \
  -- sh -c 'yes > /dev/null'
```

# 12. Current Status

```text
Metrics Server       ✅
kubectl top pods     ✅
HPA                  ✅
HPA Scale Up         ✅
HPA Scale Down       ✅
```

```
```

