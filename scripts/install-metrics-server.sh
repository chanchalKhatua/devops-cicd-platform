#!/bin/bash

set -e

echo "======================================"
echo " Kubernetes Metrics Server Setup"
echo "======================================"

# --------------------------------------
# Configuration
# --------------------------------------

METRICS_SERVER_URL="https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"

# --------------------------------------
# Check kubectl
# --------------------------------------

echo
echo "[1/5] Checking kubectl..."

if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is not installed."
    exit 1
fi

echo "kubectl: AVAILABLE"

# --------------------------------------
# Check Kubernetes cluster
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
# Install Metrics Server
# --------------------------------------

echo
echo "[3/5] Installing Metrics Server..."

if kubectl get deployment metrics-server -n kube-system >/dev/null 2>&1; then
    echo "Metrics Server: ALREADY INSTALLED"
else
    echo "Metrics Server: INSTALLING..."

    kubectl apply -f "$METRICS_SERVER_URL"

    echo "Metrics Server: INSTALLED"
fi

# --------------------------------------
# Configure kind
# --------------------------------------

if [[ "$CURRENT_CONTEXT" == kind-* ]]; then

    echo
    echo "Local kind cluster detected."
    echo "Configuring kubelet TLS..."

    if kubectl get deployment metrics-server -n kube-system \
        -o jsonpath='{.spec.template.spec.containers[0].args}' \
        | grep -q -- "--kubelet-insecure-tls"; then

        echo "kubelet-insecure-tls: ALREADY CONFIGURED"

    else

        kubectl patch deployment metrics-server \
            -n kube-system \
            --type='json' \
            -p='[
              {
                "op": "add",
                "path": "/spec/template/spec/containers/0/args/-",
                "value": "--kubelet-insecure-tls"
              }
            ]'

        echo "kubelet-insecure-tls: CONFIGURED"
    fi

else

    echo
    echo "Non-kind cluster detected."
    echo "Skipping insecure TLS configuration."

fi

# --------------------------------------
# Wait for Metrics Server
# --------------------------------------

echo
echo "[4/5] Waiting for Metrics Server..."

kubectl rollout status deployment/metrics-server \
    -n kube-system \
    --timeout=120s

echo "Metrics Server: READY"

# --------------------------------------
# Verify metrics
# --------------------------------------

echo
echo "[5/5] Verifying Metrics API..."

echo
echo "Checking node metrics..."

if kubectl top nodes >/dev/null 2>&1; then
    echo "Node metrics: AVAILABLE"
else
    echo "ERROR: Node metrics are not available."
    exit 1
fi

echo
echo "Checking Pod metrics..."

if kubectl top pods >/dev/null 2>&1; then
    echo "Pod metrics: AVAILABLE"
else
    echo "ERROR: Pod metrics are not available."
    exit 1
fi

echo
echo "======================================"
echo " Metrics Server Ready"
echo "======================================"

echo
echo "Context:"
echo "$CURRENT_CONTEXT"

echo
echo "Metrics Server:"
kubectl get pods -n kube-system | grep metrics-server

echo
echo "Node Metrics:"
kubectl top nodes

echo
echo "Pod Metrics:"
kubectl top pods

echo
echo "======================================"
echo " Setup Completed Successfully"
echo "======================================"
