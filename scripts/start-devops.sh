#!/bin/bash

set -e

echo "======================================"
echo " Starting DevOps Local Environment"
echo "======================================"

PROJECT_ROOT="$HOME/project/devops-cicd-platform"

# --------------------------------------
# 1. Docker
# --------------------------------------

echo
echo "[1/4] Checking Docker..."

if docker info >/dev/null 2>&1; then
    echo "Docker: RUNNING"
else
    echo "Docker: NOT RUNNING"

    if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl start docker
    fi

    sleep 3

    if ! docker info >/dev/null 2>&1; then
        echo "ERROR: Docker could not be started."
        exit 1
    fi

    echo "Docker: STARTED"
fi


# --------------------------------------
# 2. Jenkins
# --------------------------------------

echo
echo "[2/4] Checking Jenkins..."

if systemctl is-active --quiet jenkins; then
    echo "Jenkins: RUNNING"
else
    echo "Jenkins: NOT RUNNING"
    sudo systemctl start jenkins
    sleep 3

    if systemctl is-active --quiet jenkins; then
        echo "Jenkins: STARTED"
    else
        echo "ERROR: Jenkins could not be started."
        exit 1
    fi
fi


# --------------------------------------
# 3. kind Kubernetes cluster
# --------------------------------------

echo
echo "[3/4] Checking Kubernetes..."

if ! command -v kind >/dev/null 2>&1; then
    echo "ERROR: kind is not installed."
    exit 1
fi

CLUSTER_NAME="devops-cluster"

if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then

    echo "kind cluster '$CLUSTER_NAME': EXISTS"

else

    echo "kind cluster '$CLUSTER_NAME': NOT FOUND"
    echo "Creating cluster..."

    kind create cluster --name "$CLUSTER_NAME"

fi

kubectl config use-context "kind-$CLUSTER_NAME" >/dev/null

if kubectl get nodes >/dev/null 2>&1; then
    echo "Kubernetes: READY"
else
    echo "ERROR: Kubernetes cluster is not ready."
    exit 1
fi


# --------------------------------------
# 4. ngrok
# --------------------------------------

echo
echo "[4/4] Checking ngrok..."

if command -v ngrok >/dev/null 2>&1; then

    if pgrep -x ngrok >/dev/null 2>&1; then
        echo "ngrok: RUNNING"
    else
        echo "ngrok: NOT RUNNING"
        echo "Starting ngrok..."

        nohup ngrok http 8080 \
            > "$HOME/ngrok.log" 2>&1 &

        sleep 3

        if pgrep -x ngrok >/dev/null 2>&1; then
            echo "ngrok: STARTED"
        else
            echo "WARNING: ngrok failed to start."
            echo "Check: $HOME/ngrok.log"
        fi
    fi

else
    echo "WARNING: ngrok is not installed."
fi


# --------------------------------------
# Final status
# --------------------------------------

echo
echo "======================================"
echo " DevOps Environment Ready"
echo "======================================"

echo
echo "Docker:"
docker --version

echo
echo "Jenkins:"
systemctl is-active jenkins

echo
echo "Kubernetes:"
kubectl config current-context
kubectl get nodes

echo
echo "ngrok:"
if pgrep -x ngrok >/dev/null 2>&1; then
    echo "RUNNING"
else
    echo "NOT RUNNING"
fi

echo
echo "Project:"
echo "$PROJECT_ROOT"

echo
echo "======================================"
echo " Ready to Work 🚀"
echo "======================================"
