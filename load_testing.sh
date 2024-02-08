#!/bin/bash

NAMESPACE=garykong
APP_NAME=project

# Configure kubectl to use AKS cluster
echo -e "\nConfiguring kubectl to use AKS cluster..."
az aks get-credentials --resource-group w255 --name w255-aks --overwrite-existing

# Set the namespace to be garykong
echo -e "\nSetting namespace to be garykong..."
kubectl config set-context --current --namespace=$NAMESPACE

# Port forward Grafana
echo -e "\nPort forwarding Grafana..."
kubectl port-forward -n prometheus svc/grafana 3000:3000 &

# Deploy production deployment and service
echo -e "\nDeploying production deployment and service..."
kubectl apply -k .k8s/overlays/prod -n $NAMESPACE

# Get name of Redis pod
echo -e "\nGetting name of Redis pod..."
REDIS_POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=redis -o jsonpath="{.items[0].metadata.name}")
echo -e "\nRedis pod name: $REDIS_POD_NAME"

# Flush Redis cache
echo -e "\nFlushing Redis cache..."
kubectl exec -n $NAMESPACE -it $REDIS_POD_NAME -- redis-cli FLUSHDB

# # Wait until the number of replicas = minpods
# while [[ "$(kubectl get hpa $APP_NAME -n $NAMESPACE -o jsonpath='{.status.currentReplicas}')" != "$(kubectl get hpa $APP_NAME -n $NAMESPACE -o jsonpath='{.spec.minReplicas}')" ]]; do
#     echo "Waiting until the number of replicas = minpods..."
#     echo "Current replicas: $(kubectl get hpa $APP_NAME -n $NAMESPACE -o jsonpath='{.status.currentReplicas}')"
#     sleep 5
# done

# Run K6 using load.js
echo -e "\nRunning K6 using load.js..."
k6 run --env NAMESPACE=$NAMESPACE load.js