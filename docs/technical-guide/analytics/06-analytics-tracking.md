# 6. Analytics & Tracking Implementation

## Comprehensive Analytics Strategy

### Multi-Platform Analytics Setup
```typescript
// lib/analytics.ts
interface AnalyticsEvent {
  action: string
  category: string
  label?: string
  value?: number
  custom_parameters?: Record<string, any>
}

export class AnalyticsManager {
  private providers: AnalyticsProvider[] = []

  constructor() {
    this.initializeProviders()
  }

  private initializeProviders() {
    // Google Analytics 4
    this.providers.push(new GoogleAnalytics4Provider())
    
    // Meta Pixel (Facebook)
    this.providers.push(new MetaPixelProvider())
    
    // Google Tag Manager
    this.providers.push(new GTMProvider())
    
    // Hotjar for UX analytics
    this.providers.push(new HotjarProvider())
    
    // Microsoft Clarity
    this.providers.push(new ClarityProvider())
    
    // Custom HERO analytics
    this.providers.push(new HeroAnalyticsProvider())
  }

  track(event: AnalyticsEvent) {
    this.providers.forEach(provider => {
      try {
        provider.track(event)
      } catch (error) {
        console.error(`Analytics provider error:`, error)
      }
    })
  }

  page(path: string, title?: string) {
    this.providers.forEach(provider => {
      try {
        provider.page(path, title)
      } catch (error) {
        console.error(`Page tracking error:`, error)
      }
    })
  }

  identify(userId: string, traits?: Record<string, any>) {
    this.providers.forEach(provider => {
      try {
        provider.identify(userId, traits)
      } catch (error) {
        console.error(`User identification error:`, error)
      }
    })
  }
}

// Singleton instance
export const analytics = new AnalyticsManager()
```

### Google Analytics 4 Implementation
```typescript
// lib/analytics/google-analytics.ts
export class GoogleAnalytics4Provider implements AnalyticsProvider {
  private gtag: Function

  constructor() {
    this.initializeGA4()
  }

  private initializeGA4() {
    // Load gtag script
    const script = document.createElement('script')
    script.async = true
    script.src = `https://www.googletagmanager.com/gtag/js?id=${process.env.NEXT_PUBLIC_GA_ID}`
    document.head.appendChild(script)

    // Initialize gtag
    window.dataLayer = window.dataLayer || []
    this.gtag = function() {
      window.dataLayer.push(arguments)
    }
    
    this.gtag('js', new Date())
    this.gtag('config', process.env.NEXT_PUBLIC_GA_ID, {
      page_title: document.title,
      page_location: window.location.href,
      send_page_view: true,
      // Enhanced ecommerce for conversion tracking
      enhanced_conversions: true,
      // Custom parameters
      custom_map: {
        custom_parameter_1: 'lead_source',
        custom_parameter_2: 'service_interest'
      }
    })
  }

  track(event: AnalyticsEvent) {
    this.gtag('event', event.action, {
      event_category: event.category,
      event_label: event.label,
      value: event.value,
      ...event.custom_parameters
    })
  }

  page(path: string, title?: string) {
    this.gtag('config', process.env.NEXT_PUBLIC_GA_ID, {
      page_path: path,
      page_title: title
    })
  }

  identify(userId: string, traits?: Record<string, any>) {
    this.gtag('config', process.env.NEXT_PUBLIC_GA_ID, {
      user_id: userId,
      custom_map: traits
    })
  }

  // E-commerce tracking for service purchases
  trackPurchase(transactionData: {
    transaction_id: string
    value: number
    currency: string
    items: Array<{
      item_id: string
      item_name: string
      category: string
      quantity: number
      price: number
    }>
  }) {
    this.gtag('event', 'purchase', {
      transaction_id: transactionData.transaction_id,
      value: transactionData.value,
      currency: transactionData.currency,
      items: transactionData.items
    })
  }

  // Lead generation tracking
  trackLead(leadData: {
    lead_source: string
    service_interest: string
    contact_method: string
    value?: number
  }) {
    this.gtag('event', 'generate_lead', {
      currency: 'BRL',
      value: leadData.value || 1000, // Estimated lead value
      lead_source: leadData.lead_source,
      service_interest: leadData.service_interest,
      contact_method: leadData.contact_method
    })
  }
}
```

### Conversion Tracking Setup
```typescript
// lib/analytics/conversion-tracking.ts
export class ConversionTracker {
  // Primary conversion goals for HERO
  static GOALS = {
    CONTACT_FORM: 'contact_form_submission',
    PHONE_CALL: 'phone_call',
    WHATSAPP_CONTACT: 'whatsapp_contact',
    EMAIL_CONTACT: 'email_contact',
    SERVICE_INQUIRY: 'service_inquiry',
    CONSULTATION_REQUEST: 'consultation_request',
    NEWSLETTER_SIGNUP: 'newsletter_signup',
    RESOURCE_DOWNLOAD: 'resource_download'
  }

  static trackConversion(goal: string, data: {
    value?: number
    service?: string
    source?: string
    medium?: string
    campaign?: string
  }) {
    // Google Analytics 4 conversion
    analytics.track({
      action: goal,
      category: 'conversion',
      label: data.service,
      value: data.value,
      custom_parameters: {
        lead_source: data.source,
        medium: data.medium,
        campaign: data.campaign,
        service_interest: data.service
      }
    })

    // Facebook Pixel conversion
    if (typeof fbq !== 'undefined') {
      fbq('track', 'Lead', {
        content_name: data.service,
        content_category: 'consulting_service',
        value: data.value,
        currency: 'BRL'
      })
    }

    // Google Ads conversion tracking
    if (typeof gtag !== 'undefined') {
      gtag('event', 'conversion', {
        send_to: 'AW-CONVERSION_ID/CONVERSION_LABEL',
        value: data.value,
        currency: 'BRL',
        transaction_id: this.generateTransactionId()
      })
    }

    // Send to CRM
    this.sendToCRM(goal, data)
  }

  private static generateTransactionId(): string {
    return `hero_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }

  private static async sendToCRM(goal: string, data: any) {
    try {
      await fetch('/api/crm/conversion', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          goal,
          data,
          timestamp: new Date().toISOString(),
          url: window.location.href,
          referrer: document.referrer
        })
      })
    } catch (error) {
      console.error('Failed to send conversion to CRM:', error)
    }
  }
}
```

### User Behavior Analytics
```typescript
// lib/analytics/behavior-tracking.ts
export class BehaviorTracker {
  private scrollDepth: number = 0
  private timeOnPage: number = 0
  private interactions: string[] = []
  private startTime: number = Date.now()

  constructor() {
    this.initializeTracking()
  }

  private initializeTracking() {
    // Scroll depth tracking
    this.trackScrollDepth()
    
    // Time on page tracking
    this.trackTimeOnPage()
    
    // Click tracking
    this.trackClicks()
    
    // Form interactions
    this.trackFormInteractions()
    
    // Video/media interactions
    this.trackMediaInteractions()
  }

  private trackScrollDepth() {
    let maxScroll = 0
    const milestones = [25, 50, 75, 90, 100]
    let trackedMilestones: number[] = []

    const handleScroll = () => {
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop
      const docHeight = document.documentElement.scrollHeight
      const winHeight = window.innerHeight
      const scrollPercent = Math.round((scrollTop / (docHeight - winHeight)) * 100)

      if (scrollPercent > maxScroll) {
        maxScroll = scrollPercent
        
        milestones.forEach(milestone => {
          if (scrollPercent >= milestone && !trackedMilestones.includes(milestone)) {
            trackedMilestones.push(milestone)
            
            analytics.track({
              action: 'scroll_depth',
              category: 'engagement',
              label: `${milestone}%`,
              value: milestone
            })
          }
        })
      }
    }

    window.addEventListener('scroll', this.throttle(handleScroll, 250))
  }

  private trackTimeOnPage() {
    // Track time milestones
    const milestones = [10, 30, 60, 120, 300] // seconds
    let trackedMilestones: number[] = []

    setInterval(() => {
      this.timeOnPage = Math.round((Date.now() - this.startTime) / 1000)
      
      milestones.forEach(milestone => {
        if (this.timeOnPage >= milestone && !trackedMilestones.includes(milestone)) {
          trackedMilestones.push(milestone)
          
          analytics.track({
            action: 'time_on_page',
            category: 'engagement',
            label: `${milestone}s`,
            value: milestone
          })
        }
      })
    }, 10000) // Check every 10 seconds
  }

  private trackClicks() {
    document.addEventListener('click', (event) => {
      const target = event.target as HTMLElement
      const tagName = target.tagName.toLowerCase()
      const classList = Array.from(target.classList).join(' ')
      const href = target.getAttribute('href')
      const text = target.textContent?.trim().substring(0, 50)

      // Track button clicks
      if (tagName === 'button' || target.closest('button')) {
        analytics.track({
          action: 'button_click',
          category: 'interaction',
          label: text || classList,
          custom_parameters: {
            element_type: 'button',
            element_classes: classList
          }
        })
      }

      // Track link clicks
      if (tagName === 'a' && href) {
        const isExternal = href.startsWith('http') && !href.includes(window.location.hostname)
        
        analytics.track({
          action: isExternal ? 'external_link_click' : 'internal_link_click',
          category: 'navigation',
          label: href,
          custom_parameters: {
            link_text: text,
            link_url: href
          }
        })
      }

      // Track CTA clicks
      if (target.closest('[data-cta]')) {
        const ctaName = target.closest('[data-cta]')?.getAttribute('data-cta')
        
        analytics.track({
          action: 'cta_click',
          category: 'conversion',
          label: ctaName,
          custom_parameters: {
            cta_text: text,
            cta_position: this.getElementPosition(target)
          }
        })
      }
    })
  }

  private trackFormInteractions() {
    // Track form starts
    document.addEventListener('focusin', (event) => {
      const target = event.target as HTMLElement
      if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') {
        const form = target.closest('form')
        if (form && !form.hasAttribute('data-tracked')) {
          form.setAttribute('data-tracked', 'true')
          
          analytics.track({
            action: 'form_start',
            category: 'engagement',
            label: form.id || form.className || 'unnamed_form'
          })
        }
      }
    })

    // Track form submissions
    document.addEventListener('submit', (event) => {
      const form = event.target as HTMLFormElement
      
      analytics.track({
        action: 'form_submit',
        category: 'conversion',
        label: form.id || form.className || 'unnamed_form',
        custom_parameters: {
          form_fields: this.getFormFields(form)
        }
      })
    })
  }

  private getElementPosition(element: HTMLElement): string {
    const rect = element.getBoundingClientRect()
    const windowHeight = window.innerHeight
    
    if (rect.top < windowHeight * 0.33) return 'above_fold'
    if (rect.top < windowHeight * 0.66) return 'middle_fold'
    return 'below_fold'
  }

  private getFormFields(form: HTMLFormElement): string[] {
    const inputs = form.querySelectorAll('input, textarea, select')
    return Array.from(inputs).map(input => 
      input.getAttribute('name') || input.getAttribute('id') || 'unnamed_field'
    )
  }

  private throttle(func: Function, limit: number) {
    let inThrottle: boolean
    return function(this: any, ...args: any[]) {
      if (!inThrottle) {
        func.apply(this, args)
        inThrottle = true
        setTimeout(() => inThrottle = false, limit)
      }
    }
  }
}
```

### Heat Map and User Recording Setup
```typescript
// lib/analytics/hotjar.ts
export class HotjarProvider implements AnalyticsProvider {
  constructor() {
    this.initializeHotjar()
  }

  private initializeHotjar() {
    const hjid = process.env.NEXT_PUBLIC_HOTJAR_ID
    if (!hjid) return

    (function(h: any, o: any, t: any, j: any, a?: any, r?: any) {
      h.hj = h.hj || function(...args: any[]) { (h.hj.q = h.hj.q || []).push(args) }
      h._hjSettings = { hjid, hjsv: 6 }
      a = o.getElementsByTagName('head')[0]
      r = o.createElement('script')
      r.async = 1
      r.src = t + h._hjSettings.hjid + j + h._hjSettings.hjsv
      a.appendChild(r)
    })(window, document, 'https://static.hotjar.com/c/hotjar-', '.js?sv=')
  }

  track(event: AnalyticsEvent) {
    if (typeof window.hj !== 'undefined') {
      window.hj('event', event.action)
    }
  }

  page(path: string, title?: string) {
    if (typeof window.hj !== 'undefined') {
      window.hj('stateChange', path)
    }
  }

  identify(userId: string, traits?: Record<string, any>) {
    if (typeof window.hj !== 'undefined') {
      window.hj('identify', userId, traits)
    }
  }

  // Track custom Hotjar events
  trackUserFeedback(feedbackData: {
    rating: number
    comment?: string
    page: string
  }) {
    if (typeof window.hj !== 'undefined') {
      window.hj('event', 'user_feedback')
      window.hj('tagRecording', ['feedback', `rating_${feedbackData.rating}`])
    }
  }
}
```

### Advanced Analytics Dashboard
```typescript
// components/admin/AnalyticsDashboard.tsx
import { useState, useEffect } from 'react'
import { Line, Bar, Doughnut } from 'react-chartjs-2'

interface AnalyticsData {
  overview: {
    sessions: number
    users: number
    pageviews: number
    bounceRate: number
    avgSessionDuration: number
    conversions: number
    conversionRate: number
  }
  traffic: {
    organic: number
    direct: number
    social: number
    referral: number
    paid: number
  }
  conversions: Array<{
    goal: string
    conversions: number
    value: number
    rate: number
  }>
  topPages: Array<{
    page: string
    views: number
    uniqueViews: number
    avgTime: number
    bounceRate: number
  }>
}

export function AnalyticsDashboard() {
  const [data, setData] = useState<AnalyticsData | null>(null)
  const [timeframe, setTimeframe] = useState('30d')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchAnalyticsData(timeframe)
      .then(setData)
      .finally(() => setLoading(false))
  }, [timeframe])

  if (loading) {
    return <div className="animate-pulse">Loading analytics...</div>
  }

  return (
    <div className="space-y-8">
      {/* Overview Metrics */}
      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-4">
        <MetricCard
          title="Sessions"
          value={data?.overview.sessions.toLocaleString() || '0'}
          change={12.5}
          format="number"
        />
        <MetricCard
          title="Users"
          value={data?.overview.users.toLocaleString() || '0'}
          change={8.3}
          format="number"
        />
        <MetricCard
          title="Pageviews"
          value={data?.overview.pageviews.toLocaleString() || '0'}
          change={15.7}
          format="number"
        />
        <MetricCard
          title="Bounce Rate"
          value={`${data?.overview.bounceRate || 0}%`}
          change={-3.2}
          format="percentage"
          inverse
        />
        <MetricCard
          title="Avg Session"
          value={formatDuration(data?.overview.avgSessionDuration || 0)}
          change={5.8}
          format="duration"
        />
        <MetricCard
          title="Conversions"
          value={data?.overview.conversions.toLocaleString() || '0'}
          change={22.1}
          format="number"
        />
        <MetricCard
          title="Conv. Rate"
          value={`${data?.overview.conversionRate || 0}%`}
          change={18.9}
          format="percentage"
        />
      </div>

      {/* Traffic Sources */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Traffic Sources</h3>
          <Doughnut
            data={{
              labels: ['Organic', 'Direct', 'Social', 'Referral', 'Paid'],
              datasets: [{
                data: [
                  data?.traffic.organic || 0,
                  data?.traffic.direct || 0,
                  data?.traffic.social || 0,
                  data?.traffic.referral || 0,
                  data?.traffic.paid || 0
                ],
                backgroundColor: [
                  '#10B981',
                  '#3B82F6',
                  '#8B5CF6',
                  '#F59E0B',
                  '#EF4444'
                ]
              }]
            }}
          />
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Conversion Goals</h3>
          <div className="space-y-4">
            {data?.conversions.map((goal, index) => (
              <div key={index} className="flex justify-between items-center">
                <div>
                  <div className="font-medium">{goal.goal}</div>
                  <div className="text-sm text-gray-500">
                    {goal.conversions} conversions • {goal.rate}% rate
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-medium">R$ {goal.value.toLocaleString()}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Top Pages Performance */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Top Pages Performance</h3>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Page
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Views
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Unique Views
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Avg Time
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Bounce Rate
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {data?.topPages.map((page, index) => (
                <tr key={index}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {page.page}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {page.views.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {page.uniqueViews.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {formatDuration(page.avgTime)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {page.bounceRate}%
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
```

### Privacy-Compliant Analytics
```typescript
// lib/analytics/privacy.ts
export class PrivacyManager {
  private consentLevel: 'none' | 'functional' | 'analytics' | 'marketing' = 'none'
  
  constructor() {
    this.loadConsentPreferences()
  }

  private loadConsentPreferences() {
    const saved = localStorage.getItem('hero_analytics_consent')
    if (saved) {
      this.consentLevel = saved as any
      this.applyConsentSettings()
    } else {
      this.showConsentBanner()
    }
  }

  setConsent(level: 'none' | 'functional' | 'analytics' | 'marketing') {
    this.consentLevel = level
    localStorage.setItem('hero_analytics_consent', level)
    this.applyConsentSettings()
  }

  private applyConsentSettings() {
    // Update Google Analytics consent
    if (typeof gtag !== 'undefined') {
      gtag('consent', 'update', {
        analytics_storage: this.consentLevel === 'analytics' || this.consentLevel === 'marketing' ? 'granted' : 'denied',
        ad_storage: this.consentLevel === 'marketing' ? 'granted' : 'denied',
        functionality_storage: this.consentLevel !== 'none' ? 'granted' : 'denied',
        personalization_storage: this.consentLevel === 'marketing' ? 'granted' : 'denied'
      })
    }

    // Update Facebook Pixel consent
    if (typeof fbq !== 'undefined' && this.consentLevel === 'marketing') {
      fbq('consent', 'grant')
    } else if (typeof fbq !== 'undefined') {
      fbq('consent', 'revoke')
    }
  }

  private showConsentBanner() {
    // Show LGPD/GDPR compliant consent banner
    const banner = document.createElement('div')
    banner.innerHTML = `
      <div class="fixed bottom-0 left-0 right-0 bg-gray-900 text-white p-4 z-50">
        <div class="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between">
          <div class="mb-4 md:mb-0">
            <p class="text-sm">
              Utilizamos cookies para melhorar sua experiência. 
              <a href="/privacidade" class="underline">Saiba mais</a>
            </p>
          </div>
          <div class="flex space-x-4">
            <button onclick="window.privacyManager.setConsent('none')" 
                    class="px-4 py-2 text-sm border border-gray-600 rounded">
              Recusar
            </button>
            <button onclick="window.privacyManager.setConsent('functional')" 
                    class="px-4 py-2 text-sm bg-gray-700 rounded">
              Apenas Funcionais
            </button>
            <button onclick="window.privacyManager.setConsent('analytics')" 
                    class="px-4 py-2 text-sm bg-blue-600 rounded">
              Aceitar Analytics
            </button>
            <button onclick="window.privacyManager.setConsent('marketing')" 
                    class="px-4 py-2 text-sm bg-blue-600 rounded">
              Aceitar Todos
            </button>
          </div>
        </div>
      </div>
    `
    document.body.appendChild(banner)
  }

  canTrack(type: 'functional' | 'analytics' | 'marketing'): boolean {
    const levels = {
      'functional': ['functional', 'analytics', 'marketing'],
      'analytics': ['analytics', 'marketing'],
      'marketing': ['marketing']
    }
    
    return levels[type].includes(this.consentLevel)
  }
}

// Global privacy manager instance
export const privacyManager = new PrivacyManager()
```

## Benefits of This Analytics Strategy

1. **Comprehensive Tracking**: Multi-platform analytics for complete visibility
2. **Conversion Optimization**: Detailed funnel analysis and optimization
3. **User Experience Insights**: Heat maps and behavior analysis
4. **Privacy Compliance**: LGPD/GDPR compliant tracking
5. **Real-time Monitoring**: Live dashboard for immediate insights
6. **ROI Measurement**: Clear attribution and value tracking
7. **Performance Correlation**: Link analytics to performance metrics
8. **Automated Reporting**: Scheduled reports and alerts for key metrics