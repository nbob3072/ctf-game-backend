#!/bin/bash
# Quick Fly.io deployment script for CTF backend

set -e  # Exit on error

echo "🚀 Fly.io Deployment Script for CTF Backend"
echo "==========================================="
echo ""

# Check if flyctl is installed
if ! command -v fly &> /dev/null; then
    echo "❌ Fly CLI not found. Installing..."
    curl -L https://fly.io/install.sh | sh
    echo ""
    echo "✅ Fly CLI installed. Please run this script again."
    echo "   You may need to restart your terminal or run:"
    echo "   export PATH=\"\$HOME/.fly/bin:\$PATH\""
    exit 0
fi

echo "✅ Fly CLI found: $(fly version)"
echo ""

# Check if logged in
if ! fly auth whoami &> /dev/null; then
    echo "🔐 Not logged in to Fly.io. Opening browser for login..."
    fly auth login
else
    echo "✅ Already logged in to Fly.io as: $(fly auth whoami)"
fi

echo ""
echo "📝 Configuration"
echo "=================="

# Generate JWT secret
JWT_SECRET=$(openssl rand -hex 32)
echo "✅ Generated JWT_SECRET"

# Check if app already exists
APP_NAME="ctf-game-backend"
if fly status -a $APP_NAME &> /dev/null; then
    echo "⚠️  App '$APP_NAME' already exists"
    read -p "Do you want to redeploy to existing app? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 1
    fi
    EXISTING_APP=true
else
    EXISTING_APP=false
fi

echo ""
echo "🏗️  Setting up Fly.io app..."
echo "=============================="

if [ "$EXISTING_APP" = false ]; then
    # Create new app
    fly launch \
        --name $APP_NAME \
        --region sea \
        --no-deploy \
        --copy-config \
        --dockerfile Dockerfile

    echo "✅ App created: $APP_NAME"
fi

echo ""
echo "🔐 Setting environment variables..."
echo "===================================="

# Set secrets
fly secrets set \
    NODE_ENV=production \
    PORT=3000 \
    WS_PORT=3001 \
    DB_HOST=db.qapziqecutkgvuqnfzsd.supabase.co \
    DB_PORT=5432 \
    DB_NAME=postgres \
    DB_USER=postgres \
    DB_PASSWORD=nixqyG-qovnen-zijby2 \
    JWT_SECRET=$JWT_SECRET \
    -a $APP_NAME

echo "✅ Secrets configured"

echo ""
echo "🚀 Deploying to Fly.io..."
echo "=========================="

fly deploy -a $APP_NAME

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 App Status"
echo "=============="
fly status -a $APP_NAME

echo ""
echo "🌐 Your app is live at:"
echo "https://$APP_NAME.fly.dev"
echo ""
echo "📝 Next steps:"
echo "1. Test your API: curl https://$APP_NAME.fly.dev/health"
echo "2. Update iOS app with URL: https://$APP_NAME.fly.dev"
echo "3. Monitor logs: fly logs -a $APP_NAME"
echo ""
echo "🎉 Done!"
