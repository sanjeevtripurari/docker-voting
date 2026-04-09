# 🐳 Docker Setup for Voting App (External, Non-Intrusive)

This guide explains how to run the **Voting App** using Docker **without modifying the original repository**.

---

# 🎯 Objective

* Keep source repo unchanged
* Use external Docker setup
* Build, run, clean, rebuild, and push images
* Support tagging for releases

---

# 📁 Directory Structure

Create a separate folder:

```bash
docker-voting/
├── backend.Dockerfile
├── frontend.Dockerfile
├── docker-compose.yml
├── .env
├── scripts/
│   └── docker.sh
└── voting-app/   # cloned repo
```

---

# 📥 Step 1 — Clone Repository

```bash
git clone https://github.com/sanjeevtripurari/voting-app.git
```

---

# 🐳 Step 2 — Backend Dockerfile

📄 `backend.Dockerfile`

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY voting-app/backend/package*.json ./
RUN npm install --production

COPY voting-app/backend ./

EXPOSE 5000

CMD ["node", "server.js"]
```

---

# 🐳 Step 3 — Frontend Dockerfile

📄 `frontend.Dockerfile`

```dockerfile
FROM node:18-alpine AS build

WORKDIR /app

COPY voting-app/frontend/package*.json ./
RUN npm install

COPY voting-app/frontend ./

RUN npm run build

FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

---

# 🐳 Step 4 — Docker Compose

📄 `docker-compose.yml`

```yaml
services:
  db:
    image: mysql:8
    container_name: voting-db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: voting_app
    volumes:
      - db_data:/var/lib/mysql
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"

  backend:
    build:
      context: .
      dockerfile: backend.Dockerfile
    container_name: voting-backend
    depends_on:
      - db
    environment:
      DB_HOST: db
      DB_USER: voting_user
      DB_PASSWORD: vote_pass
      DB_NAME: voting_app
      PORT: 5000
    ports:
      - "5000:5000"

  frontend:
    build:
      context: .
      dockerfile: frontend.Dockerfile
    container_name: voting-frontend
    depends_on:
      - backend
    ports:
      - "3000:80"

volumes:
  db_data:
```

---

# ⚙️ Step 5 — Environment File

📄 `.env`

```env
DOCKER_USER=sanjeevtripurari
IMAGE_NAME=voting-app
```

---

# 🧰 Step 6 — Automation Script

📄 `scripts/docker.sh`

```bash
#!/bin/bash

set -e

DOCKER_USER=${DOCKER_USER:-"your_dockerhub_username"}
TAG=${1:-latest}

function build() {
  echo "Building images..."
  docker build -t $DOCKER_USER/voting-app-backend:$TAG -f backend.Dockerfile .
  docker build -t $DOCKER_USER/voting-app-frontend:$TAG -f frontend.Dockerfile .
}

function up() {
  echo "Starting containers..."
  docker compose up -d
}

function down() {
  echo "Stopping containers..."
  docker compose down -v
}

function rebuild() {
  echo "Rebuilding everything..."
  down
  build
  up
}

function push() {
  echo "Pushing images..."
  docker push $DOCKER_USER/voting-app-backend:$TAG
  docker push $DOCKER_USER/voting-app-frontend:$TAG
}

function clean() {
  echo "Cleaning images..."
  docker rmi $DOCKER_USER/voting-app-backend:$TAG || true
  docker rmi $DOCKER_USER/voting-app-frontend:$TAG || true
}

case "$2" in
  build) build ;;
  up) up ;;
  down) down ;;
  rebuild) rebuild ;;
  push) push ;;
  clean) clean ;;
  *)
    echo "Usage: ./docker.sh <tag> {build|up|down|rebuild|push|clean}"
    exit 1
esac
```

---

# 🚀 Usage

## 🔨 Build images

```bash
./scripts/docker.sh v1 build
```

---

## ▶️ Start containers

```bash
./scripts/docker.sh v1 up
```

---

## 🛑 Stop containers

```bash
./scripts/docker.sh v1 down
```

---

## 🔄 Rebuild everything

```bash
./scripts/docker.sh v1 rebuild
```

---

## 📦 Push to Docker Hub

```bash
docker login
./scripts/docker.sh v1 push
```

---

## 🧹 Clean images

```bash
./scripts/docker.sh v1 clean
```

---

# 🔄 Workflow Summary

```text
Clone repo → Build Docker → Run containers → Test → Tag → Push → Deploy
```

---

# ⚠️ Notes

* Ensure frontend has `"build": "react-scripts build"`
* MySQL init script must create user `voting_user`
* Docker Hub login required before push

---
