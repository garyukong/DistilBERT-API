#!/bin/bash

TENANT_ID=cba533e6-d004-4e85-8d96-8f0a22c908a5
IMAGE_NAME=project
ACR_DOMAIN=w255mids.azurecr.io

# Login to ACR
echo -e "\nLogging in to ACR..."
az login --tenant $TENANT_ID
az acr login --name w255mids

# Get the short commit hash using git
echo -e "\nGetting short commit hash..."
COMMIT_HASH=$(git rev-parse --short HEAD)
echo -e "Commit hash: $COMMIT_HASH"

# Get the image prefix
echo -e "\nGetting image prefix..."
IMAGE_PREFIX=$(az account list --all | jq '.[].user.name' | grep -i berkeley.edu | awk -F@ '{print $1}' | tr -d '"' | tr -d "." | tr '[:upper:]' '[:lower:]' | tr '_' '-' | uniq)
echo -e "Image prefix: $IMAGE_PREFIX"

# Set the image name
echo -e "\nSetting image name..."
echo -e "Image name: $IMAGE_NAME"

# FQDN = Fully-Qualified Domain Name
echo -e "\nSetting FQDN..."
IMAGE_FQDN="${ACR_DOMAIN}/${IMAGE_PREFIX}/${IMAGE_NAME}"
echo -e "Image FQDN: $IMAGE_FQDN"

# Set the image tag
echo -e "\nSetting image tag..."
IMAGE_TAG="${IMAGE_FQDN}:${COMMIT_HASH}"
echo -e "Image tag: $IMAGE_TAG"

# Build the Docker image with the short commit hash as the tag
echo -e "\nBuilding docker image..."
docker build --platform linux/amd64 -t ${IMAGE_TAG} .

# Push the Docker image to ACR
echo -e "\nPushing docker image to ACR..."
docker push ${IMAGE_TAG}

# Confirm the image has been pushed by pulling
echo -e "\nConfirming image has been pushed by pulling..."
docker pull ${IMAGE_TAG}

# Replace [IMAGE_TAG] with the generated image tag in patch-deployment-project.yaml
echo -e "\nReplacing [IMAGE_TAG] with the generated image tag..."
sed "s|\[IMAGE_TAG\]|${IMAGE_TAG}|g" .k8s/overlays/prod/patch-deployment-project_copy.yaml > .k8s/overlays/prod/patch-deployment-project.yaml