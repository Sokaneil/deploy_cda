#!/bin/bash

# Pull latest changes
git pull

# Pull latest backend
cd ../backend
git pull
cd ../deployment

# Pull latest frontend
cd ../frontend
git pull
cd ../deployment

# Rebuild and restart containers
docker-compose down
docker-compose build
docker-compose up -d

echo "Deployment completed at $(date)"