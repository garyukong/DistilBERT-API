#!/bin/bash

NAMESPACE=garykong
APP_NAME=project

# Build and push the image by running ./scripts/build_push_image.sh
echo -e "\nBuilding and pushing the image..."
./scripts/build_push_image.sh

# Configure kubectl to use AKS cluster
echo -e "\nConfiguring kubectl to use AKS cluster..."
az aks get-credentials --resource-group w255 --name w255-aks --overwrite-existing

# Set the namespace to be garykong
echo -e "\nSetting namespace to be garykong..."
kubectl config set-context --current --namespace=$NAMESPACE

# Wait for nodes to be ready
echo -e "\nChecking that nodes are ready and available..."
kubectl get nodes

# Deploy production deployment and service
echo -e "\nDeploying production deployment and service..."
kubectl apply -k .k8s/overlays/prod -n $NAMESPACE

# Wait for pods to be ready
echo -e "\nWaiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=$APP_NAME -n $NAMESPACE --timeout=60s
kubectl wait --for=condition=ready pod -l app=redis -n $NAMESPACE --timeout=60s

# Curl the health endpoint
echo -e "\nTesting the '/health' endpoint..."
curl -o /dev/null -s -w "%{http_code}\n" -X GET "https://$NAMESPACE.mids255.com/health"

# Curl the /docs endpoint
echo -e "\nTesting the '/docs' endpoint..."
curl -o /dev/null -s -w "%{http_code}\n" -X GET "https://$NAMESPACE.mids255.com/docs"

# Curl the /openapi.json endpoint
echo -e "\nTesting the '/openapi.json' endpoint..."
curl -o /dev/null -s -w "%{http_code}\n" -X GET "https://$NAMESPACE.mids255.com/openapi.json"

# Validate project-predict endpoint
echo -e "\nTesting '/project-predict' endpoint with valid input"
INPUT='{"text": ["I hate you.", "I love you."]}'

RESPONSE=$(curl -s -X POST "https://$NAMESPACE.mids255.com/project-predict" \
    -H "Content-Type: application/json" \
    -d "$INPUT" \
    -w "\nHTTP Status Code: %{http_code}")

RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

echo -e "\nInput: $INPUT"
echo -e "\nResponse Body: $RESPONSE_BODY"
echo -e "\n$HTTP_STATUS"
