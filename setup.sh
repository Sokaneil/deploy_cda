#!/bin/bash

# Local Testing Setup for 89 Progress
echo "🚀 Setting up 89 Progress for local testing..."

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p caddy

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "⚙️ Creating .env file from template..."
    cat > .env << 'EOF'
# Local Development Environment Variables
DOMAIN=localhost
DB_ROOT_PASSWORD=rootpassword123
DB_NAME=school_app
DB_USERNAME=admin_user
DB_PASSWORD=password123
JWT_SECRET=local-development-secret-key-change-in-production-minimum-32-characters
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_EXPIRATION=7d
ARGON2_MEMORY_COST=65536
ARGON2_TIME_COST=3
ARGON2_PARALLELISM=1
NEXT_PUBLIC_API_URL=http://localhost/api
NODE_ENV=development
ENABLE_SSL=false
DEBUG=true
EOF
    echo "✅ .env file created with local development settings"
else
    echo "⚠️ .env file already exists, skipping creation"
fi

# Create Caddyfile if it doesn't exist
if [ ! -f caddy/Caddyfile ]; then
    echo "⚙️ Creating Caddyfile..."
    mkdir -p caddy
    cat > caddy/Caddyfile << 'EOF'
# Local Development Caddyfile
{
    admin off
    log {
        output stdout
        level INFO
    }
}

localhost {
    # API routes - proxy to backend
    handle /api/* {
        reverse_proxy backend:3001 {
            header_up Host {host}
            header_up X-Real-IP {remote}
            header_up X-Forwarded-For {remote}
            header_up X-Forwarded-Proto {scheme}
        }
    }
    
    # Health endpoint
    handle /health {
        respond "OK" 200
    }
    
    # Frontend - proxy to Next.js
    handle {
        reverse_proxy frontend:3000 {
            header_up Host {host}
            header_up X-Real-IP {remote}
            header_up X-Forwarded-For {remote}
            header_up X-Forwarded-Proto {scheme}
        }
    }
    
    # Logging
    log {
        output stdout
        level INFO
    }
}
EOF
    echo "✅ Caddyfile created for local development"
else
    echo "⚠️ Caddyfile already exists, skipping creation"
fi

# Check if backend and frontend directories exist
if [ ! -d "Back_cda" ]; then
    echo "❌ Back_cda directory not found. Please ensure you have:"
    echo "   - Back_cda/ directory with your backend code"
    echo "   - front_cda/ directory with your frontend code"
    echo "   - This script should be run from your deployment directory"
    exit 1
fi

if [ ! -d "front_cda" ]; then
    echo "❌ front_cda directory not found. Please ensure you have:"
    echo "   - Back_cda/ directory with your backend code"
    echo "   - front_cda/ directory with your frontend code"
    echo "   - This script should be run from your deployment directory"
    exit 1
fi

# Create next.config.js for frontend if it doesn't exist
if [ ! -f "front_cda/next.config.js" ]; then
    echo "⚙️ Creating Next.js config for standalone build..."
    cat > front_cda/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  trailingSlash: true,
  generateEtags: false,
  poweredByHeader: false,
  compress: true,
  experimental: {
    outputFileTracingRoot: process.cwd(),
  },
  // Specify port for production
  server: {
    port: 3001
  }
}

module.exports = nextConfig
EOF
    echo "✅ Next.js config created"
fi

echo ""
echo "🏗️ Building and starting services..."

# Build and start services
docker-compose build --no-cache
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."

# Wait for services to be healthy
timeout=180
counter=0

while [ $counter -lt $timeout ]; do
    if docker-compose ps | grep -q "Up (healthy)"; then
        healthy_services=$(docker-compose ps | grep "Up (healthy)" | wc -l)
        total_services=$(docker-compose ps | grep "Up" | wc -l)
        
        if [ $healthy_services -eq 4 ]; then  # db, backend, frontend, caddy
            echo "✅ All services are healthy!"
            break
        fi
        
        echo "⏳ $healthy_services/$total_services services healthy, waiting..."
    else
        echo "⏳ Services starting up..."
    fi
    
    sleep 5
    counter=$((counter + 5))
done

if [ $counter -ge $timeout ]; then
    echo "❌ Timeout waiting for services to become healthy"
    echo "📋 Service status:"
    docker-compose ps
    echo ""
    echo "📋 Service logs:"
    docker-compose logs --tail=20
    exit 1
fi

echo ""
echo "🧪 Testing endpoints..."

# Test health endpoint
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "✅ Health endpoint working"
else
    echo "❌ Health endpoint not responding"
fi

# Test API endpoint
if curl -f http://localhost/api/health > /dev/null 2>&1; then
    echo "✅ API endpoint working"
else
    echo "❌ API endpoint not responding"
fi

# Test frontend
if curl -f http://localhost/ > /dev/null 2>&1; then
    echo "✅ Frontend endpoint working"
else
    echo "❌ Frontend endpoint not responding"
fi

echo ""
echo "🎉 Local deployment complete!"
echo ""
echo "📍 Your application is available at:"
echo "   🌐 Frontend: http://localhost"
echo "   🔧 API: http://localhost/api"
echo "   💚 Health: http://localhost/health"
echo ""
echo "🔧 Useful commands:"
echo "   View logs: docker-compose logs -f"
echo "   Stop services: docker-compose down"
echo "   Restart services: docker-compose restart"
echo "   View status: docker-compose ps"
echo ""
echo "🐛 If you encounter issues, check the logs with:"
echo "   docker-compose logs <service-name>"
echo "   (service names: db, backend, frontend, caddy)"