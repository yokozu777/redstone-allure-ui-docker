
docker stop allure-api allure-ui 2>$null
docker rm allure-api allure-ui 2>$null


cd allure-api
docker build -t allure-api-fork -f docker-custom/Dockerfile.bionic-custom --build-arg BUILD_DATE=na --build-arg BUILD_VERSION=na --build-arg BUILD_REF=na --build-arg ALLURE_RELEASE=2.27.0 .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Ошибка при сборке API образа" -ForegroundColor Red
    exit 1
}


cd ../allure-fork
docker build -t allure-ui-fork -f docker/Dockerfile --build-arg VERSION=na --build-arg VCS_REF=na --build-arg BUILD_DATE=na .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Ошибка при сборке UI образа" -ForegroundColor Red
    exit 1
}


cd ..
if (!(Test-Path "projects")) {
    New-Item -ItemType Directory -Name "projects"
}


docker run -d -p 5050:5050 -e CHECK_RESULTS_EVERY_SECONDS=NONE -e KEEP_HISTORY=1 -v "${PWD}/projects:/app/projects" --name allure-api allure-api-fork


Start-Sleep -Seconds 10


docker run -d -p 5252:5252 -e ALLURE_DOCKER_PUBLIC_API_URL=http://localhost:5050 --name allure-ui allure-ui-fork


docker ps


Write-Host "   Allure UI: http://localhost:5252/allure-docker-service-ui" -ForegroundColor Cyan
Write-Host "   Allure API: http://localhost:5050/allure-docker-service" -ForegroundColor Cyan
