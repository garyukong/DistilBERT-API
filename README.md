# A Full End-to-End Machine Learning API

## Overview

This project demonstrates a fully functional prediction API that leverages the DistilBERT model from Hugging Face for sentiment analysis. It encompasses an end-to-end machine learning pipeline, including model packaging, API creation with FastAPI, result caching with Redis, containerization with Docker, and deployment to Azure using Kubernetes.

## Objectives

- Package DistilBERT for efficient CPU-based sentiment analysis.
- Serve prediction results through a FastAPI application.
- Ensure application robustness with pytest.
- Containerize the application for scalable deployment.
- Implement Redis caching for endpoint protection.
- Automate deployment to Azure Kubernetes Service (AKS).
- Monitor application performance with Grafana.

## Key Features

- **Pydantic Models**: Input and output models designed to match specific structures for API requests and responses.
- **Model Management**: DistilBERT model is managed locally to optimize loading times and integrated into the application build process.
- **Testing and Deployment**: Comprehensive pytest suite and Docker-based deployment streamlined for AKS.
- **Performance Monitoring**: Utilization of K6 and Grafana for load testing and performance analysis.

## Getting Started

1. **Clone the Repository**: Access all necessary files for local setup and deployment.
2. **Install Dependencies**: Use Poetry for Python dependency management, utilizing the `pyproject.toml` file which specifies project dependencies.
3. **Run Locally**: To test the application's functionality locally, execute `deploy_minikube.sh` for a Minikube deployment.
4. **Deploy to Azure**: For Azure deployment, utilize `deploy_azure.sh` following the Azure Kubernetes Service (AKS) setup instructions.
5. **Load Testing**: Conduct load testing by running `load_testing.sh`, which simulates traffic to your deployed application.

## Project Organization
