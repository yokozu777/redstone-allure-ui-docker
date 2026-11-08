#!/bin/bash

# build-and-run.sh
echo "🚀 Начинаем сборку и запуск Allure Docker Service..."

# Остановка и удаление существующих контейнеров
echo "🛑 Останавливаем существующие контейнеры..."
docker stop allure-api allure-ui 2>/dev/null || true
docker rm allure-api allure-ui 2>/dev/null || true

# Сборка API образа
echo "🔨 Собираем API образ..."
cd allure-api
docker build -t allure-api-fork -f docker-custom/Dockerfile.bionic-custom \
  --build-arg BUILD_DATE=na \
  --build-arg BUILD_VERSION=na \
  --build-arg BUILD_REF=na \
  --build-arg ALLURE_RELEASE=2.27.0 .

if [ $? -ne 0 ]; then
    echo "❌ Ошибка при сборке API образа"
    exit 1
fi

# Сборка UI образа
echo "🔨 Собираем UI образ..."
cd ../allure-fork
docker build -t allure-ui-fork -f docker/Dockerfile \
  --build-arg VERSION=na \
  --build-arg VCS_REF=na \
  --build-arg BUILD_DATE=na .

if [ $? -ne 0 ]; then
    echo "❌ Ошибка при сборке UI образа"
    exit 1
fi

# Создание папки для проектов
echo "📁 Создаем папку для проектов..."
cd ..
mkdir -p projects

# Запуск API контейнера
echo "🚀 Запускаем API контейнер..."
docker run -d -p 5050:5050 \
  -e CHECK_RESULTS_EVERY_SECONDS=NONE \
  -e KEEP_HISTORY=1 \
  -v "$(pwd)/projects:/app/projects" \
  --name allure-api \
  allure-api-fork

# Ожидание запуска API
echo "⏳ Ожидаем запуска API..."
sleep 10

# Запуск UI контейнера
echo "🚀 Запускаем UI контейнер..."
docker run -d -p 5252:5252 \
  -e ALLURE_DOCKER_PUBLIC_API_URL=http://localhost:5050 \
  --name allure-ui \
  allure-ui-fork

# Проверка статуса
echo "✅ Проверяем статус контейнеров..."
docker ps

echo "🎉 Готово! Доступ к приложению:"
echo "   Allure UI: http://localhost:5252/allure-docker-service-ui"
echo "   Allure API: http://localhost:5050/allure-docker-service"
