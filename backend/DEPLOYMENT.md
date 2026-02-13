# Deployment Guide

Production deployment guide for CTF Game backend API.

## 🎯 Deployment Options

1. **AWS** (Recommended for scale)
2. **Heroku** (Fastest for MVP)
3. **DigitalOcean** (Cost-effective)
4. **Docker** (Self-hosted)

---

## Option 1: AWS Deployment

### Prerequisites
- AWS Account
- AWS CLI configured
- Domain name (optional)

### Architecture
```
Internet
    ↓
CloudFront (CDN) → S3 (Static Assets)
    ↓
Route53 (DNS)
    ↓
Application Load Balancer (ALB)
    ↓
EC2 Auto Scaling Group (API Servers)
    ↓ ↓
RDS PostgreSQL + PostGIS
ElastiCache Redis
```

### Step 1: RDS PostgreSQL Setup

```bash
# Create PostgreSQL instance with PostGIS
aws rds create-db-instance \
  --db-instance-identifier ctf-game-db \
  --db-instance-class db.t3.medium \
  --engine postgres \
  --engine-version 14.7 \
  --master-username ctfadmin \
  --master-user-password YOUR_SECURE_PASSWORD \
  --allocated-storage 20 \
  --storage-type gp3 \
  --vpc-security-group-ids sg-xxxxx \
  --db-subnet-group-name your-subnet-group \
  --publicly-accessible false \
  --backup-retention-period 7

# After creation, connect and enable PostGIS
psql -h your-rds-endpoint.amazonaws.com -U ctfadmin -d postgres
CREATE DATABASE ctf_game;
\c ctf_game
CREATE EXTENSION postgis;
```

### Step 2: ElastiCache Redis

```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id ctf-game-redis \
  --cache-node-type cache.t3.medium \
  --engine redis \
  --engine-version 7.0 \
  --num-cache-nodes 1 \
  --cache-subnet-group-name your-subnet-group \
  --security-group-ids sg-xxxxx
```

### Step 3: EC2 Setup

**Launch EC2 Instance:**
- AMI: Amazon Linux 2023
- Instance Type: t3.medium (2 vCPU, 4GB RAM)
- Security Group: Allow ports 80, 443, 3000, 3001

**Install Dependencies:**
```bash
# SSH into EC2
ssh -i your-key.pem ec2-user@your-instance-ip

# Update system
sudo yum update -y

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install Git
sudo yum install -y git

# Install PM2 globally
sudo npm install -g pm2

# Clone repository
git clone https://github.com/your-org/ctf-game-backend.git
cd ctf-game-backend

# Install dependencies
npm ci --only=production
```

**Configure Environment:**
```bash
# Create .env file
cat > .env << EOF
PORT=3000
WS_PORT=3001
NODE_ENV=production

DB_HOST=your-rds-endpoint.amazonaws.com
DB_PORT=5432
DB_NAME=ctf_game
DB_USER=ctfadmin
DB_PASSWORD=YOUR_SECURE_PASSWORD

REDIS_HOST=your-elasticache-endpoint.amazonaws.com
REDIS_PORT=6379

JWT_SECRET=$(openssl rand -hex 32)
EOF

# Run migrations
npm run migrate
npm run seed
```

**Start with PM2:**
```bash
# Start application
pm2 start src/server.js --name ctf-api

# Configure auto-restart on reboot
pm2 startup
pm2 save

# Monitor
pm2 status
pm2 logs ctf-api
```

### Step 4: Application Load Balancer

```bash
# Create target group
aws elbv2 create-target-group \
  --name ctf-api-targets \
  --protocol HTTP \
  --port 3000 \
  --vpc-id vpc-xxxxx \
  --health-check-path /health

# Create load balancer
aws elbv2 create-load-balancer \
  --name ctf-api-lb \
  --subnets subnet-xxxxx subnet-yyyyy \
  --security-groups sg-xxxxx

# Create listener
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:... \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:...

# Register EC2 instances
aws elbv2 register-targets \
  --target-group-arn arn:aws:... \
  --targets Id=i-xxxxx
```

### Step 5: SSL/TLS (HTTPS)

```bash
# Request ACM certificate
aws acm request-certificate \
  --domain-name api.ctfgame.com \
  --validation-method DNS

# Create HTTPS listener
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:... \
  --protocol HTTPS \
  --port 443 \
  --certificates CertificateArn=arn:aws:acm:... \
  --default-actions Type=forward,TargetGroupArn=arn:aws:...
```

### Step 6: Auto Scaling

```bash
# Create launch template
aws ec2 create-launch-template \
  --launch-template-name ctf-api-template \
  --version-description v1 \
  --launch-template-data file://launch-template.json

# Create auto scaling group
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name ctf-api-asg \
  --launch-template LaunchTemplateName=ctf-api-template \
  --min-size 2 \
  --max-size 10 \
  --desired-capacity 2 \
  --target-group-arns arn:aws:... \
  --vpc-zone-identifier "subnet-xxxxx,subnet-yyyyy"

# Configure scaling policies
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name ctf-api-asg \
  --policy-name cpu-scale-up \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration file://scaling-policy.json
```

**scaling-policy.json:**
```json
{
  "PredefinedMetricSpecification": {
    "PredefinedMetricType": "ASGAverageCPUUtilization"
  },
  "TargetValue": 70.0
}
```

### Cost Estimate (AWS)

**Monthly Costs:**
- RDS db.t3.medium: ~$60
- ElastiCache cache.t3.medium: ~$50
- EC2 t3.medium (2 instances): ~$60
- ALB: ~$20
- Data transfer: ~$10-50
- **Total: ~$200-250/month**

---

## Option 2: Heroku Deployment (Fastest)

### Prerequisites
- Heroku account
- Heroku CLI installed

### Steps

```bash
# Login to Heroku
heroku login

# Create app
heroku create ctf-game-api

# Add PostgreSQL addon
heroku addons:create heroku-postgresql:standard-0

# Add Redis addon
heroku addons:create heroku-redis:premium-0

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=$(openssl rand -hex 32)
heroku config:set WS_PORT=3001

# Deploy
git add .
git commit -m "Initial deployment"
git push heroku main

# Run migrations
heroku run npm run migrate
heroku run npm run seed

# Scale dynos
heroku ps:scale web=2

# View logs
heroku logs --tail

# Open app
heroku open
```

### Enable PostGIS on Heroku Postgres

```bash
# Connect to database
heroku pg:psql

# Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;
\dx
\q
```

### Heroku Procfile

Create `Procfile` in project root:
```
web: npm start
```

### Cost Estimate (Heroku)

**Monthly Costs:**
- Standard-0 Postgres: ~$50
- Premium-0 Redis: ~$60
- 2x Standard-1X Dynos: ~$50
- **Total: ~$160/month**

---

## Option 3: DigitalOcean Deployment

### Steps

```bash
# Create Droplet (Ubuntu 22.04)
# Size: 4GB RAM, 2 vCPU (~$24/month)

# SSH into droplet
ssh root@your-droplet-ip

# Update system
apt update && apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Install PostgreSQL + PostGIS
apt install -y postgresql postgresql-contrib postgis

# Install Redis
apt install -y redis-server

# Configure PostgreSQL
sudo -u postgres psql
CREATE DATABASE ctf_game;
CREATE USER ctfadmin WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE ctf_game TO ctfadmin;
\c ctf_game
CREATE EXTENSION postgis;
\q

# Clone repository
git clone https://github.com/your-org/ctf-game-backend.git
cd ctf-game-backend

# Install dependencies
npm ci --only=production

# Configure environment
nano .env
# (paste production values)

# Run migrations
npm run migrate
npm run seed

# Install PM2
npm install -g pm2
pm2 start src/server.js --name ctf-api
pm2 startup
pm2 save

# Configure Nginx reverse proxy
apt install -y nginx

cat > /etc/nginx/sites-available/ctf-api << 'EOF'
server {
    listen 80;
    server_name api.ctfgame.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /ws {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
EOF

ln -s /etc/nginx/sites-available/ctf-api /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# Install Certbot for HTTPS
apt install -y certbot python3-certbot-nginx
certbot --nginx -d api.ctfgame.com
```

### Cost Estimate (DigitalOcean)

**Monthly Costs:**
- 4GB Droplet: $24
- Managed Postgres (optional): $15
- Managed Redis (optional): $15
- **Total: ~$24-54/month**

---

## Option 4: Docker Deployment

### Using Docker Compose

```bash
# Clone repository
git clone https://github.com/your-org/ctf-game-backend.git
cd ctf-game-backend

# Build and start
docker-compose up -d

# Run migrations
docker-compose exec api npm run migrate
docker-compose exec api npm run seed

# View logs
docker-compose logs -f

# Scale API instances
docker-compose up -d --scale api=3
```

### Production Docker Compose

```yaml
version: '3.8'

services:
  postgres:
    image: postgis/postgis:14-3.3
    restart: always
    environment:
      POSTGRES_USER: ctfadmin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ctf_game
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend

  redis:
    image: redis:7-alpine
    restart: always
    volumes:
      - redis_data:/data
    networks:
      - backend

  api:
    build: .
    restart: always
    environment:
      NODE_ENV: production
      DB_HOST: postgres
      REDIS_HOST: redis
      JWT_SECRET: ${JWT_SECRET}
    ports:
      - "3000:3000"
      - "3001:3001"
    depends_on:
      - postgres
      - redis
    networks:
      - backend
      - frontend

  nginx:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - api
    networks:
      - frontend

volumes:
  postgres_data:
  redis_data:

networks:
  backend:
  frontend:
```

---

## 🔒 Security Checklist

**Before Going Live:**

- [ ] Change `JWT_SECRET` to strong random value
- [ ] Enable HTTPS/TLS (use Let's Encrypt)
- [ ] Configure database firewall (allow only API servers)
- [ ] Set up Redis authentication
- [ ] Enable rate limiting on all endpoints
- [ ] Configure CORS for specific domains only
- [ ] Set up CloudWatch/monitoring
- [ ] Configure automated backups (RDS/database)
- [ ] Set up error tracking (Sentry, Rollbar)
- [ ] Enable SQL query logging for debugging
- [ ] Create read-only database replicas
- [ ] Set up DDoS protection (CloudFlare, AWS Shield)

---

## 📊 Monitoring & Logging

### CloudWatch (AWS)

```bash
# Install CloudWatch agent on EC2
wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip
unzip AmazonCloudWatchAgent.zip
sudo ./install.sh

# Configure agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

### PM2 Monitoring

```bash
# PM2 Plus (free tier)
pm2 link YOUR_SECRET_KEY YOUR_PUBLIC_KEY

# View metrics
pm2 monit

# Custom metrics
pm2 install pm2-server-monit
```

### Logging Best Practices

```javascript
// Use Winston for structured logging
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// In production, send to CloudWatch/Datadog
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.12.12
        with:
          heroku_api_key: ${{ secrets.HEROKU_API_KEY }}
          heroku_app_name: "ctf-game-api"
          heroku_email: "your@email.com"
```

---

## 🚨 Rollback Strategy

```bash
# Heroku rollback
heroku releases
heroku rollback v42

# AWS with Blue/Green deployment
# 1. Keep old version running
# 2. Deploy new version to separate target group
# 3. Test new version
# 4. Switch load balancer to new version
# 5. Keep old version for 24h for quick rollback

# Docker rollback
docker-compose down
git checkout previous-tag
docker-compose up -d
```

---

## 📈 Performance Optimization

**Database:**
- Enable connection pooling (already configured)
- Add indexes on frequently queried columns
- Use materialized views for complex queries
- Set up read replicas for high-traffic endpoints

**Caching:**
- Cache leaderboards in Redis (5-minute TTL)
- Cache flag states (1-hour TTL)
- Use CDN for static assets

**API:**
- Enable gzip compression
- Implement pagination on list endpoints
- Use database query optimization
- Monitor slow queries with pg_stat_statements

---

## 🎯 Next Steps After Deployment

1. **Load Testing**: Use Artillery or k6 to test 1000+ concurrent users
2. **Mobile Integration**: Connect iOS app to production API
3. **Push Notifications**: Implement APNs/FCM integration
4. **Analytics**: Add Mixpanel or Amplitude for user tracking
5. **Admin Dashboard**: Build internal tool for game management

---

**Questions?** Check the main README or open an issue on GitHub.
