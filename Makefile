# Variables
SERVER_DIR = Server
MOBILE_DIR = NguyenQuangHung
DOCKER_COMPOSE_FILE = $(SERVER_DIR)/docker-compose.yml
DOCKER_COMPOSE = docker compose -f $(DOCKER_COMPOSE_FILE)

.PHONY: all help setup clean \
        up down restart logs ps docker-clean \
        server server-dev server-build server-clean db-migrate \
        mobile mobile-devices mobile-pub-get mobile-clean mobile-apk

# Default target
all: help

help:
	@echo "=================================================================="
	@echo "                   LEARN LTDD EXAM - MAKEFILE                     "
	@echo "=================================================================="
	@echo " Docker (SQL Server):"
	@echo "   make up            - Khởi động SQL Server qua Docker Compose"
	@echo "   make down          - Dừng dịch vụ Docker SQL Server"
	@echo "   make restart       - Khởi động lại Docker SQL Server"
	@echo "   make logs          - Xem logs thời gian thực của Docker SQL Server"
	@echo "   make ps            - Xem trạng thái các container Docker"
	@echo "   make docker-clean  - Dừng container và xóa volume dữ liệu"
	@echo ""
	@echo " Server (.NET Web API):"
	@echo "   make server        - Chạy Server backend"
	@echo "   make server-dev    - Chạy Server backend với Hot Reload (dotnet watch)"
	@echo "   make server-build  - Build Server backend"
	@echo "   make server-clean  - Dọn dẹp build cache của Server"
	@echo "   make db-migrate    - Cập nhật database EF Core migrations"
	@echo ""
	@echo " Mobile (Flutter):"
	@echo "   make mobile        - Chạy ứng dụng Mobile Flutter"
	@echo "   make mobile-devices- Kiểm tra danh sách thiết bị/máy ảo"
	@echo "   make mobile-pub-get- Cài đặt/cập nhật flutter packages"
	@echo "   make mobile-clean  - Dọn dẹp cache build của Flutter"
	@echo "   make mobile-apk    - Build APK Android"
	@echo ""
	@echo " Chung:"
	@echo "   make setup         - Cài đặt và restore dependencies cho toàn bộ dự án"
	@echo "   make clean         - Dọn dẹp build cache của Server, Flutter và Docker"
	@echo "=================================================================="

# Docker Commands
up:
	@echo "Đang khởi động SQL Server (Docker Compose)..."
	$(DOCKER_COMPOSE) up -d

down:
	@echo "Đang dừng SQL Server (Docker Compose)..."
	$(DOCKER_COMPOSE) down

restart:
	@echo "Đang khởi động lại SQL Server..."
	$(DOCKER_COMPOSE) restart

logs:
	@echo "Đang theo dõi logs SQL Server..."
	$(DOCKER_COMPOSE) logs -f

ps:
	@echo "Trạng thái containers:"
	$(DOCKER_COMPOSE) ps

docker-clean:
	@echo "Đang dọn dẹp Docker container và volume dữ liệu..."
	$(DOCKER_COMPOSE) down -v --remove-orphans

# Server Commands
server:
	@echo "Đang khởi động Server..."
	dotnet run --project $(SERVER_DIR)

server-dev:
	@echo "Đang khởi động Server với Hot Reload..."
	dotnet watch --project $(SERVER_DIR) run

server-build:
	@echo "Đang build Server..."
	dotnet build $(SERVER_DIR)

server-clean:
	@echo "Đang dọn dẹp Server..."
	dotnet clean $(SERVER_DIR)

db-migrate:
	@echo "Đang cập nhật database EF Core..."
	dotnet ef database update --project $(SERVER_DIR)

# Mobile Commands
mobile:
	@echo "Đang chạy ứng dụng Mobile Flutter..."
	cd $(MOBILE_DIR) && flutter run

mobile-devices:
	@echo "Kiểm tra danh sách thiết bị/máy ảo kết nối..."
	flutter devices

mobile-pub-get:
	@echo "Đang lấy dependencies Flutter..."
	cd $(MOBILE_DIR) && flutter pub get

mobile-clean:
	@echo "Đang dọn dẹp Flutter build cache..."
	cd $(MOBILE_DIR) && flutter clean

mobile-apk:
	@echo "Đang build APK release..."
	cd $(MOBILE_DIR) && flutter build apk

# General Commands
setup:
	@echo "Đang cài đặt / restore dependencies cho Server và Mobile..."
	dotnet restore $(SERVER_DIR)
	cd $(MOBILE_DIR) && flutter pub get
	@echo "Setup hoàn tất!"

clean: server-clean mobile-clean docker-clean
	@echo "Đã dọn dẹp toàn bộ dự án!"
