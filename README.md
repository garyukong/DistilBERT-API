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
2. **Install Dependencies**: Utilize Poetry for Python dependency management.
3. **Run Locally**: Test the application's functionality using pytest and Docker.
4. **Deploy to Azure**: Follow the instructions for AKS deployment and monitoring setup.

## Project Organization
