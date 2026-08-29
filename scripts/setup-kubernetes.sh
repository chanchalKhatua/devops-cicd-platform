#!/bin/bash

set -e

echo "======================================"
echo " Kubernetes Environment Setup"
echo "======================================"

CLUSTER_NAME="devops-cluster"
KIND_CONFIG="kind/kind-config.yaml"

# --------------------------------------
# 1. Check kind
# --------------------------------------

echo
echo "[1/7] Checking kind..."

if ! command -v kind >/dev/null 2>&1; then
    echo "ERROR: kind is not installed."
    exit 1
fi

echo "kind: AVAILABLE"

# --------------------------------------
# 2. Check / Create cluster
# --------------------------------------

echo
echo "[2/7] Checking kind cluster..."

if kind get clusters | grep -qx "$CLUSTER_NAME"; then

    echo "Cluster '$CLUSTER_NAME': EXISTS"

else

    echo "Cluster '$CLUSTER_NAME': NOT FOUND"
    echo "Creating cluster using:"
    echo "$KIND_CONFIG"

    if [ ! -f "$KIND_CONFIG" ]; then
        echo "ERROR: Kind configuration not found:"
        echo "$KIND_CONFIG"
        exit 1
    fi

    kind create cluster \
        --name "$CLUSTER_NAME" \
        --config "$KIND_CONFIG"

    echo "Cluster '$CLUSTER_NAME': CREATED"

fi

# --------------------------------------
# 3. Verify Kubernetes
# --------------------------------------

echo
echo "[3/7] Checking Kubernetes..."

kubectl config use-context "kind-$CLUSTER_NAME" >/dev/null

if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "ERROR: Kubernetes cluster is not reachable."
    exit 1
fi

echo "Kubernetes: READY"

# --------------------------------------
# 4. Metrics Server
# --------------------------------------

echo
echo "[4/7] Setting up Metrics Server..."

./scripts/install-metrics-server.sh

# --------------------------------------
# 5. Ingress Controller
# --------------------------------------

echo
echo "[5/7] Setting up Ingress Controller..."

./scripts/install-ingress.sh

# --------------------------------------
# 6. Application
# --------------------------------------

echo
echo "[6/7] Deploying application..."

kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/hpa.yaml
kubectl apply -f kubernetes/ingress.yaml

# --------------------------------------
# 7. Verify
# --------------------------------------

echo
echo "[7/7] Verifying application..."

kubectl rollout status deployment/devops-cicd-frontend \
    --timeout=120s

echo
echo "======================================"
echo " Kubernetes Setup Completed"
echo "======================================"

echo
echo "Cluster:"
kind get clusters

echo
echo "Pods:"
kubectl get pods

echo
echo "Service:"
kubectl get svc devops-cicd-frontend

echo
echo "HPA:"
kubectl get hpa

echo
echo "Ingress:"
kubectl get ingress

echo
echo "======================================"
echo " Local Application"
echo "======================================"
echo
echo "URL: http://localhost:8081"
echo "Host: devops.local"
echo
