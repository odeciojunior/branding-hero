# 5. Performance Metrics & Core Web Vitals Targets

## Core Web Vitals Targets

### Target Metrics (2024 Standards)
```typescript
// lib/performance-targets.ts
export const coreWebVitalsTargets = {
  // Largest Contentful Paint - Loading Performance
  LCP: {
    good: 2.5, // seconds
    needsImprovement: 4.0,
    poor: Infinity,
    target: 1.8 // HERO target: 1.8s or better
  },
  
  // First Input Delay - Interactivity
  FID: {
    good: 100, // milliseconds
    needsImprovement: 300,
    poor: Infinity,
    target: 50 // HERO target: 50ms or better
  },
  
  // Cumulative Layout Shift - Visual Stability
  CLS: {
    good: 0.1,
    needsImprovement: 0.25,
    poor: Infinity,
    target: 0.05 // HERO target: 0.05 or better
  },
  
  // Interaction to Next Paint (replacing FID)
  INP: {
    good: 200, // milliseconds
    needsImprovement: 500,
    poor: Infinity,
    target: 150 // HERO target: 150ms or better
  }
}

// Additional Performance Targets
export const performanceTargets = {
  // First Contentful Paint
  FCP: {
    target: 1.2, // seconds
    threshold: 1.8
  },
  
  // Time to Interactive
  TTI: {
    target: 3.0, // seconds
    threshold: 5.0
  },
  
  // Total Blocking Time
  TBT: {
    target: 150, // milliseconds
    threshold: 300
  },
  
  // Speed Index
  speedIndex: {
    target: 2.0, // seconds
    threshold: 3.4
  },
  
  // Lighthouse Performance Score
  lighthouseScore: {
    target: 95, // out of 100
    minimum: 90
  }
}
```

## Performance Monitoring Implementation

### Web Vitals Tracking
```typescript
// lib/web-vitals.ts
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals'

interface WebVitalMetric {
  name: string
  value: number
  id: string
  delta: number
  entries: PerformanceEntry[]
}

export function trackWebVitals() {
  function sendToAnalytics(metric: WebVitalMetric) {
    // Send to analytics service
    gtag('event', metric.name, {
      event_category: 'Web Vitals',
      event_label: metric.id,
      value: Math.round(metric.name === 'CLS' ? metric.value * 1000 : metric.value),
      non_interaction: true,
    })
    
    // Send to custom analytics
    fetch('/api/analytics/web-vitals', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        metric: metric.name,
        value: metric.value,
        id: metric.id,
        url: window.location.pathname,
        timestamp: Date.now()
      })
    })
  }

  getCLS(sendToAnalytics)
  getFID(sendToAnalytics)
  getFCP(sendToAnalytics)
  getLCP(sendToAnalytics)
  getTTFB(sendToAnalytics)
}

// Real User Monitoring (RUM)
export class PerformanceMonitor {
  private metrics: Map<string, number> = new Map()
  private observer: PerformanceObserver | null = null

  constructor() {
    this.initializeObserver()
  }

  private initializeObserver() {
    if (typeof window === 'undefined' || !('PerformanceObserver' in window)) {
      return
    }

    this.observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        this.processEntry(entry)
      }
    })

    // Observe different types of performance entries
    this.observer.observe({ entryTypes: ['navigation', 'paint', 'largest-contentful-paint', 'layout-shift'] })
  }

  private processEntry(entry: PerformanceEntry) {
    switch (entry.entryType) {
      case 'navigation':
        this.trackNavigationTiming(entry as PerformanceNavigationTiming)
        break
      case 'paint':
        this.trackPaintTiming(entry as PerformancePaintTiming)
        break
      case 'largest-contentful-paint':
        this.trackLCP(entry)
        break
      case 'layout-shift':
        this.trackCLS(entry)
        break
    }
  }

  private trackNavigationTiming(entry: PerformanceNavigationTiming) {
    const metrics = {
      dns: entry.domainLookupEnd - entry.domainLookupStart,
      tcp: entry.connectEnd - entry.connectStart,
      ssl: entry.secureConnectionStart > 0 ? entry.connectEnd - entry.secureConnectionStart : 0,
      ttfb: entry.responseStart - entry.requestStart,
      domContentLoaded: entry.domContentLoadedEventEnd - entry.navigationStart,
      windowLoad: entry.loadEventEnd - entry.navigationStart
    }

    Object.entries(metrics).forEach(([key, value]) => {
      this.metrics.set(key, value)
    })

    this.reportMetrics('navigation', metrics)
  }

  private trackPaintTiming(entry: PerformancePaintTiming) {
    this.metrics.set(entry.name, entry.startTime)
    this.reportMetrics('paint', { [entry.name]: entry.startTime })
  }

  private trackLCP(entry: any) {
    this.metrics.set('lcp', entry.startTime)
    this.reportMetrics('lcp', { value: entry.startTime })
  }

  private trackCLS(entry: any) {
    if (!entry.hadRecentInput) {
      const currentCLS = this.metrics.get('cls') || 0
      this.metrics.set('cls', currentCLS + entry.value)
      this.reportMetrics('cls', { value: entry.value })
    }
  }

  private reportMetrics(type: string, metrics: Record<string, number>) {
    fetch('/api/analytics/performance', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        type,
        metrics,
        url: window.location.pathname,
        userAgent: navigator.userAgent,
        timestamp: Date.now()
      })
    }).catch(console.error)
  }
}
```

### Performance API Integration
```typescript
// pages/api/analytics/performance.ts
import { NextApiRequest, NextApiResponse } from 'next'
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' })
  }

  try {
    const { type, metrics, url, userAgent, timestamp } = req.body

    await prisma.performanceMetric.create({
      data: {
        type,
        metrics: JSON.stringify(metrics),
        url,
        userAgent,
        timestamp: new Date(timestamp),
        sessionId: req.headers['x-session-id'] as string || 'anonymous'
      }
    })

    res.status(200).json({ success: true })
  } catch (error) {
    console.error('Performance tracking error:', error)
    res.status(500).json({ error: 'Failed to track performance' })
  }
}
```

## Performance Optimization Strategies

### Image Optimization
```typescript
// components/OptimizedImage.tsx
import Image from 'next/image'
import { useState } from 'react'

interface OptimizedImageProps {
  src: string
  alt: string
  width: number
  height: number
  priority?: boolean
  className?: string
  placeholder?: 'blur' | 'empty'
}

export function OptimizedImage({
  src,
  alt,
  width,
  height,
  priority = false,
  className,
  placeholder = 'blur'
}: OptimizedImageProps) {
  const [isLoading, setIsLoading] = useState(true)

  return (
    <div className={`relative overflow-hidden ${className}`}>
      <Image
        src={src}
        alt={alt}
        width={width}
        height={height}
        priority={priority}
        placeholder={placeholder}
        blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAAIAAoDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAhEAACAQMDBQAAAAAAAAAAAAABAgMABAUGIWGRkqGx0f/EABUBAQEAAAAAAAAAAAAAAAAAAAMF/8QAGhEAAgIDAAAAAAAAAAAAAAAAAAECEgMRkf/aAAwDAQACEQMRAD8AltJagyeH0AthI5xdrLcNM91BF5pX2HaH9bcfaSXWGaRmknyEkayRUyRJGI8eRjp5+VkrWey9nOz2eWONvpOpL6kVRc6wBvyPhMNjVlrUnTJBMJCcdxPqvhZJYokl7eXWWpPLG0WciNDe2V5mLWR8TLN8q7Ea0wStBu6T8bQZptZaKOjgvEi3LmSr8tJQ8FnGawO4bCAShSANkj1VbSO/Pq8LwDOdSXDXPvE="
        onLoadingComplete={() => setIsLoading(false)}
        className={`duration-700 ease-in-out ${
          isLoading
            ? 'scale-110 blur-2xl grayscale'
            : 'scale-100 blur-0 grayscale-0'
        }`}
        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
      />
    </div>
  )
}
```

### Code Splitting and Lazy Loading
```typescript
// components/LazyComponents.tsx
import dynamic from 'next/dynamic'
import { Suspense } from 'react'

// Lazy load heavy components
export const ContactForm = dynamic(
  () => import('./forms/ContactForm').then(mod => ({ default: mod.ContactForm })),
  {
    loading: () => <ContactFormSkeleton />,
    ssr: false // Don't render on server for better initial load
  }
)

export const TestimonialsCarousel = dynamic(
  () => import('./TestimonialsCarousel'),
  {
    loading: () => <CarouselSkeleton />,
    ssr: true
  }
)

export const InteractiveMap = dynamic(
  () => import('./InteractiveMap'),
  {
    loading: () => <MapSkeleton />,
    ssr: false
  }
)

// Skeleton components for loading states
function ContactFormSkeleton() {
  return (
    <div className="animate-pulse space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="h-12 bg-gray-200 rounded"></div>
        <div className="h-12 bg-gray-200 rounded"></div>
      </div>
      <div className="h-32 bg-gray-200 rounded"></div>
      <div className="h-12 bg-gray-200 rounded"></div>
    </div>
  )
}

// Progressive enhancement wrapper
export function ProgressiveWrapper({ 
  fallback, 
  children 
}: { 
  fallback: React.ReactNode
  children: React.ReactNode 
}) {
  return (
    <Suspense fallback={fallback}>
      {children}
    </Suspense>
  )
}
```

### Resource Hints and Preloading
```typescript
// components/PerformanceOptimizations.tsx
import Head from 'next/head'

export function PerformanceOptimizations() {
  return (
    <Head>
      {/* DNS prefetch for external domains */}
      <link rel="dns-prefetch" href="//fonts.googleapis.com" />
      <link rel="dns-prefetch" href="//www.google-analytics.com" />
      <link rel="dns-prefetch" href="//cdn.sanity.io" />
      
      {/* Preconnect to critical domains */}
      <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
      <link rel="preconnect" href="https://cdn.sanity.io" />
      
      {/* Preload critical resources */}
      <link
        rel="preload"
        href="/fonts/inter-var.woff2"
        as="font"
        type="font/woff2"
        crossOrigin=""
      />
      <link
        rel="preload"
        href="/hero-background.webp"
        as="image"
        type="image/webp"
      />
      
      {/* Preload critical CSS */}
      <link rel="preload" href="/styles/critical.css" as="style" />
      
      {/* Module preload for JavaScript */}
      <link rel="modulepreload" href="/js/critical.js" />
    </Head>
  )
}
```

## Bundle Optimization

### Webpack Bundle Analysis
```typescript
// next.config.js - Bundle optimization
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer')

/** @type {import('next').NextConfig} */
const nextConfig = {
  // Optimize bundle size
  experimental: {
    optimizePackageImports: [
      '@heroicons/react',
      'lucide-react',
      '@headlessui/react'
    ]
  },
  
  webpack: (config, { buildId, dev, isServer, defaultLoaders, webpack }) => {
    // Bundle analyzer in development
    if (process.env.ANALYZE === 'true') {
      config.plugins.push(
        new BundleAnalyzerPlugin({
          analyzerMode: 'server',
          analyzerPort: isServer ? 8888 : 8889,
          openAnalyzer: true,
        })
      )
    }

    // Tree shaking optimization
    config.optimization = {
      ...config.optimization,
      usedExports: true,
      sideEffects: false
    }

    // Split chunks for better caching
    if (!isServer) {
      config.optimization.splitChunks = {
        chunks: 'all',
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            chunks: 'all',
          },
          common: {
            name: 'common',
            minChunks: 2,
            chunks: 'all',
            enforce: true,
          },
        },
      }
    }

    return config
  },
}

module.exports = nextConfig
```

### Code Splitting Strategy
```typescript
// lib/code-splitting.ts
export const codeSpittingStrategy = {
  // Route-based splitting (automatic with Next.js)
  routes: 'automatic',
  
  // Component-based splitting
  components: {
    // Critical components (loaded immediately)
    critical: [
      'Header',
      'Navigation', 
      'HeroSection',
      'Footer'
    ],
    
    // Above-the-fold components (preloaded)
    aboveFold: [
      'ServicesPreview',
      'ValueProposition'
    ],
    
    // Below-the-fold components (lazy loaded)
    belowFold: [
      'ContactForm',
      'Testimonials',
      'BlogPosts',
      'SocialProof'
    ],
    
    // Interactive components (loaded on interaction)
    interactive: [
      'Calculator',
      'ContactForm',
      'Newsletter',
      'InteractiveMap'
    ]
  },
  
  // Library splitting
  libraries: {
    // Core libraries (always loaded)
    core: ['react', 'react-dom', 'next'],
    
    // UI libraries (chunked separately)
    ui: ['@headlessui/react', '@heroicons/react'],
    
    // Utility libraries (lazy loaded)
    utils: ['date-fns', 'lodash-es'],
    
    // Analytics libraries (async loaded)
    analytics: ['gtag', 'hotjar']
  }
}
```

## Performance Budgets

### Performance Budget Configuration
```typescript
// performance-budget.config.ts
export const performanceBudget = {
  // Size budgets
  bundles: {
    'main.js': '150kb', // Main JavaScript bundle
    'vendors.js': '200kb', // Third-party libraries
    'styles.css': '50kb', // CSS bundle
    'images': '500kb', // Total images per page
    'fonts': '100kb', // Font files
    'total': '1mb' // Total page weight
  },
  
  // Timing budgets
  metrics: {
    FCP: 1500, // milliseconds
    LCP: 2000,
    TTI: 3000,
    FID: 100,
    CLS: 0.1,
    speedIndex: 2000
  },
  
  // Resource budgets
  resources: {
    requests: 50, // Maximum HTTP requests
    domNodes: 1500, // Maximum DOM nodes
    jsExecutionTime: 2000, // JavaScript execution time (ms)
    renderTime: 16 // Frame render time (ms for 60fps)
  }
}

// Budget monitoring
export function checkPerformanceBudget(metrics: any) {
  const violations = []
  
  Object.entries(performanceBudget.metrics).forEach(([metric, budget]) => {
    if (metrics[metric] > budget) {
      violations.push({
        metric,
        actual: metrics[metric],
        budget,
        violation: metrics[metric] - budget
      })
    }
  })
  
  return {
    passed: violations.length === 0,
    violations
  }
}
```

### Automated Performance Testing
```typescript
// scripts/performance-test.js
const lighthouse = require('lighthouse')
const chromeLauncher = require('chrome-launcher')

async function runPerformanceAudit(url) {
  const chrome = await chromeLauncher.launch({ chromeFlags: ['--headless'] })
  
  const options = {
    logLevel: 'info',
    output: 'json',
    onlyCategories: ['performance'],
    port: chrome.port,
  }
  
  const runnerResult = await lighthouse(url, options)
  
  await chrome.kill()
  
  const { lhr } = runnerResult
  const { categories, audits } = lhr
  
  const performanceScore = categories.performance.score * 100
  
  const metrics = {
    performanceScore,
    fcp: audits['first-contentful-paint'].numericValue,
    lcp: audits['largest-contentful-paint'].numericValue,
    cls: audits['cumulative-layout-shift'].numericValue,
    tti: audits['interactive'].numericValue,
    speedIndex: audits['speed-index'].numericValue
  }
  
  // Check against performance budget
  const budgetCheck = checkPerformanceBudget(metrics)
  
  console.log('Performance Metrics:', metrics)
  console.log('Budget Check:', budgetCheck)
  
  // Fail CI if budget is exceeded
  if (!budgetCheck.passed) {
    console.error('Performance budget exceeded!')
    process.exit(1)
  }
  
  return metrics
}

// Run for all critical pages
const pages = [
  'https://hero.com.br',
  'https://hero.com.br/servicos',
  'https://hero.com.br/sobre',
  'https://hero.com.br/contato'
]

Promise.all(pages.map(runPerformanceAudit))
  .then(results => {
    console.log('All pages passed performance budget!')
  })
  .catch(error => {
    console.error('Performance test failed:', error)
    process.exit(1)
  })
```

## Performance Monitoring Dashboard

### Real-time Performance Dashboard
```typescript
// components/admin/PerformanceDashboard.tsx
import { useState, useEffect } from 'react'
import { Line, Bar } from 'react-chartjs-2'

export function PerformanceDashboard() {
  const [metrics, setMetrics] = useState(null)
  const [timeframe, setTimeframe] = useState('24h')

  useEffect(() => {
    fetchPerformanceMetrics(timeframe).then(setMetrics)
  }, [timeframe])

  return (
    <div className="space-y-8">
      {/* Core Web Vitals Overview */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <MetricCard
          title="LCP (Loading)"
          value={`${metrics?.lcp || 0}s`}
          target={coreWebVitalsTargets.LCP.target}
          status={getMetricStatus(metrics?.lcp, coreWebVitalsTargets.LCP)}
        />
        <MetricCard
          title="FID (Interactivity)"
          value={`${metrics?.fid || 0}ms`}
          target={coreWebVitalsTargets.FID.target}
          status={getMetricStatus(metrics?.fid, coreWebVitalsTargets.FID)}
        />
        <MetricCard
          title="CLS (Stability)"
          value={metrics?.cls || 0}
          target={coreWebVitalsTargets.CLS.target}
          status={getMetricStatus(metrics?.cls, coreWebVitalsTargets.CLS)}
        />
      </div>

      {/* Performance Trends */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Performance Trends</h3>
          <Line data={performanceTrendData} options={chartOptions} />
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Page Speed Distribution</h3>
          <Bar data={pageSpeedDistribution} options={chartOptions} />
        </div>
      </div>

      {/* Performance Budget Status */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Performance Budget Status</h3>
        <PerformanceBudgetStatus budget={performanceBudget} current={metrics} />
      </div>
    </div>
  )
}

function MetricCard({ title, value, target, status }) {
  const statusColor = {
    good: 'text-green-600 bg-green-100',
    warning: 'text-yellow-600 bg-yellow-100',
    poor: 'text-red-600 bg-red-100'
  }[status]

  return (
    <div className="bg-white p-6 rounded-lg shadow">
      <div className="flex items-center justify-between">
        <h4 className="text-sm font-medium text-gray-500">{title}</h4>
        <span className={`px-2 py-1 text-xs rounded-full ${statusColor}`}>
          {status}
        </span>
      </div>
      <div className="mt-2">
        <div className="text-2xl font-bold text-gray-900">{value}</div>
        <div className="text-sm text-gray-500">Target: {target}</div>
      </div>
    </div>
  )
}
```

## Benefits of This Performance Strategy

1. **User Experience**: Fast loading times improve user satisfaction
2. **SEO Rankings**: Core Web Vitals are ranking factors
3. **Conversion Rates**: Every 100ms improvement increases conversions by 1%
4. **Cost Efficiency**: Optimized performance reduces hosting costs
5. **Mobile Experience**: Critical for mobile users and Core Web Vitals
6. **Real-time Monitoring**: Immediate detection of performance regressions
7. **Competitive Advantage**: Faster sites outperform slower competitors
8. **Business Impact**: Performance directly correlates with revenue