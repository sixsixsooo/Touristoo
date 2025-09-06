# Yandex Cloud Setup Guide for Touristoo Runner Game

This guide provides detailed step-by-step instructions for setting up Yandex Cloud services for the Touristoo Runner mobile game.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [PostgreSQL Cluster Setup](#postgresql-cluster-setup)
3. [Object Storage Configuration](#object-storage-configuration)
4. [Yandex Ads SDK Setup](#yandex-ads-sdk-setup)
5. [API Gateway & Cloud Functions](#api-gateway--cloud-functions)
6. [Environment Configuration](#environment-configuration)
7. [Testing the Setup](#testing-the-setup)

## Prerequisites

- Yandex Cloud account with billing enabled
- Domain name (optional, for production)
- Mobile app bundle ID (for ads configuration)

## 1. PostgreSQL Cluster Setup

### Step 1: Create PostgreSQL Cluster

1. **Log in to Yandex Cloud Console**

   - Go to [console.cloud.yandex.ru](https://console.cloud.yandex.ru)
   - Sign in with your Yandex account

2. **Navigate to Managed Service for PostgreSQL**

   - In the left sidebar, go to "Database" → "Managed Service for PostgreSQL"
   - Click "Create cluster"

3. **Configure the cluster:**

   ```
   Cluster name: touristoo-db
   Description: PostgreSQL cluster for Touristoo game
   Environment: Production (or Prestable for testing)
   Version: PostgreSQL 15
   Host class: s2.micro (1 vCPU, 4 GB RAM) for development
   Storage type: SSD
   Storage size: 20 GB (minimum)
   ```

4. **Network Configuration:**

   - Select your VPC network or create a new one
   - Create security group with rules:
     - Port 6432 (PostgreSQL) from your application's IP range
     - Port 22 (SSH) for management if needed

5. **Database Configuration:**

   ```
   Database name: touristoo
   Username: touristoo_user
   Password: [Generate strong password - save securely!]
   ```

6. **Backup Settings:**

   - Enable automatic backups
   - Set backup retention to 7 days
   - Choose backup time (e.g., 02:00 UTC)

7. **Click "Create cluster"** and wait for provisioning (5-10 minutes)

### Step 2: Configure Database Access

1. **Get Connection Details:**

   - Note the cluster hostname and port
   - Save the database credentials securely

2. **Test Connection:**

   ```bash
   psql -h <cluster-hostname> -p 6432 -U touristoo_user -d touristoo
   ```

3. **Update Environment Variables:**
   ```env
   DB_HOST=<cluster-hostname>
   DB_PORT=6432
   DB_NAME=touristoo
   DB_USER=touristoo_user
   DB_PASSWORD=<your-password>
   ```

**Video Tutorial:** [Yandex Cloud PostgreSQL Setup](https://youtu.be/example-postgresql-setup)

## 2. Object Storage Configuration

### Step 1: Create Object Storage Bucket

1. **Navigate to Object Storage**

   - In the left sidebar, go to "Storage" → "Object Storage"
   - Click "Create bucket"

2. **Configure the bucket:**

   ```
   Bucket name: touristoo-assets-[random-suffix]
   Storage class: Standard
   Access: Private
   Versioning: Enabled
   ```

3. **Set up CORS (Cross-Origin Resource Sharing):**
   - Go to bucket settings → "CORS"
   - Add rule:
   ```json
   {
     "AllowedOrigins": ["*"],
     "AllowedMethods": ["GET", "HEAD"],
     "AllowedHeaders": ["*"],
     "MaxAgeSeconds": 3600
   }
   ```

### Step 2: Create Folder Structure

Create the following folders in your bucket:

```
models/
  ├── characters/
  ├── obstacles/
  └── environment/
textures/
  ├── characters/
  ├── obstacles/
  └── environment/
sounds/
  ├── music/
  ├── effects/
  └── voice/
animations/
  └── characters/
ui/
  ├── icons/
  └── backgrounds/
```

### Step 3: Set up Access Keys

1. **Create Service Account:**

   - Go to "IAM" → "Service accounts"
   - Create service account: `touristoo-storage`
   - Assign role: `storage.editor`

2. **Create Access Keys:**

   - Go to "Access keys" in the service account
   - Create new access key
   - Save the `Access Key ID` and `Secret Access Key`

3. **Update Environment Variables:**
   ```env
   YC_ACCESS_KEY_ID=<access-key-id>
   YC_SECRET_ACCESS_KEY=<secret-access-key>
   YC_BUCKET_NAME=touristoo-assets-[random-suffix]
   YC_REGION=ru-central1
   ```

**Video Tutorial:** [Yandex Cloud Object Storage Setup](https://youtu.be/example-object-storage-setup)

## 3. Yandex Ads SDK Setup

### Step 1: Create Yandex Advertising Account

1. **Navigate to Yandex Advertising Network**

   - Go to [yandex.ru/adv](https://yandex.ru/adv)
   - Sign in with your Yandex account

2. **Create a new campaign:**
   - Click "Create campaign"
   - Select "Mobile app promotion"
   - Choose "Yandex Advertising Network"

### Step 2: Configure Your App

1. **App Information:**

   ```
   App name: Touristoo Runner
   Platform: Android and iOS
   Category: Games → Arcade
   Description: 3D endless runner game
   ```

2. **App Store Links:**
   - Add Google Play Store link when published
   - Add App Store link when published

### Step 3: Create Ad Units

1. **Banner Ads:**

   - Create banner ad unit (320x50, 320x100)
   - Note the Ad Unit ID

2. **Interstitial Ads:**

   - Create full-screen ad unit
   - Note the Ad Unit ID

3. **Rewarded Video Ads:**
   - Create rewarded video ad unit
   - Note the Ad Unit ID

### Step 4: Configure Ad Units in App

Update your app configuration:

```env
YANDEX_ADS_BANNER_UNIT_ID=<banner-unit-id>
YANDEX_ADS_INTERSTITIAL_UNIT_ID=<interstitial-unit-id>
YANDEX_ADS_REWARDED_UNIT_ID=<rewarded-unit-id>
```

**Video Tutorial:** [Yandex Ads SDK Setup](https://youtu.be/example-yandex-ads-setup)

## 4. API Gateway & Cloud Functions

### Step 1: Create API Gateway

1. **Navigate to API Gateway**

   - Go to "Serverless" → "API Gateway"
   - Click "Create API Gateway"

2. **Configure API Gateway:**

   ```
   Name: touristoo-api
   Description: API Gateway for Touristoo game
   ```

3. **Create OpenAPI Specification:**
   ```yaml
   openapi: 3.0.0
   info:
     title: Touristoo API
     version: 1.0.0
   paths:
     /health:
       get:
         x-yc-apigateway-integration:
           type: cloud_functions
           function_id: <function-id>
   ```

### Step 2: Create Cloud Functions

1. **Create Function for Authentication:**

   ```
   Name: touristoo-auth
   Runtime: nodejs18
   Entry point: index.handler
   ```

2. **Create Function for Game Logic:**

   ```
   Name: touristoo-game
   Runtime: nodejs18
   Entry point: index.handler
   ```

3. **Create Function for Leaderboard:**
   ```
   Name: touristoo-leaderboard
   Runtime: nodejs18
   Entry point: index.handler
   ```

### Step 3: Configure Function Triggers

1. **Set up HTTP triggers for each function**
2. **Configure environment variables for each function**
3. **Set up IAM roles for database access**

**Video Tutorial:** [Yandex Cloud Functions Setup](https://youtu.be/example-cloud-functions-setup)

## 5. Environment Configuration

### Backend Environment Variables

Create `.env` file in your backend directory:

```env
# Database Configuration
DB_HOST=<postgresql-cluster-hostname>
DB_PORT=6432
DB_NAME=touristoo
DB_USER=touristoo_user
DB_PASSWORD=<your-database-password>

# JWT Configuration
JWT_SECRET=<generate-strong-secret>
JWT_REFRESH_SECRET=<generate-strong-refresh-secret>
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Yandex Cloud Configuration
YC_ACCESS_KEY_ID=<your-access-key-id>
YC_SECRET_ACCESS_KEY=<your-secret-access-key>
YC_BUCKET_NAME=touristoo-assets-[random-suffix]
YC_REGION=ru-central1

# Yandex Ads Configuration
YANDEX_ADS_BANNER_UNIT_ID=<banner-unit-id>
YANDEX_ADS_INTERSTITIAL_UNIT_ID=<interstitial-unit-id>
YANDEX_ADS_REWARDED_UNIT_ID=<rewarded-unit-id>

# Server Configuration
PORT=3000
NODE_ENV=production
ALLOWED_ORIGINS=https://yourdomain.com,https://yourdomain.ru
```

### Client Environment Variables

Create `.env` file in your client directory:

```env
# API Configuration
API_BASE_URL=https://your-api-gateway-url
API_TIMEOUT=10000

# Yandex Ads Configuration
YANDEX_ADS_BANNER_UNIT_ID=<banner-unit-id>
YANDEX_ADS_INTERSTITIAL_UNIT_ID=<interstitial-unit-id>
YANDEX_ADS_REWARDED_UNIT_ID=<rewarded-unit-id>

# App Configuration
APP_NAME=Touristoo Runner
APP_VERSION=1.0.0
```

## 6. Testing the Setup

### Test Database Connection

```bash
# Test PostgreSQL connection
psql -h <cluster-hostname> -p 6432 -U touristoo_user -d touristoo

# Run database initialization
cd backend
npm run db:init
```

### Test Object Storage

```bash
# Test bucket access
aws s3 ls s3://touristoo-assets-[random-suffix] --endpoint-url=https://storage.yandexcloud.net
```

### Test API Endpoints

```bash
# Test health endpoint
curl https://your-api-gateway-url/health

# Test authentication
curl -X POST https://your-api-gateway-url/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"testpass123"}'
```

## 7. Security Best Practices

### Database Security

- Use strong passwords
- Enable SSL connections
- Restrict access by IP
- Regular security updates

### Object Storage Security

- Use private buckets
- Implement proper CORS policies
- Use signed URLs for sensitive content
- Regular access key rotation

### API Security

- Use HTTPS everywhere
- Implement rate limiting
- Validate all inputs
- Use proper authentication

## 8. Monitoring and Maintenance

### Set up Monitoring

1. **Cloud Monitoring** for database and storage
2. **Logging** for API Gateway and Functions
3. **Alerts** for critical issues

### Regular Maintenance

1. **Database backups** (automated)
2. **Security updates** (monthly)
3. **Performance monitoring** (continuous)
4. **Cost optimization** (monthly review)

## Troubleshooting

### Common Issues

1. **Database Connection Failed**

   - Check security group rules
   - Verify credentials
   - Check network connectivity

2. **Object Storage Access Denied**

   - Verify access keys
   - Check bucket permissions
   - Verify CORS configuration

3. **API Gateway Errors**
   - Check function logs
   - Verify environment variables
   - Check IAM permissions

### Support Resources

- [Yandex Cloud Documentation](https://cloud.yandex.ru/docs)
- [Yandex Ads Documentation](https://yandex.ru/dev/ads/)
- [Community Forum](https://cloud.yandex.ru/community)

## Cost Optimization

### Estimated Monthly Costs (Development)

- PostgreSQL Cluster (s2.micro): ~$15-20
- Object Storage (20GB): ~$1-2
- API Gateway: ~$5-10
- Cloud Functions: ~$5-15
- **Total: ~$25-50/month**

### Production Scaling

- Upgrade to larger PostgreSQL instance
- Implement CDN for assets
- Use reserved capacity for cost savings
- Monitor usage and optimize

---

**Note:** Replace placeholder values with your actual configuration values. Keep all credentials secure and never commit them to version control.
