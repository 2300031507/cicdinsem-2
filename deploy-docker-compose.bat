@echo off
echo 🚀 Starting Event Management System Deployment with Docker Compose...
echo ===============================================================

REM Check if Docker is running
echo [INFO] Checking Docker status...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running. Please start Docker Desktop first.
    exit /b 1
)

REM Check if Docker Compose is available
echo [INFO] Checking Docker Compose...
docker compose version >nul 2>&1
if %errorlevel% equ 0 (
    set COMPOSE_CMD=docker compose
) else (
    docker-compose --version >nul 2>&1
    if %errorlevel% equ 0 (
        set COMPOSE_CMD=docker-compose
    ) else (
        echo [ERROR] Docker Compose is not available. Please install Docker Compose.
        exit /b 1
    )
)

REM Build and start services
echo [INFO] Building Docker images...
%COMPOSE_CMD% build
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build Docker images.
    exit /b 1
)

echo [INFO] Starting services...
%COMPOSE_CMD% up -d
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start services.
    exit /b 1
)

echo [INFO] Waiting for services to be ready...
echo This may take a few minutes...

REM Wait for services (simplified for Windows)
timeout /t 30 /nobreak >nul

echo [INFO] Deployment Status:
%COMPOSE_CMD% ps

echo.
echo 🎉 Event Management System deployed successfully with Docker Compose!
echo ===============================================================
echo.
echo 📋 Access URLs:
echo    • Frontend: http://localhost:3000
echo    • Backend API: http://localhost:2025/back2
echo    • Database: MySQL on localhost:3306
echo.
echo 🔧 Useful Commands:
echo    • View logs: %COMPOSE_CMD% logs -f
echo    • Stop services: %COMPOSE_CMD% down
echo    • Restart services: %COMPOSE_CMD% restart
echo    • View status: %COMPOSE_CMD% ps
echo.
echo ⏱️  Note: Services may take a few more minutes to be fully ready.

REM Test connectivity
echo [INFO] Testing backend connectivity...
curl -s "http://localhost:2025/back2" >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] ✅ Backend is accessible!
) else (
    echo [WARNING] ⚠️  Backend may still be starting. Please wait a moment and try: curl http://localhost:2025/back2
)

echo [INFO] Testing frontend connectivity...
curl -s "http://localhost:3000" >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] ✅ Frontend is accessible!
) else (
    echo [WARNING] ⚠️  Frontend may still be starting. Please wait a moment and try: curl http://localhost:3000
)

echo.
echo Deployment complete! Check the URLs above to access your application.