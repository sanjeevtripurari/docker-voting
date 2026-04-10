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