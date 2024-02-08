# Sets an argument for the application directory
ARG APP_DIR=/app

# First stage: build
# ---------------------------------------------
# Get the base image: Python 3.10 slim
FROM python:3.10-slim as build
ARG APP_DIR
LABEL stage=build-stage

# Install curl and build dependencies, and remove apt cache
RUN apt-get update \
    && apt-get install -y \
         curl \
         build-essential \
         libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Install poetry
ENV POETRY_VERSION="1.6.1"
RUN curl -sSL https://install.python-poetry.org | python3.10 -
ENV PATH /root/.local/bin:$PATH

# Set the working directory in the container
WORKDIR ${APP_DIR}

# Copy the poetry.lock and pyproject.toml files to the container
COPY poetry.lock pyproject.toml ./

# Copy over the venv including any symbolic links
RUN python -m venv ${APP_DIR}/venv --copies

# Activate virtual environment and install dependencies (no development dependencies)
RUN . ${APP_DIR}/venv/bin/activate && poetry install --only main

# Second stage: deploy
# ---------------------------------------------
# Get the base image: Python 3.10 slim
FROM python:3.10-slim AS deploy
ARG APP_DIR
LABEL stage=deploy-stage

# Set work directory
WORKDIR ${APP_DIR}

# Copy virtual environment from build stage
COPY --from=build ${APP_DIR}/venv ${APP_DIR}/venv
ENV PATH=${APP_DIR}/venv/bin:$PATH

# Copy source code
COPY . .

# Expose the application port
EXPOSE 8000

# Run Uvicorn, the API
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]