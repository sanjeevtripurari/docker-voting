#!/bin/bash

set -e

echo "Cloning or updating repository..."

if [ ! -d "voting-app" ]; then
  git clone https://github.com/sanjeevtripurari/voting-app.git
else
  cd voting-app
  git pull
  cd ..
fi

echo "Stopping old containers..."
docker compose down -v || true

echo "Building and starting containers..."
docker compose up --build -d

echo "Waiting for services..."
sleep 20

echo "Testing backend..."
curl -f http://localhost:5000 || (echo "Backend failed" && exit 1)

echo "Setup completed successfully!"
echo "Frontend: http://localhost:3000"
echo "Backend: http://localhost:5000"
