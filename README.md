# Allure Docker Service UI — Build and Run

This project contains updated Allure Docker Service API and UI images with current Node.js, Python, and JDK versions.

## Quick start

### Prerequisites

- Docker Desktop installed and running
- Git (to clone the repository)

### Automatic start

#### Windows
```powershell
.\build-and-run.ps1
```

#### macOS/Linux
```bash
chmod +x build-and-run.sh
./build-and-run.sh
```

#### Docker Compose (all operating systems)
```bash
docker-compose up --build -d
```

### 1. Clone the repository

```bash
git clone https://github.com/Valiantsin2021/allure-docker-service-ui.git
cd allure-docker-service-ui
```

### 2. Build the images

#### Build the API image

```bash
cd allure-api
docker build -t allure-api-fork -f docker-custom/Dockerfile.bionic-custom \
  --build-arg BUILD_DATE=na \
  --build-arg BUILD_VERSION=na \
  --build-arg BUILD_REF=na \
  --build-arg ALLURE_RELEASE=2.27.0 .
```

#### Build the UI image

```bash
cd ../allure-fork
docker build -t allure-ui-fork -f docker/Dockerfile \
  --build-arg VERSION=na \
  --build-arg VCS_REF=na \
  --build-arg BUILD_DATE=na .
```

### 3. Start the containers

#### Start the API container

```bash
docker run -d -p 5050:5050 \
  -e CHECK_RESULTS_EVERY_SECONDS=NONE \
  -e KEEP_HISTORY=1 \
  -v ${PWD}/projects:/app/projects \
  --name allure-api \
  allure-api-fork
```

#### Start the UI container

```bash
docker run -d -p 5252:5252 \
  -e ALLURE_DOCKER_PUBLIC_API_URL=http://localhost:5050 \
  --name allure-ui \
  allure-ui-fork
```

### 4. Check the status

```bash
docker ps
```

## Full build and run scripts

### Windows (PowerShell)

Create `build-and-run.ps1` in the project root:

```powershell
# build-and-run.ps1
Write-Host "🚀 Building and starting Allure Docker Service..." -ForegroundColor Green

# Stop and remove existing containers
Write-Host "🛑 Stopping existing containers..." -ForegroundColor Yellow
docker stop allure-api allure-ui 2>$null
docker rm allure-api allure-ui 2>$null

# Build the API image
Write-Host "🔨 Building the API image..." -ForegroundColor Yellow
cd allure-api
docker build -t allure-api-fork -f docker-custom/Dockerfile.bionic-custom --build-arg BUILD_DATE=na --build-arg BUILD_VERSION=na --build-arg BUILD_REF=na --build-arg ALLURE_RELEASE=2.27.0 .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ API image build failed" -ForegroundColor Red
    exit 1
}

# Build the UI image
Write-Host "🔨 Building the UI image..." -ForegroundColor Yellow
cd ../allure-fork
docker build -t allure-ui-fork -f docker/Dockerfile --build-arg VERSION=na --build-arg VCS_REF=na --build-arg BUILD_DATE=na .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ UI image build failed" -ForegroundColor Red
    exit 1
}

# Create the projects directory
Write-Host "📁 Creating the projects directory..." -ForegroundColor Yellow
cd ..
mkdir -p projects

# Start the API container
Write-Host "🚀 Starting the API container..." -ForegroundColor Yellow
docker run -d -p 5050:5050 -e CHECK_RESULTS_EVERY_SECONDS=NONE -e KEEP_HISTORY=1 -v ${PWD}/projects:/app/projects --name allure-api allure-api-fork

# Wait for the API to start
Write-Host "⏳ Waiting for the API..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Start the UI container
Write-Host "🚀 Starting the UI container..." -ForegroundColor Yellow
docker run -d -p 5252:5252 -e ALLURE_DOCKER_PUBLIC_API_URL=http://localhost:5050 --name allure-ui allure-ui-fork

# Check the status
Write-Host "✅ Checking container status..." -ForegroundColor Green
docker ps

Write-Host "🎉 Done. Open the application:" -ForegroundColor Green
Write-Host "   Allure UI: http://localhost:5252/allure-docker-service-ui" -ForegroundColor Cyan
Write-Host "   Allure API: http://localhost:5050/allure-docker-service" -ForegroundColor Cyan
```

Run the script:

```powershell
.\build-and-run.ps1
```

### macOS/Linux (Bash)

Create `build-and-run.sh` in the project root:

```bash
#!/bin/bash

# build-and-run.sh
echo "🚀 Building and starting Allure Docker Service..."

# Stop and remove existing containers
echo "🛑 Stopping existing containers..."
docker stop allure-api allure-ui 2>/dev/null || true
docker rm allure-api allure-ui 2>/dev/null || true

# Build the API image
echo "🔨 Building the API image..."
cd allure-api
docker build -t allure-api-fork -f docker-custom/Dockerfile.bionic-custom \
  --build-arg BUILD_DATE=na \
  --build-arg BUILD_VERSION=na \
  --build-arg BUILD_REF=na \
  --build-arg ALLURE_RELEASE=2.27.0 .

if [ $? -ne 0 ]; then
    echo "❌ API image build failed"
    exit 1
fi

# Build the UI image
echo "🔨 Building the UI image..."
cd ../allure-fork
docker build -t allure-ui-fork -f docker/Dockerfile \
  --build-arg VERSION=na \
  --build-arg VCS_REF=na \
  --build-arg BUILD_DATE=na .

if [ $? -ne 0 ]; then
    echo "❌ UI image build failed"
    exit 1
fi

# Create the projects directory
echo "📁 Creating the projects directory..."
cd ..
mkdir -p projects

# Start the API container
echo "🚀 Starting the API container..."
docker run -d -p 5050:5050 \
  -e CHECK_RESULTS_EVERY_SECONDS=NONE \
  -e KEEP_HISTORY=1 \
  -v "$(pwd)/projects:/app/projects" \
  --name allure-api \
  allure-api-fork

# Wait for the API to start
echo "⏳ Waiting for the API..."
sleep 10

# Start the UI container
echo "🚀 Starting the UI container..."
docker run -d -p 5252:5252 \
  -e ALLURE_DOCKER_PUBLIC_API_URL=http://localhost:5050 \
  --name allure-ui \
  allure-ui-fork

# Check the status
echo "✅ Checking container status..."
docker ps

echo "🎉 Done. Open the application:"
echo "   Allure UI: http://localhost:5252/allure-docker-service-ui"
echo "   Allure API: http://localhost:5050/allure-docker-service"
```

Make the script executable and run it:

```bash
chmod +x build-and-run.sh
./build-and-run.sh
```

## Docker Compose (alternative)

`docker-compose.yml` is already in the project root. The UI URL is `http://localhost:5050` because the browser calls the API; the Docker network name `allure-api` does not resolve on the host.

```yaml
services:
  allure-api:
    build:
      context: ./allure-api
      dockerfile: docker-custom/Dockerfile.bionic-custom
      args:
        BUILD_DATE: na
        BUILD_VERSION: na
        BUILD_REF: na
        ALLURE_RELEASE: 2.27.0
    environment:
      CHECK_RESULTS_EVERY_SECONDS: NONE
      KEEP_HISTORY: 1
      KEEP_HISTORY_LATEST: 25
    ports:
      - "5050:5050"
    volumes:
      - ./projects:/app/projects
    container_name: allure-api
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5050/allure-docker-service/version"]
      interval: 30s
      timeout: 10s
      retries: 3

  allure-ui:
    build:
      context: ./allure-fork
      dockerfile: docker/Dockerfile
      args:
        VERSION: na
        VCS_REF: na
        BUILD_DATE: na
    environment:
      ALLURE_DOCKER_PUBLIC_API_URL: "http://localhost:5050"
      ALLURE_DOCKER_PUBLIC_API_URL_PREFIX: ""
    ports:
      - "5252:5252"
    depends_on:
      allure-api:
        condition: service_healthy
    container_name: allure-ui
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5252/allure-docker-service-ui"]
      interval: 30s
      timeout: 10s
      retries: 3
```

Start with Docker Compose:

```bash
docker-compose up --build -d
```

## Container management

### View logs

```bash
# API logs
docker logs allure-api

# UI logs
docker logs allure-ui

# Follow the logs
docker logs -f allure-api
docker logs -f allure-ui
```

### Stop the containers

```bash
docker stop allure-api allure-ui
```

### Remove the containers

```bash
docker rm allure-api allure-ui
```

### Remove the images

```bash
docker rmi allure-api-fork allure-ui-fork
```

## Monitoring

### Check container health

```bash
docker ps
```

### Check resource usage

```bash
docker stats allure-api allure-ui
```

## Technical details

### Updated components

- **Node.js**: 24.8.0-trixie-slim (was 12.18.3-buster-slim)
- **Python**: 3.12 (was 3.13, for compatibility)
- **JDK**: eclipse-temurin:11.0.28_6-jre-noble (was adoptopenjdk:11-jre-openj9-bionic)
- **Base OS**: Ubuntu Noble 24.04 (was Buster 10)

### Issues fixed

- Compatibility with current Docker versions
- Python package installation on Ubuntu Noble
- Conflicts with the system pip and wheel packages
- User and group creation

## Open the application

After the containers start:

- **Allure UI**: http://localhost:5252/allure-docker-service-ui
- **Allure API**: http://localhost:5050/allure-docker-service

## Notes

- Ports 5050 and 5252 must be free
- Use HTTPS in production
- Docker creates `projects/` on startup and stores Allure reports there. Do not commit that directory
