#!/bin/bash

set -e

echo "======================================"
echo " Kubernetes Ingress Controller Setup"
echo "======================================"

INGRESS_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

# --------------------------------------
# 1. Check kubectl
# --------------------------------------

echo
echo "[1/5] Checking kubectl..."

if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is not installed."
    exit 1
fi

echo "kubectl: AVAILABLE"

# --------------------------------------
# 2. Check Kubernetes cluster
# --------------------------------------

echo
echo "[2/5] Checking Kubernetes cluster..."

if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "ERROR: Kubernetes cluster is not reachable."
    exit 1
fi

CURRENT_CONTEXT=$(kubectl config current-context)

echo "Context: $CURRENT_CONTEXT"

# --------------------------------------
# 3. Verify kind cluster
# --------------------------------------

echo
echo "[3/5] Checking kind cluster..."

if [[ "$CURRENT_CONTEXT" != kind-* ]]; then
    echo "ERROR: This script is intended for a kind cluster."
    echo "Current context: $CURRENT_CONTEXT"
    exit 1
fi

echo "kind cluster: DETECTED"

# --------------------------------------
# 4. Install Ingress Controller
# --------------------------------------

echo
echo "[4/5] Installing NGINX Ingress Controller..."

if kubectl get deployment ingress-nginx-controller \
    -n ingress-nginx >/dev/null 2>&1; then

    echo "Ingress Controller: ALREADY INSTALLED"

else

    kubectl apply -f "$INGRESS_URL"

    echo "Ingress Controller: INSTALLING"

fi

# --------------------------------------
# 5. Wait and verify
# --------------------------------------

echo
echo "[5/5] Waiting for Ingress Controller..."

kubectl wait \
    --namespace ingress-nginx \
    --for=condition=Ready \
    pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=180s

echo
echo "Ingress Controller: READY"

echo
echo "Ingress Class:"
kubectl get ingressclass

echo
echo "Ingress Controller:"
kubectl get pods -n ingress-nginx

echo
echo "Service:"
kubectl get svc -n ingress-nginx

echo
echo "======================================"
echo " Ingress Controller Ready"
echo "======================================"
