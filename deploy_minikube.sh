#!/bin/bash

IMAGE_NAME=project:latest # Name of docker image. Ensure this is the same as the name in .k8s/overlays/dev/deployment-project.yaml
APP_NAME=project
NAMESPACE=garykong

# Start up Minikube
echo -e "\nStarting Minikube..."
minikube start --kubernetes-version=v1.27.3 --memory 4096 --cpus 4

# Setup docker daemon to build with Minikube
echo -e "\nSetting up docker daemon to build with Minikube..."
eval $(minikube docker-env)

# Install dependencies for pytest
poetry install --no-root

# Run tests
echo -e "\nRunning tests..."
poetry run pytest -p no:warnings

# Build docker image
echo -e "\nBuilding docker image..."
docker build -t ${IMAGE_NAME} .

# Configure kubectl to use Minikube
echo -e "\nConfiguring kubectl to use Minikube..."
kubectl config use-context minikube

# Apply Deployments and Services
echo -e "\nApplying K8s deployments and services..."
kubectl apply -k .k8s/overlays/dev

# Wait for pods to be ready
echo -e "\nWaiting for pods to be ready..."
while [[ "$(kubectl get deployments $APP_NAME -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')" != "3" ]]; do
    echo "Waiting for pods to be ready..."
    sleep 5
done

# Create minikube tunnel
echo -e "\nChecking for minikube tunnel process..."
MINIKUBE_TUNNEL_PID=$(ps -ef | grep "minikube tunnel" | grep -v grep | awk '{print $2}')
if [ -z "$MINIKUBE_TUNNEL_PID" ]
then
    echo -e "\nNo minikube tunnel process found. Creating one..."
else
    echo -e "\nFound minikube tunnel process. Killing it and creating a new one..."
    sudo kill -9 $MINIKUBE_TUNNEL_PID
fi
sudo minikube tunnel -c &
MINIKUBE_TUNNEL_PID=$!
echo -e "Minikube tunnel process created with PID: $MINIKUBE_TUNNEL_PID"

# Retrieve External IP and Port
EXTERNAL_IP=""
EXTERNAL_PORT=""
while [[ -z $EXTERNAL_IP || -z $EXTERNAL_PORT ]]; do
    echo -e "\nWaiting for external IP and Port..."
    EXTERNAL_IP=$(kubectl get svc project --namespace=$NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    EXTERNAL_PORT=$(kubectl get svc project --namespace=$NAMESPACE -o jsonpath='{.spec.ports[0].port}')
    sleep 5
done
echo -e "Found External IP: $EXTERNAL_IP. Port: $EXTERNAL_PORT"

# Check if API is accessible
echo -e "\nChecking if API is accessible..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' $EXTERNAL_IP:$EXTERNAL_PORT/health)" != "200" ]]; do
    echo "Waiting for API to be accessible..."
    sleep 5
done
echo -e "\nAPI is accessible at http://$EXTERNAL_IP:$EXTERNAL_PORT/health"

# Validate project-predict endpoint
echo -e "\nTesting '/project-predict' endpoint with valid input"
INPUT='{"text": ["I hate you.", "I love you."]}'

RESPONSE=$(curl -s -X POST "http://$EXTERNAL_IP:$EXTERNAL_PORT/project-predict" \
    -H "Content-Type: application/json" \
    -d "$INPUT" \
    -w "\nHTTP Status Code: %{http_code}")

RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

echo -e "\nInput: $INPUT"
echo -e "\nResponse Body: $RESPONSE_BODY"
echo -e "\n$HTTP_STATUS"

# Cleanup
echo -e "\n"
read -p "Press enter to start cleanup..."
echo -e "\nCleaning up..."
echo -e "\nKilling minikube tunnel process..."
MINIKUBE_TUNNEL_PID=$(ps -ef | grep "minikube tunnel" | grep -v grep | awk '{print $2}')
sudo kill -9 $MINIKUBE_TUNNEL_PID

echo -e "\nDeleting all resources in namespace..."
kubectl delete all --all -n $NAMESPACE

echo -e "\nDeleting namespace..."
kubectl delete namespace $NAMESPACE

echo -e "\nStopping Minikube..."
minikube stop --all