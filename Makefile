# Variables
SERVER_DIR = Server
MOBILE_DIR = NguyenQuangHung
DOCKER_COMPOSE_FILE = $(SERVER_DIR)/docker-compose.yml
DOCKER_COMPOSE = docker compose -f $(DOCKER_COMPOSE_FILE)
DOCKER_IMAGE_NAME = learnltddexam-server:latest

.PHONY: all setup clean \
        up up-db down restart logs ps docker-build docker-clean \
        server server-dev server-build server-clean db-migrate \
        mobile mobile-devices mobile-pub-get mobile-clean mobile-apk

# Docker Commands
docker-build:
	@echo "Đang build Docker image cho Server ($(DOCKER_IMAGE_NAME))..."
	docker build -t $(DOCKER_IMAGE_NAME) $(SERVER_DIR)

up:
	@echo "Đang build và khởi động toàn bộ dịch vụ (SQL Server + Backend API)..."
	$(DOCKER_COMPOSE) up -d --build

up-db:
	@echo "Đang khởi động riêng SQL Server (Docker Compose)..."
	$(DOCKER_COMPOSE) up -d sqlserver

down:
	@echo "Đang dừng các dịch vụ Docker Compose..."
	$(DOCKER_COMPOSE) down

restart:
	@echo "Đang khởi động lại các dịch vụ Docker..."
	$(DOCKER_COMPOSE) restart

logs:
	@echo "Đang theo dõi logs Docker Compose..."
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
