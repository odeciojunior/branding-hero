# 4. SEO Optimization Requirements

## Technical SEO Foundation

### Next.js SEO Configuration
```typescript
// next.config.js - SEO-optimized configuration
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable experimental features for better SEO
  experimental: {
    appDir: true,
    optimizePackageImports: ['lucide-react', '@heroicons/react']
  },
  
  // Image optimization for faster loading
  images: {
    formats: ['image/webp', 'image/avif'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    domains: ['cdn.sanity.io', 'images.unsplash.com']
  },
  
  // Compress responses
  compress: true,
  
  // Generate sitemap and robots.txt
  async rewrites() {
    return [
      {
        source: '/sitemap.xml',
        destination: '/api/sitemap'
      },
      {
        source: '/robots.txt',
        destination: '/api/robots'
      }
    ]
  },
  
  // SEO-friendly headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY'
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block'
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin'
          }
        ]
      }
    ]
  }
}

module.exports = nextConfig
```

### Metadata API Integration
```typescript
// app/layout.tsx - Root layout with global SEO
import { Metadata } from 'next'
import { Inter, Playfair_Display } from 'next/font/google'

const inter = Inter({ 
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter'
})

const playfair = Playfair_Display({ 
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-playfair'
})

export const metadata: Metadata = {
  metadataBase: new URL('https://hero.com.br'),
  title: {
    default: 'HERO - Estratégia e Crescimento para Empresas',
    template: '%s | HERO'
  },
  description: 'Transformamos negócios através de estratégias personalizadas, branding inovador e soluções digitais que geram resultados reais e sustentáveis.',
  keywords: [
    'consultoria empresarial',
    'estratégia de negócios',
    'branding',
    'transformação digital',
    'crescimento empresarial',
    'consultoria estratégica',
    'hero consultoria'
  ],
  authors: [{ name: 'HERO Consultoria' }],
  creator: 'HERO',
  publisher: 'HERO',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  openGraph: {
    type: 'website',
    locale: 'pt_BR',
    url: 'https://hero.com.br',
    siteName: 'HERO',
    title: 'HERO - Estratégia e Crescimento para Empresas',
    description: 'Transformamos negócios através de estratégias personalizadas, branding inovador e soluções digitais.',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'HERO - Consultoria Estratégica'
      }
    ]
  },
  twitter: {
    card: 'summary_large_image',
    title: 'HERO - Estratégia e Crescimento para Empresas',
    description: 'Transformamos negócios através de estratégias personalizadas e soluções digitais.',
    images: ['/og-image.png'],
    creator: '@heroconsultoria'
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'google-site-verification-code',
    yandex: 'yandex-verification-code',
    yahoo: 'yahoo-verification-code'
  }
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR" className={`${inter.variable} ${playfair.variable}`}>
      <head>
        <link rel="canonical" href="https://hero.com.br" />
        <link rel="alternate" hrefLang="pt" href="https://hero.com.br" />
        <link rel="alternate" hrefLang="en" href="https://hero.com.br/en" />
        <link rel="alternate" hrefLang="es" href="https://hero.com.br/es" />
        <link rel="alternate" hrefLang="x-default" href="https://hero.com.br" />
      </head>
      <body className="font-sans antialiased">
        {children}
      </body>
    </html>
  )
}
```

### Dynamic Page SEO
```typescript
// app/[slug]/page.tsx - Dynamic page metadata
import { Metadata } from 'next'
import { client } from '@/lib/sanity'
import { notFound } from 'next/navigation'

interface PageProps {
  params: { slug: string }
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const page = await client.fetch(`
    *[_type == "page" && slug.current == $slug][0] {
      title,
      seo,
      slug
    }
  `, { slug: params.slug })

  if (!page) {
    return {}
  }

  const title = page.seo?.metaTitle?.pt || page.title?.pt
  const description = page.seo?.metaDescription?.pt
  const url = `https://hero.com.br/${page.slug.current}`

  return {
    title,
    description,
    canonical: page.seo?.canonicalUrl || url,
    openGraph: {
      title,
      description,
      url,
      images: page.seo?.ogImage ? [
        {
          url: page.seo.ogImage.asset.url,
          width: 1200,
          height: 630,
          alt: page.seo.ogImage.alt || title
        }
      ] : undefined
    },
    twitter: {
      title,
      description,
      images: page.seo?.ogImage ? [page.seo.ogImage.asset.url] : undefined
    },
    robots: {
      index: !page.seo?.noIndex,
      follow: !page.seo?.noIndex
    },
    keywords: page.seo?.keywords || []
  }
}
```

## Technical SEO Implementation

### Structured Data (JSON-LD)
```typescript
// components/seo/StructuredData.tsx
interface OrganizationSchema {
  "@context": "https://schema.org"
  "@type": "Organization"
  name: string
  url: string
  logo: string
  description: string
  address: {
    "@type": "PostalAddress"
    streetAddress: string
    addressLocality: string
    addressRegion: string
    postalCode: string
    addressCountry: string
  }
  contactPoint: {
    "@type": "ContactPoint"
    telephone: string
    contactType: string
    availableLanguage: string[]
  }
  sameAs: string[]
}

export function OrganizationStructuredData() {
  const schema: OrganizationSchema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: "HERO Consultoria",
    url: "https://hero.com.br",
    logo: "https://hero.com.br/logo.png",
    description: "Consultoria estratégica especializada em transformação digital e crescimento empresarial",
    address: {
      "@type": "PostalAddress",
      streetAddress: "Rua das Empresas, 123",
      addressLocality: "São Paulo",
      addressRegion: "SP",
      postalCode: "01234-567",
      addressCountry: "BR"
    },
    contactPoint: {
      "@type": "ContactPoint",
      telephone: "+55-11-9999-9999",
      contactType: "customer service",
      availableLanguage: ["Portuguese", "English", "Spanish"]
    },
    sameAs: [
      "https://linkedin.com/company/hero",
      "https://instagram.com/heroconsultoria",
      "https://facebook.com/heroconsultoria"
    ]
  }

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  )
}

// Service page structured data
export function ServiceStructuredData({ service }: { service: any }) {
  const schema = {
    "@context": "https://schema.org",
    "@type": "Service",
    name: service.name.pt,
    description: service.shortDescription.pt,
    provider: {
      "@type": "Organization",
      name: "HERO Consultoria",
      url: "https://hero.com.br"
    },
    areaServed: {
      "@type": "Country",
      name: "Brazil"
    },
    serviceType: "Business Consulting"
  }

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  )
}
```

### Sitemap Generation
```typescript
// app/api/sitemap/route.ts
import { NextResponse } from 'next/server'
import { client } from '@/lib/sanity'

export async function GET() {
  const pages = await client.fetch(`
    *[_type == "page" && status == "published"] {
      slug,
      _updatedAt
    }
  `)

  const services = await client.fetch(`
    *[_type == "service"] {
      slug,
      _updatedAt
    }
  `)

  const baseUrl = 'https://hero.com.br'
  
  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
            xmlns:xhtml="http://www.w3.org/1999/xhtml">
      <url>
        <loc>${baseUrl}</loc>
        <lastmod>${new Date().toISOString()}</lastmod>
        <changefreq>daily</changefreq>
        <priority>1.0</priority>
        <xhtml:link rel="alternate" hreflang="pt" href="${baseUrl}" />
        <xhtml:link rel="alternate" hreflang="en" href="${baseUrl}/en" />
        <xhtml:link rel="alternate" hreflang="es" href="${baseUrl}/es" />
      </url>
      ${pages.map((page: any) => `
        <url>
          <loc>${baseUrl}/${page.slug.current}</loc>
          <lastmod>${new Date(page._updatedAt).toISOString()}</lastmod>
          <changefreq>weekly</changefreq>
          <priority>0.8</priority>
        </url>
      `).join('')}
      ${services.map((service: any) => `
        <url>
          <loc>${baseUrl}/servicos/${service.slug.current}</loc>
          <lastmod>${new Date(service._updatedAt).toISOString()}</lastmod>
          <changefreq>monthly</changefreq>
          <priority>0.6</priority>
        </url>
      `).join('')}
    </urlset>`

  return new NextResponse(sitemap, {
    headers: {
      'Content-Type': 'application/xml',
      'Cache-Control': 'public, max-age=3600, s-maxage=3600'
    }
  })
}
```

### Robots.txt Generation
```typescript
// app/api/robots/route.ts
import { NextResponse } from 'next/server'

export async function GET() {
  const robots = `User-agent: *
Allow: /

User-agent: Googlebot
Allow: /
Crawl-delay: 1

User-agent: Bingbot
Allow: /
Crawl-delay: 1

Sitemap: https://hero.com.br/sitemap.xml

# Block admin and API routes
Disallow: /admin/
Disallow: /api/
Disallow: /_next/
Disallow: /studio/

# Block search and filter pages
Disallow: /*?*search=*
Disallow: /*?*filter=*`

  return new NextResponse(robots, {
    headers: {
      'Content-Type': 'text/plain',
      'Cache-Control': 'public, max-age=86400'
    }
  })
}
```

## Content SEO Strategy

### Keyword Research and Implementation
```typescript
// lib/seo-keywords.ts
export const seoKeywords = {
  primary: [
    'consultoria empresarial',
    'estratégia de negócios',
    'consultoria estratégica',
    'transformação digital',
    'crescimento empresarial'
  ],
  secondary: [
    'branding corporativo',
    'identidade visual',
    'marketing digital',
    'otimização de processos',
    'inovação empresarial'
  ],
  longTail: [
    'consultoria empresarial em são paulo',
    'como fazer estratégia de negócios',
    'empresa de branding e design',
    'consultoria para transformação digital',
    'serviços de crescimento empresarial'
  ],
  local: [
    'consultoria empresarial são paulo',
    'consultoria estratégica sp',
    'branding são paulo',
    'consultoria empresarial brasil'
  ]
}

// SEO content analysis
export function analyzeSEOContent(content: string, targetKeyword: string) {
  const wordCount = content.split(' ').length
  const keywordDensity = (content.match(new RegExp(targetKeyword, 'gi')) || []).length / wordCount * 100
  
  return {
    wordCount,
    keywordDensity,
    recommendations: {
      minWords: wordCount >= 300,
      maxWords: wordCount <= 2000,
      keywordDensity: keywordDensity >= 0.5 && keywordDensity <= 2.5,
      hasTitle: content.includes('<h1'),
      hasSubheadings: content.includes('<h2') || content.includes('<h3'),
      hasImages: content.includes('<img'),
      hasInternalLinks: content.includes('href="/')
    }
  }
}
```

### Content Optimization Components
```typescript
// components/seo/SEOOptimizedContent.tsx
import { ReactNode } from 'react'

interface SEOContentProps {
  title: string
  description: string
  keywords: string[]
  children: ReactNode
  schema?: object
}

export function SEOOptimizedContent({
  title,
  description,
  keywords,
  children,
  schema
}: SEOContentProps) {
  return (
    <article>
      <header>
        <h1 className="text-4xl font-bold text-hero-navy mb-4">
          {title}
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          {description}
        </p>
      </header>
      
      <div className="prose prose-lg max-w-none">
        {children}
      </div>
      
      {/* Hidden keywords for SEO (use sparingly) */}
      <div className="sr-only">
        {keywords.join(', ')}
      </div>
      
      {/* Structured data */}
      {schema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
        />
      )}
    </article>
  )
}
```

## Local SEO Implementation

### Google My Business Integration
```typescript
// components/seo/LocalBusinessSchema.tsx
export function LocalBusinessSchema() {
  const schema = {
    "@context": "https://schema.org",
    "@type": "ProfessionalService",
    name: "HERO Consultoria",
    image: "https://hero.com.br/hero-office.jpg",
    "@id": "https://hero.com.br",
    url: "https://hero.com.br",
    telephone: "+55-11-9999-9999",
    priceRange: "$$",
    address: {
      "@type": "PostalAddress",
      streetAddress: "Rua das Empresas, 123",
      addressLocality: "São Paulo",
      addressRegion: "SP",
      postalCode: "01234-567",
      addressCountry: "BR"
    },
    geo: {
      "@type": "GeoCoordinates",
      latitude: -23.5505,
      longitude: -46.6333
    },
    openingHoursSpecification: [
      {
        "@type": "OpeningHoursSpecification",
        dayOfWeek: [
          "Monday",
          "Tuesday", 
          "Wednesday",
          "Thursday",
          "Friday"
        ],
        opens: "09:00",
        closes: "18:00"
      }
    ],
    sameAs: [
      "https://www.facebook.com/heroconsultoria",
      "https://www.linkedin.com/company/hero",
      "https://www.instagram.com/heroconsultoria"
    ]
  }

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  )
}
```

### Local Content Strategy
```typescript
// content/local-seo.ts
export const localSEOContent = {
  locations: [
    {
      city: 'São Paulo',
      state: 'SP',
      keywords: [
        'consultoria empresarial são paulo',
        'estratégia de negócios sp',
        'branding são paulo'
      ],
      content: {
        title: 'Consultoria Empresarial em São Paulo - HERO',
        description: 'Especialistas em consultoria estratégica e crescimento empresarial em São Paulo. Transformamos negócios com estratégias personalizadas.'
      }
    },
    {
      city: 'Rio de Janeiro',
      state: 'RJ',
      keywords: [
        'consultoria empresarial rio de janeiro',
        'estratégia de negócios rj',
        'branding rio de janeiro'
      ],
      content: {
        title: 'Consultoria Empresarial no Rio de Janeiro - HERO',
        description: 'Consultoria estratégica especializada no Rio de Janeiro. Soluções personalizadas para o crescimento do seu negócio.'
      }
    }
  ]
}
```

## International SEO (Hreflang)

### Multi-language Setup
```typescript
// app/[locale]/layout.tsx
import { notFound } from 'next/navigation'
import { getRequestConfig } from 'next-intl/server'

const locales = ['pt', 'en', 'es']

export default getRequestConfig(async ({ locale }) => {
  if (!locales.includes(locale as any)) notFound()

  return {
    messages: (await import(`../../messages/${locale}.json`)).default
  }
})

// Generate hreflang tags
export function HreflangTags({ pathname }: { pathname: string }) {
  const baseUrl = 'https://hero.com.br'
  
  return (
    <>
      <link rel="alternate" hrefLang="pt" href={`${baseUrl}${pathname}`} />
      <link rel="alternate" hrefLang="en" href={`${baseUrl}/en${pathname}`} />
      <link rel="alternate" hrefLang="es" href={`${baseUrl}/es${pathname}`} />
      <link rel="alternate" hrefLang="x-default" href={`${baseUrl}${pathname}`} />
    </>
  )
}
```

## SEO Monitoring and Analytics

### Custom SEO Dashboard
```typescript
// components/admin/SEODashboard.tsx
import { useState, useEffect } from 'react'

interface SEOMetrics {
  rankings: { keyword: string; position: number; change: number }[]
  visibility: number
  clicks: number
  impressions: number
  ctr: number
  avgPosition: number
}

export function SEODashboard() {
  const [metrics, setMetrics] = useState<SEOMetrics | null>(null)
  const [timeframe, setTimeframe] = useState('30d')

  useEffect(() => {
    fetchSEOMetrics(timeframe).then(setMetrics)
  }, [timeframe])

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <MetricCard
        title="Visibilidade"
        value={`${metrics?.visibility || 0}%`}
        change={+5.2}
        trend="up"
      />
      <MetricCard
        title="Cliques"
        value={metrics?.clicks || 0}
        change={+12.3}
        trend="up"
      />
      <MetricCard
        title="Impressões"
        value={metrics?.impressions || 0}
        change={+8.7}
        trend="up"
      />
      <MetricCard
        title="CTR Médio"
        value={`${metrics?.ctr || 0}%`}
        change={-0.3}
        trend="down"
      />
    </div>
  )
}
```

### SEO Performance Tracking
```typescript
// lib/seo-analytics.ts
export async function trackSEOPerformance() {
  const metrics = {
    pageSpeed: await measurePageSpeed(),
    coreWebVitals: await getCoreWebVitals(),
    rankingPositions: await getRankingPositions(),
    backlinks: await getBacklinkData(),
    organicTraffic: await getOrganicTraffic()
  }

  // Send to analytics service
  await sendToAnalytics('seo_performance', metrics)
  
  return metrics
}

async function measurePageSpeed() {
  // Implementation for PageSpeed Insights API
  const response = await fetch(
    `https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://hero.com.br&key=${process.env.PAGESPEED_API_KEY}`
  )
  const data = await response.json()
  
  return {
    desktop: data.lighthouseResult.categories.performance.score * 100,
    mobile: data.lighthouseResult.categories.performance.score * 100
  }
}
```

## SEO Checklist and Targets

### On-Page SEO Checklist
```typescript
export const seoChecklist = {
  technical: [
    { item: 'Meta title (50-60 chars)', required: true },
    { item: 'Meta description (150-160 chars)', required: true },
    { item: 'H1 tag with target keyword', required: true },
    { item: 'H2-H6 hierarchy', required: true },
    { item: 'Alt text for images', required: true },
    { item: 'Internal linking', required: true },
    { item: 'Schema markup', required: true },
    { item: 'Canonical URL', required: true },
    { item: 'Mobile responsive', required: true },
    { item: 'Page speed > 90', required: true }
  ],
  content: [
    { item: 'Target keyword in title', required: true },
    { item: 'Keyword in first 100 words', required: true },
    { item: 'Content length 300+ words', required: true },
    { item: 'Keyword density 0.5-2.5%', required: true },
    { item: 'Related keywords used', required: true },
    { item: 'High-quality images', required: true },
    { item: 'Readable content structure', required: true }
  ]
}
```

### SEO Targets and KPIs
```typescript
export const seoTargets = {
  rankings: {
    primary_keywords: {
      target: 'Top 3 positions',
      timeframe: '6 months'
    },
    secondary_keywords: {
      target: 'Top 10 positions', 
      timeframe: '3 months'
    },
    long_tail: {
      target: 'Top 5 positions',
      timeframe: '2 months'
    }
  },
  traffic: {
    organic_growth: '+150% in 12 months',
    conversion_rate: '3.5% from organic traffic',
    local_visibility: '80% for local keywords'
  },
  technical: {
    page_speed: 'Score > 90 on all pages',
    core_web_vitals: 'Pass all metrics',
    mobile_usability: '100% mobile-friendly'
  }
}
```

## Benefits of This SEO Strategy

1. **Technical Excellence**: Comprehensive technical SEO foundation
2. **Content Optimization**: Strategic keyword targeting and content quality
3. **Local Dominance**: Strong local SEO for geographic targeting
4. **International Ready**: Multi-language support with proper hreflang
5. **Performance Monitoring**: Real-time SEO metrics and tracking
6. **User Experience**: SEO practices that enhance user experience
7. **Conversion Focus**: SEO optimized for business goals and conversions
8. **Future Proof**: Scalable SEO architecture for growth