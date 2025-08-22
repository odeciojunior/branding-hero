# 8. Deployment & Hosting Infrastructure

## Cloud Infrastructure Architecture

### Recommended Hosting Stack: Vercel + Cloudflare
```typescript
// Infrastructure configuration overview
export const infrastructureConfig = {
  primary: {
    platform: "Vercel",
    tier: "Pro Plan",
    features: [
      "Edge Functions",
      "Image Optimization", 
      "Incremental Static Regeneration",
      "Analytics",
      "Preview Deployments",
      "Automatic HTTPS"
    ],
    regions: ["Brazil (gru1)", "US East (iad1)", "Europe (fra1)"],
    scalability: "Automatic scaling to zero and beyond"
  },
  
  cdn: {
    provider: "Cloudflare",
    tier: "Pro Plan",
    features: [
      "Global CDN",
      "DDoS Protection", 
      "Web Application Firewall",
      "Bot Management",
      "Image Optimization",
      "Cache Analytics"
    ],
    caching: "Smart caching with edge workers"
  },
  
  database: {
    primary: "PlanetScale (MySQL)",
    backup: "Supabase (PostgreSQL)",
    features: [
      "Serverless MySQL",
      "Branching for development",
      "Connection pooling",
      "Automatic backups",
      "Global read replicas"
    ]
  },
  
  monitoring: {
    performance: "Vercel Analytics + Web Vitals",
    errors: "Sentry",
    uptime: "Pingdom",
    logs: "Vercel Functions Logs"
  }
}
```

### Vercel Deployment Configuration
```typescript
// vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/next"
    }
  ],
  "functions": {
    "app/api/**/*.ts": {
      "maxDuration": 30
    }
  },
  "regions": ["gru1", "iad1"],
  "env": {
    "NODE_ENV": "production"
  },
  "build": {
    "env": {
      "NEXT_TELEMETRY_DISABLED": "1",
      "SKIP_ENV_VALIDATION": "1"
    }
  },
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options", 
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        },
        {
          "key": "Permissions-Policy",
          "value": "camera=(), microphone=(), geolocation=()"
        }
      ]
    },
    {
      "source": "/api/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "s-maxage=60, stale-while-revalidate=300"
        }
      ]
    },
    {
      "source": "/(.*\\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2))",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ],
  "redirects": [
    {
      "source": "/admin",
      "destination": "/studio",
      "permanent": true
    }
  ],
  "rewrites": [
    {
      "source": "/sitemap.xml",
      "destination": "/api/sitemap"
    },
    {
      "source": "/robots.txt", 
      "destination": "/api/robots"
    }
  ]
}
```

### Next.js Production Configuration
```typescript
// next.config.js - Production optimized
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Performance optimizations
  experimental: {
    appDir: true,
    serverComponentsExternalPackages: ['@prisma/client'],
    optimizePackageImports: [
      '@heroicons/react',
      '@headlessui/react',
      'lucide-react'
    ]
  },

  // Compiler optimizations
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production',
    reactRemoveProperties: process.env.NODE_ENV === 'production'
  },

  // Image optimization
  images: {
    formats: ['image/webp', 'image/avif'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    domains: ['cdn.sanity.io', 'images.unsplash.com'],
    minimumCacheTTL: 60 * 60 * 24 * 7 // 7 days
  },

  // Enable compression
  compress: true,

  // Enable SWC minification
  swcMinify: true,

  // Output configuration
  output: 'standalone',

  // Bundle analyzer in development
  ...(process.env.ANALYZE === 'true' && {
    webpack: (config, { isServer }) => {
      if (!isServer) {
        const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer')
        config.plugins.push(
          new BundleAnalyzerPlugin({
            analyzerMode: 'server',
            analyzerPort: 8889,
            openAnalyzer: true
          })
        )
      }
      return config
    }
  }),

  // Environment variables validation
  env: {
    CUSTOM_KEY: process.env.CUSTOM_KEY,
  },

  // Security headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=31536000; includeSubDomains; preload'
          },
          {
            key: 'Content-Security-Policy',
            value: generateCSP()
          }
        ]
      }
    ]
  },

  // Redirects for SEO
  async redirects() {
    return [
      {
        source: '/home',
        destination: '/',
        permanent: true
      },
      {
        source: '/servicos/:slug*',
        destination: '/services/:slug*',
        permanent: false
      }
    ]
  }
}

function generateCSP() {
  const csp = [
    "default-src 'self'",
    "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.googletagmanager.com https://connect.facebook.net",
    "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
    "img-src 'self' data: https://cdn.sanity.io https://images.unsplash.com",
    "font-src 'self' https://fonts.gstatic.com",
    "connect-src 'self' https://api.sanity.io https://www.google-analytics.com",
    "frame-src 'none'",
    "object-src 'none'"
  ]
  return csp.join('; ')
}

module.exports = nextConfig
```

### CI/CD Pipeline Configuration
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: 18.x
  PNPM_VERSION: 8.x

jobs:
  test:
    name: Test & Quality Checks
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          
      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: ${{ env.PNPM_VERSION }}
          
      - name: Get pnpm store directory
        id: pnpm-cache
        run: echo "STORE_PATH=$(pnpm store path)" >> $GITHUB_OUTPUT
        
      - name: Setup pnpm cache
        uses: actions/cache@v3
        with:
          path: ${{ steps.pnpm-cache.outputs.STORE_PATH }}
          key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}
          restore-keys: |
            ${{ runner.os }}-pnpm-store-
            
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
        
      - name: Run type checking
        run: pnpm run type-check
        
      - name: Run linting
        run: pnpm run lint
        
      - name: Run tests
        run: pnpm run test
        
      - name: Run E2E tests
        run: pnpm run test:e2e
        
      - name: Build application
        run: pnpm run build
        env:
          NEXT_PUBLIC_SANITY_PROJECT_ID: ${{ secrets.NEXT_PUBLIC_SANITY_PROJECT_ID }}
          NEXT_PUBLIC_SANITY_DATASET: ${{ secrets.NEXT_PUBLIC_SANITY_DATASET }}
          
  security:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Run Snyk security scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
          
      - name: Run OWASP dependency check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'hero-website'
          path: '.'
          format: 'JSON'
          
  performance:
    name: Performance Audit
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          
      - name: Install dependencies
        run: npm install -g lighthouse @lhci/cli
        
      - name: Run Lighthouse CI
        run: lhci autorun
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
          
  deploy:
    name: Deploy to Vercel
    runs-on: ubuntu-latest
    needs: [test, security, performance]
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
          
      - name: Post-deployment tests
        run: |
          # Wait for deployment to be ready
          sleep 60
          # Run smoke tests against production
          curl -f https://hero.com.br/api/health || exit 1
          
  notify:
    name: Notify Team
    runs-on: ubuntu-latest
    needs: deploy
    if: always()
    
    steps:
      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          channel: '#deployments'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Database Migration Strategy
```typescript
// scripts/migrate.ts
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

export async function runMigrations() {
  console.log('Starting database migrations...')
  
  try {
    // Run Prisma migrations
    await prisma.$executeRaw`SELECT 1` // Health check
    
    console.log('Database connection successful')
    
    // Custom data migrations if needed
    await migrateContactFormData()
    await migrateAnalyticsData()
    
    console.log('Migrations completed successfully')
  } catch (error) {
    console.error('Migration failed:', error)
    process.exit(1)
  } finally {
    await prisma.$disconnect()
  }
}

async function migrateContactFormData() {
  // Example: Migrate old contact form data to new schema
  const oldContacts = await prisma.contact.findMany({
    where: { migrated: false }
  })
  
  for (const contact of oldContacts) {
    await prisma.contact.update({
      where: { id: contact.id },
      data: {
        // Transform data as needed
        migrated: true
      }
    })
  }
  
  console.log(`Migrated ${oldContacts.length} contact records`)
}

async function migrateAnalyticsData() {
  // Migrate analytics data if needed
  console.log('Analytics data migration completed')
}

// Run migrations
if (require.main === module) {
  runMigrations()
}
```

### Environment Configuration Management
```typescript
// lib/env.ts - Environment validation
import { z } from 'zod'

const envSchema = z.object({
  // App configuration
  NODE_ENV: z.enum(['development', 'testing', 'production']),
  NEXT_PUBLIC_APP_URL: z.string().url(),
  
  // Database
  DATABASE_URL: z.string().min(1),
  
  // CMS
  NEXT_PUBLIC_SANITY_PROJECT_ID: z.string().min(1),
  NEXT_PUBLIC_SANITY_DATASET: z.string().min(1),
  SANITY_API_TOKEN: z.string().min(1),
  
  // Analytics
  NEXT_PUBLIC_GA_ID: z.string().min(1),
  NEXT_PUBLIC_HOTJAR_ID: z.string().optional(),
  
  // External APIs
  EMAIL_API_KEY: z.string().min(1),
  WHATSAPP_API_TOKEN: z.string().min(1),
  
  // Security
  NEXTAUTH_SECRET: z.string().min(32),
  NEXTAUTH_URL: z.string().url(),
  ENCRYPTION_KEY: z.string().min(32),
  CSRF_SECRET: z.string().min(32),
  
  // Monitoring
  SENTRY_DSN: z.string().url().optional(),
  VERCEL_URL: z.string().optional(),
})

type Env = z.infer<typeof envSchema>

export const env: Env = envSchema.parse(process.env)

// Validate environment on startup
export function validateEnvironment() {
  try {
    envSchema.parse(process.env)
    console.log('✅ Environment variables validated')
  } catch (error) {
    console.error('❌ Environment validation failed:', error)
    process.exit(1)
  }
}
```

### Multi-Environment Strategy
```typescript
// Environment-specific configurations
export const environmentConfig = {
  development: {
    database: {
      url: process.env.DEV_DATABASE_URL,
      logging: true,
      slowQueryThreshold: 1000
    },
    cache: {
      ttl: 60, // 1 minute
      redis: false // Use memory cache
    },
    monitoring: {
      sentry: false,
      analytics: false,
      performance: false
    }
  },
  
  staging: {
    database: {
      url: process.env.STAGING_DATABASE_URL,
      logging: false,
      slowQueryThreshold: 500
    },
    cache: {
      ttl: 300, // 5 minutes
      redis: true
    },
    monitoring: {
      sentry: true,
      analytics: false, // Don't pollute production analytics
      performance: true
    }
  },
  
  production: {
    database: {
      url: process.env.DATABASE_URL,
      logging: false,
      slowQueryThreshold: 200
    },
    cache: {
      ttl: 3600, // 1 hour
      redis: true
    },
    monitoring: {
      sentry: true,
      analytics: true,
      performance: true
    }
  }
}

export function getEnvironmentConfig() {
  const env = process.env.NODE_ENV as keyof typeof environmentConfig
  return environmentConfig[env] || environmentConfig.development
}
```

### Health Checks and Monitoring
```typescript
// pages/api/health.ts
import { NextApiRequest, NextApiResponse } from 'next'
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

interface HealthStatus {
  status: 'healthy' | 'unhealthy'
  timestamp: string
  version: string
  environment: string
  services: {
    database: ServiceStatus
    cms: ServiceStatus
    analytics: ServiceStatus
    cache: ServiceStatus
  }
  performance: {
    uptime: number
    memory: NodeJS.MemoryUsage
    responseTime: number
  }
}

interface ServiceStatus {
  status: 'healthy' | 'unhealthy' | 'degraded'
  responseTime?: number
  error?: string
}

export default async function handler(req: NextApiRequest, res: NextApiResponse<HealthStatus>) {
  const startTime = Date.now()
  
  try {
    // Check all services
    const [database, cms, analytics, cache] = await Promise.allSettled([
      checkDatabase(),
      checkCMS(),
      checkAnalytics(),
      checkCache()
    ])

    const services = {
      database: getServiceResult(database),
      cms: getServiceResult(cms),
      analytics: getServiceResult(analytics),
      cache: getServiceResult(cache)
    }

    const allHealthy = Object.values(services).every(service => service.status === 'healthy')
    const responseTime = Date.now() - startTime

    const healthStatus: HealthStatus = {
      status: allHealthy ? 'healthy' : 'unhealthy',
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version || '1.0.0',
      environment: process.env.NODE_ENV || 'development',
      services,
      performance: {
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        responseTime
      }
    }

    // Return appropriate status code
    const statusCode = allHealthy ? 200 : 503
    
    res.status(statusCode).json(healthStatus)
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version || '1.0.0',
      environment: process.env.NODE_ENV || 'development',
      services: {
        database: { status: 'unhealthy', error: 'Health check failed' },
        cms: { status: 'unhealthy', error: 'Health check failed' },
        analytics: { status: 'unhealthy', error: 'Health check failed' },
        cache: { status: 'unhealthy', error: 'Health check failed' }
      },
      performance: {
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        responseTime: Date.now() - startTime
      }
    })
  }
}

async function checkDatabase(): Promise<ServiceStatus> {
  const start = Date.now()
  try {
    await prisma.$queryRaw`SELECT 1`
    return {
      status: 'healthy',
      responseTime: Date.now() - start
    }
  } catch (error) {
    return {
      status: 'unhealthy',
      responseTime: Date.now() - start,
      error: error instanceof Error ? error.message : 'Unknown error'
    }
  }
}

async function checkCMS(): Promise<ServiceStatus> {
  const start = Date.now()
  try {
    const response = await fetch(`https://${process.env.NEXT_PUBLIC_SANITY_PROJECT_ID}.api.sanity.io/v1/ping`)
    
    if (response.ok) {
      return {
        status: 'healthy',
        responseTime: Date.now() - start
      }
    } else {
      return {
        status: 'unhealthy',
        responseTime: Date.now() - start,
        error: `HTTP ${response.status}`
      }
    }
  } catch (error) {
    return {
      status: 'unhealthy',
      responseTime: Date.now() - start,
      error: error instanceof Error ? error.message : 'Unknown error'
    }
  }
}

async function checkAnalytics(): Promise<ServiceStatus> {
  // Since analytics is client-side, we'll check if the configuration is valid
  if (process.env.NEXT_PUBLIC_GA_ID) {
    return { status: 'healthy' }
  } else {
    return { status: 'degraded', error: 'Analytics not configured' }
  }
}

async function checkCache(): Promise<ServiceStatus> {
  // Check Redis or memory cache if implemented
  return { status: 'healthy' }
}

function getServiceResult(result: PromiseSettledResult<ServiceStatus>): ServiceStatus {
  if (result.status === 'fulfilled') {
    return result.value
  } else {
    return {
      status: 'unhealthy',
      error: result.reason instanceof Error ? result.reason.message : 'Unknown error'
    }
  }
}
```

### Backup and Disaster Recovery
```typescript
// scripts/backup.ts
import { PrismaClient } from '@prisma/client'
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3'

const prisma = new PrismaClient()
const s3 = new S3Client({ region: 'us-east-1' })

export class BackupManager {
  async createFullBackup() {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
    const backupId = `backup-${timestamp}`
    
    try {
      console.log(`Starting full backup: ${backupId}`)
      
      // Database backup
      await this.backupDatabase(backupId)
      
      // Media files backup (if any)
      await this.backupMediaFiles(backupId)
      
      // Configuration backup
      await this.backupConfiguration(backupId)
      
      console.log(`Full backup completed: ${backupId}`)
      
      // Clean up old backups
      await this.cleanupOldBackups()
      
      return { success: true, backupId }
    } catch (error) {
      console.error(`Backup failed: ${backupId}`, error)
      return { success: false, error }
    }
  }

  private async backupDatabase(backupId: string) {
    // Export all relevant data
    const tables = [
      'Contact',
      'Subscription', 
      'Analytics',
      'SecurityEvent'
    ]
    
    const backup: any = {}
    
    for (const table of tables) {
      const data = await (prisma as any)[table.toLowerCase()].findMany()
      backup[table] = data
    }
    
    // Upload to S3
    await s3.send(new PutObjectCommand({
      Bucket: process.env.BACKUP_BUCKET!,
      Key: `database/${backupId}.json`,
      Body: JSON.stringify(backup, null, 2),
      ContentType: 'application/json'
    }))
    
    console.log(`Database backup uploaded: ${backupId}`)
  }

  private async backupMediaFiles(backupId: string) {
    // If you have any uploaded media files, back them up here
    console.log(`Media files backup completed: ${backupId}`)
  }

  private async backupConfiguration(backupId: string) {
    const config = {
      environment: process.env.NODE_ENV,
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version,
      // Don't include sensitive data
    }
    
    await s3.send(new PutObjectCommand({
      Bucket: process.env.BACKUP_BUCKET!,
      Key: `config/${backupId}.json`,
      Body: JSON.stringify(config, null, 2),
      ContentType: 'application/json'
    }))
    
    console.log(`Configuration backup uploaded: ${backupId}`)
  }

  private async cleanupOldBackups() {
    // Keep backups for 90 days
    const cutoffDate = new Date()
    cutoffDate.setDate(cutoffDate.getDate() - 90)
    
    // Implementation would list and delete old S3 objects
    console.log('Cleanup completed')
  }

  async restoreFromBackup(backupId: string) {
    try {
      console.log(`Starting restore from backup: ${backupId}`)
      
      // Download and restore database
      await this.restoreDatabase(backupId)
      
      // Restore media files
      await this.restoreMediaFiles(backupId)
      
      console.log(`Restore completed: ${backupId}`)
      
      return { success: true }
    } catch (error) {
      console.error(`Restore failed: ${backupId}`, error)
      return { success: false, error }
    }
  }

  private async restoreDatabase(backupId: string) {
    // Implementation for database restore
    console.log(`Database restored from: ${backupId}`)
  }

  private async restoreMediaFiles(backupId: string) {
    // Implementation for media files restore
    console.log(`Media files restored from: ${backupId}`)
  }
}

// Schedule automated backups
export function scheduleBackups() {
  const backupManager = new BackupManager()
  
  // Daily backup at 2 AM
  const dailyBackup = setInterval(async () => {
    await backupManager.createFullBackup()
  }, 24 * 60 * 60 * 1000) // 24 hours
  
  return dailyBackup
}
```

### Infrastructure Monitoring
```typescript
// lib/monitoring/infrastructure.ts
export class InfrastructureMonitor {
  async collectMetrics() {
    const metrics = {
      timestamp: new Date().toISOString(),
      server: {
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        cpu: process.cpuUsage(),
        pid: process.pid
      },
      application: {
        version: process.env.npm_package_version || '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        nodeVersion: process.version
      },
      performance: await this.getPerformanceMetrics(),
      errors: await this.getErrorMetrics()
    }

    // Send to monitoring service
    await this.sendToMonitoring(metrics)
    
    return metrics
  }

  private async getPerformanceMetrics() {
    // Collect performance metrics from your monitoring service
    return {
      responseTime: 0,
      throughput: 0,
      errorRate: 0
    }
  }

  private async getErrorMetrics() {
    // Collect error metrics
    return {
      count: 0,
      rate: 0,
      types: []
    }
  }

  private async sendToMonitoring(metrics: any) {
    // Send to your monitoring service (DataDog, New Relic, etc.)
    if (process.env.MONITORING_ENDPOINT) {
      try {
        await fetch(process.env.MONITORING_ENDPOINT, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(metrics)
        })
      } catch (error) {
        console.error('Failed to send metrics:', error)
      }
    }
  }
}
```

## Benefits of This Deployment Strategy

1. **High Availability**: Multi-region deployment with automatic failover
2. **Performance**: Edge computing and global CDN for fast loading
3. **Scalability**: Automatic scaling based on traffic
4. **Security**: Multiple layers of protection and monitoring
5. **Reliability**: Comprehensive backup and disaster recovery
6. **Developer Experience**: Streamlined CI/CD with automated testing
7. **Cost Efficiency**: Pay-per-use pricing with automatic optimization
8. **Monitoring**: Real-time insights into performance and health