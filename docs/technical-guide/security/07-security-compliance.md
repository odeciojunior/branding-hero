# 7. Security & Compliance Considerations

## Security Architecture Overview

### Defense in Depth Strategy
```typescript
// lib/security/security-config.ts
export const securityConfig = {
  // Content Security Policy
  csp: {
    defaultSrc: ["'self'"],
    scriptSrc: [
      "'self'",
      "'unsafe-inline'", // Only for critical inline scripts
      "https://www.googletagmanager.com",
      "https://connect.facebook.net",
      "https://static.hotjar.com"
    ],
    styleSrc: [
      "'self'",
      "'unsafe-inline'", // Required for CSS-in-JS
      "https://fonts.googleapis.com"
    ],
    imgSrc: [
      "'self'",
      "data:",
      "https://cdn.sanity.io",
      "https://images.unsplash.com",
      "https://www.google-analytics.com"
    ],
    fontSrc: [
      "'self'",
      "https://fonts.gstatic.com"
    ],
    connectSrc: [
      "'self'",
      "https://api.sanity.io",
      "https://www.google-analytics.com",
      "https://region1.google-analytics.com"
    ],
    frameSrc: ["'none'"],
    objectSrc: ["'none'"],
    mediaSrc: ["'self'"],
    workerSrc: ["'self'"],
    childSrc: ["'none'"],
    formAction: ["'self'"],
    frameAncestors: ["'none'"],
    baseUri: ["'self'"],
    upgradeInsecureRequests: true
  },

  // Security Headers
  headers: {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload'
  },

  // Rate Limiting
  rateLimiting: {
    api: {
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 100 // requests per window
    },
    contact: {
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 5 // form submissions per hour
    },
    auth: {
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 5 // login attempts per window
    }
  }
}
```

### Middleware Security Implementation
```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server'
import { rateLimit } from '@/lib/security/rate-limiting'
import { validateCSRF } from '@/lib/security/csrf'
import { securityHeaders } from '@/lib/security/headers'

export async function middleware(request: NextRequest) {
  const response = NextResponse.next()

  // Apply security headers to all responses
  securityHeaders.forEach((value, key) => {
    response.headers.set(key, value)
  })

  // Content Security Policy
  response.headers.set(
    'Content-Security-Policy',
    generateCSPHeader(request.nextUrl.pathname)
  )

  // Rate limiting for API routes
  if (request.nextUrl.pathname.startsWith('/api/')) {
    const rateLimitResult = await rateLimit(request)
    if (!rateLimitResult.success) {
      return new NextResponse(
        JSON.stringify({ error: 'Too many requests' }),
        { 
          status: 429,
          headers: {
            'Content-Type': 'application/json',
            'Retry-After': '900' // 15 minutes
          }
        }
      )
    }
  }

  // CSRF protection for state-changing requests
  if (['POST', 'PUT', 'DELETE', 'PATCH'].includes(request.method)) {
    const csrfResult = await validateCSRF(request)
    if (!csrfResult.valid) {
      return new NextResponse(
        JSON.stringify({ error: 'Invalid CSRF token' }),
        { 
          status: 403,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }
  }

  // Bot detection and blocking
  const botDetection = detectBot(request)
  if (botDetection.isBot && botDetection.malicious) {
    return new NextResponse('Forbidden', { status: 403 })
  }

  return response
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico).*)',
    '/api/:path*'
  ]
}
```

### Input Validation and Sanitization
```typescript
// lib/security/validation.ts
import { z } from 'zod'
import DOMPurify from 'isomorphic-dompurify'

// Contact form validation schema
export const contactFormSchema = z.object({
  name: z.string()
    .min(2, 'Nome deve ter pelo menos 2 caracteres')
    .max(100, 'Nome muito longo')
    .regex(/^[\p{L}\s.-]+$/u, 'Nome contém caracteres inválidos'),
  
  email: z.string()
    .email('Email inválido')
    .max(254, 'Email muito longo')
    .transform(email => email.toLowerCase().trim()),
  
  phone: z.string()
    .regex(/^[\d\s()+-]+$/, 'Telefone inválido')
    .min(10, 'Telefone deve ter pelo menos 10 dígitos')
    .max(20, 'Telefone muito longo')
    .transform(phone => phone.replace(/\D/g, '')),
  
  company: z.string()
    .max(200, 'Nome da empresa muito longo')
    .optional()
    .transform(company => company ? sanitizeString(company) : undefined),
  
  message: z.string()
    .min(10, 'Mensagem deve ter pelo menos 10 caracteres')
    .max(2000, 'Mensagem muito longa')
    .transform(message => sanitizeString(message)),
  
  service: z.enum([
    'strategy',
    'branding',
    'digital',
    'consulting',
    'other'
  ]).optional(),
  
  // Honeypot field for bot detection
  website: z.string().max(0, 'Campo deve estar vazio').optional(),
  
  // CSRF token
  csrfToken: z.string().min(1, 'Token CSRF obrigatório')
})

export function sanitizeString(input: string): string {
  // Remove any HTML tags and dangerous characters
  return DOMPurify.sanitize(input, { 
    ALLOWED_TAGS: [],
    ALLOWED_ATTR: []
  }).trim()
}

export function validateAndSanitizeInput<T>(
  schema: z.ZodSchema<T>,
  input: unknown
): { success: true; data: T } | { success: false; errors: string[] } {
  try {
    const result = schema.parse(input)
    return { success: true, data: result }
  } catch (error) {
    if (error instanceof z.ZodError) {
      return {
        success: false,
        errors: error.errors.map(err => err.message)
      }
    }
    return {
      success: false,
      errors: ['Erro de validação desconhecido']
    }
  }
}
```

### Rate Limiting Implementation
```typescript
// lib/security/rate-limiting.ts
import { NextRequest } from 'next/server'
import { Redis } from '@upstash/redis'

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL!,
  token: process.env.UPSTASH_REDIS_REST_TOKEN!
})

interface RateLimitConfig {
  windowMs: number
  max: number
  keyGenerator?: (request: NextRequest) => string
}

export class RateLimiter {
  private config: RateLimitConfig

  constructor(config: RateLimitConfig) {
    this.config = config
  }

  async checkLimit(request: NextRequest): Promise<{
    success: boolean
    remaining: number
    resetTime: Date
  }> {
    const key = this.config.keyGenerator 
      ? this.config.keyGenerator(request)
      : this.getDefaultKey(request)

    const window = Math.floor(Date.now() / this.config.windowMs)
    const redisKey = `rate_limit:${key}:${window}`

    const current = await redis.incr(redisKey)
    
    if (current === 1) {
      // Set expiration for the first request in this window
      await redis.expire(redisKey, Math.ceil(this.config.windowMs / 1000))
    }

    const success = current <= this.config.max
    const remaining = Math.max(0, this.config.max - current)
    const resetTime = new Date((window + 1) * this.config.windowMs)

    return { success, remaining, resetTime }
  }

  private getDefaultKey(request: NextRequest): string {
    // Use IP address as default key
    const forwarded = request.headers.get('x-forwarded-for')
    const ip = forwarded ? forwarded.split(',')[0] : request.ip || 'unknown'
    return ip
  }
}

// Pre-configured rate limiters
export const apiLimiter = new RateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100
})

export const contactLimiter = new RateLimiter({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5,
  keyGenerator: (request) => {
    const forwarded = request.headers.get('x-forwarded-for')
    const ip = forwarded ? forwarded.split(',')[0] : request.ip || 'unknown'
    return `contact:${ip}`
  }
})

export const authLimiter = new RateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,
  keyGenerator: (request) => {
    const forwarded = request.headers.get('x-forwarded-for')
    const ip = forwarded ? forwarded.split(',')[0] : request.ip || 'unknown'
    return `auth:${ip}`
  }
})
```

### CSRF Protection
```typescript
// lib/security/csrf.ts
import { NextRequest } from 'next/server'
import { createHash, randomBytes } from 'crypto'

const CSRF_SECRET = process.env.CSRF_SECRET || 'your-csrf-secret-key'

export function generateCSRFToken(sessionId?: string): string {
  const timestamp = Date.now().toString()
  const random = randomBytes(16).toString('hex')
  const payload = `${timestamp}:${random}:${sessionId || 'anonymous'}`
  
  const hash = createHash('sha256')
    .update(`${payload}:${CSRF_SECRET}`)
    .digest('hex')
  
  return Buffer.from(`${payload}:${hash}`).toString('base64')
}

export function validateCSRFToken(token: string, sessionId?: string): boolean {
  try {
    const decoded = Buffer.from(token, 'base64').toString('utf8')
    const [timestamp, random, tokenSessionId, hash] = decoded.split(':')
    
    // Check if token is expired (24 hours)
    const tokenTime = parseInt(timestamp)
    const now = Date.now()
    if (now - tokenTime > 24 * 60 * 60 * 1000) {
      return false
    }
    
    // Verify session match
    if (sessionId && tokenSessionId !== sessionId) {
      return false
    }
    
    // Verify hash
    const payload = `${timestamp}:${random}:${tokenSessionId}`
    const expectedHash = createHash('sha256')
      .update(`${payload}:${CSRF_SECRET}`)
      .digest('hex')
    
    return hash === expectedHash
  } catch {
    return false
  }
}

export async function validateCSRF(request: NextRequest): Promise<{ valid: boolean }> {
  const token = request.headers.get('x-csrf-token') || 
                request.nextUrl.searchParams.get('csrf_token')
  
  if (!token) {
    return { valid: false }
  }
  
  const sessionId = request.cookies.get('session-id')?.value
  const valid = validateCSRFToken(token, sessionId)
  
  return { valid }
}
```

### Data Protection and Privacy
```typescript
// lib/security/data-protection.ts
import { createCipher, createDecipher, createHash } from 'crypto'

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY!
const ALGORITHM = 'aes-256-cbc'

export class DataProtection {
  static encrypt(text: string): string {
    const iv = Buffer.from(randomBytes(16))
    const cipher = createCipher(ALGORITHM, ENCRYPTION_KEY)
    let encrypted = cipher.update(text, 'utf8', 'hex')
    encrypted += cipher.final('hex')
    return `${iv.toString('hex')}:${encrypted}`
  }

  static decrypt(encryptedText: string): string {
    const [ivHex, encrypted] = encryptedText.split(':')
    const iv = Buffer.from(ivHex, 'hex')
    const decipher = createDecipher(ALGORITHM, ENCRYPTION_KEY)
    let decrypted = decipher.update(encrypted, 'hex', 'utf8')
    decrypted += decipher.final('utf8')
    return decrypted
  }

  static hash(text: string): string {
    return createHash('sha256').update(text).digest('hex')
  }

  // PII (Personally Identifiable Information) protection
  static maskEmail(email: string): string {
    const [local, domain] = email.split('@')
    if (local.length <= 2) return email
    
    const maskedLocal = local[0] + '*'.repeat(local.length - 2) + local[local.length - 1]
    return `${maskedLocal}@${domain}`
  }

  static maskPhone(phone: string): string {
    const cleaned = phone.replace(/\D/g, '')
    if (cleaned.length < 8) return phone
    
    const masked = cleaned.slice(0, 2) + '*'.repeat(cleaned.length - 6) + cleaned.slice(-4)
    return masked
  }

  // LGPD compliance helpers
  static anonymizePersonalData(data: any): any {
    const sensitiveFields = ['email', 'phone', 'cpf', 'name', 'address']
    const anonymized = { ...data }
    
    sensitiveFields.forEach(field => {
      if (anonymized[field]) {
        anonymized[field] = this.hash(anonymized[field])
      }
    })
    
    return anonymized
  }

  static redactPersonalData(data: any): any {
    const sensitiveFields = ['email', 'phone', 'cpf', 'address']
    const redacted = { ...data }
    
    sensitiveFields.forEach(field => {
      if (redacted[field]) {
        delete redacted[field]
      }
    })
    
    // Keep name but mask it
    if (redacted.name) {
      redacted.name = redacted.name.charAt(0) + '*'.repeat(redacted.name.length - 1)
    }
    
    return redacted
  }
}
```

### Secure API Implementation
```typescript
// pages/api/contact.ts
import { NextApiRequest, NextApiResponse } from 'next/server'
import { contactLimiter } from '@/lib/security/rate-limiting'
import { validateAndSanitizeInput, contactFormSchema } from '@/lib/security/validation'
import { DataProtection } from '@/lib/security/data-protection'
import { validateCSRFToken } from '@/lib/security/csrf'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    // Rate limiting
    const rateLimitResult = await contactLimiter.checkLimit(req as any)
    if (!rateLimitResult.success) {
      return res.status(429).json({ 
        error: 'Too many requests',
        retryAfter: rateLimitResult.resetTime
      })
    }

    // CSRF validation
    const csrfToken = req.body.csrfToken
    if (!validateCSRFToken(csrfToken)) {
      return res.status(403).json({ error: 'Invalid CSRF token' })
    }

    // Input validation and sanitization
    const validationResult = validateAndSanitizeInput(contactFormSchema, req.body)
    if (!validationResult.success) {
      return res.status(400).json({ 
        error: 'Validation failed',
        details: validationResult.errors
      })
    }

    const data = validationResult.data

    // Honeypot check (bot detection)
    if (data.website) {
      // Silent fail for bots
      return res.status(200).json({ success: true })
    }

    // Additional spam detection
    const spamScore = calculateSpamScore(data)
    if (spamScore > 0.8) {
      // Flag for manual review
      await flagForManualReview(data, spamScore)
    }

    // Encrypt sensitive data before storing
    const encryptedData = {
      ...data,
      email: DataProtection.encrypt(data.email),
      phone: DataProtection.encrypt(data.phone),
      message: DataProtection.encrypt(data.message)
    }

    // Store in database
    await saveContactSubmission(encryptedData)

    // Send notifications (with masked data in logs)
    await sendNotifications(data)

    // Audit log
    await logSecurityEvent('contact_form_submission', {
      ip: getClientIP(req),
      userAgent: req.headers['user-agent'],
      timestamp: new Date().toISOString(),
      masked_email: DataProtection.maskEmail(data.email)
    })

    res.status(200).json({ success: true })
  } catch (error) {
    console.error('Contact form error:', error)
    
    // Log security incident
    await logSecurityEvent('contact_form_error', {
      error: error instanceof Error ? error.message : 'Unknown error',
      ip: getClientIP(req),
      timestamp: new Date().toISOString()
    })

    res.status(500).json({ error: 'Internal server error' })
  }
}

function calculateSpamScore(data: any): number {
  let score = 0
  
  // Check for suspicious patterns
  if (data.message.includes('http://') || data.message.includes('https://')) {
    score += 0.3
  }
  
  if (data.message.length < 20) {
    score += 0.2
  }
  
  if (/[^\p{L}\s.,!?-]/u.test(data.message)) {
    score += 0.3
  }
  
  return score
}

function getClientIP(req: NextApiRequest): string {
  const forwarded = req.headers['x-forwarded-for'] as string
  return forwarded ? forwarded.split(',')[0] : req.socket.remoteAddress || 'unknown'
}
```

### Security Monitoring and Incident Response
```typescript
// lib/security/monitoring.ts
export class SecurityMonitor {
  static async logSecurityEvent(
    eventType: string,
    details: Record<string, any>,
    severity: 'low' | 'medium' | 'high' | 'critical' = 'medium'
  ) {
    const event = {
      timestamp: new Date().toISOString(),
      type: eventType,
      severity,
      details,
      environment: process.env.NODE_ENV
    }

    // Log to security monitoring service
    try {
      await fetch(process.env.SECURITY_WEBHOOK_URL!, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(event)
      })
    } catch (error) {
      console.error('Failed to send security event:', error)
    }

    // Store in database for analysis
    await this.storeSecurityEvent(event)

    // Send alerts for high severity events
    if (severity === 'high' || severity === 'critical') {
      await this.sendSecurityAlert(event)
    }
  }

  private static async storeSecurityEvent(event: any) {
    // Implementation depends on your database
    // This could be a dedicated security events table
  }

  private static async sendSecurityAlert(event: any) {
    // Send to security team via email/Slack/etc.
    // Implementation depends on your alerting system
  }

  static async detectAnomalies() {
    // Analyze security events for patterns
    // This could run as a scheduled job
    const recentEvents = await this.getRecentSecurityEvents()
    
    // Check for suspicious patterns
    const suspiciousIPs = this.findSuspiciousIPs(recentEvents)
    const rateLimitViolations = this.findRateLimitViolations(recentEvents)
    
    if (suspiciousIPs.length > 0 || rateLimitViolations.length > 0) {
      await this.logSecurityEvent('anomaly_detected', {
        suspicious_ips: suspiciousIPs,
        rate_limit_violations: rateLimitViolations
      }, 'high')
    }
  }

  private static findSuspiciousIPs(events: any[]): string[] {
    // Find IPs with multiple failed requests
    const ipCounts = events.reduce((acc, event) => {
      if (event.type.includes('error') || event.type.includes('violation')) {
        acc[event.details.ip] = (acc[event.details.ip] || 0) + 1
      }
      return acc
    }, {})

    return Object.entries(ipCounts)
      .filter(([ip, count]) => count > 10)
      .map(([ip]) => ip)
  }

  private static findRateLimitViolations(events: any[]): any[] {
    return events.filter(event => event.type === 'rate_limit_exceeded')
  }

  private static async getRecentSecurityEvents() {
    // Get events from last 24 hours
    // Implementation depends on your database
    return []
  }
}
```

### LGPD/GDPR Compliance Implementation
```typescript
// lib/security/privacy-compliance.ts
export class PrivacyCompliance {
  // Data retention policies
  static readonly RETENTION_POLICIES = {
    contact_forms: 365 * 2, // 2 years in days
    analytics: 365 * 3, // 3 years
    logs: 365 * 1, // 1 year
    marketing: 365 * 2 // 2 years
  }

  // Right to be forgotten implementation
  static async deleteUserData(identifier: string, type: 'email' | 'phone' | 'id') {
    const deletionLog = {
      timestamp: new Date().toISOString(),
      identifier: DataProtection.hash(identifier),
      type,
      requestedBy: 'user_request'
    }

    try {
      // Delete from all systems
      await Promise.all([
        this.deleteFromDatabase(identifier, type),
        this.deleteFromAnalytics(identifier, type),
        this.deleteFromCRM(identifier, type),
        this.deleteFromBackups(identifier, type)
      ])

      // Log successful deletion
      await SecurityMonitor.logSecurityEvent('data_deletion_completed', deletionLog)
      
      return { success: true }
    } catch (error) {
      await SecurityMonitor.logSecurityEvent('data_deletion_failed', {
        ...deletionLog,
        error: error instanceof Error ? error.message : 'Unknown error'
      }, 'high')
      
      throw error
    }
  }

  // Data portability (right to data access)
  static async exportUserData(identifier: string, type: 'email' | 'phone' | 'id') {
    const exportLog = {
      timestamp: new Date().toISOString(),
      identifier: DataProtection.hash(identifier),
      type,
      requestedBy: 'user_request'
    }

    try {
      const userData = await this.collectUserData(identifier, type)
      
      // Decrypt sensitive data for export
      const decryptedData = this.decryptUserData(userData)
      
      // Log export request
      await SecurityMonitor.logSecurityEvent('data_export_completed', exportLog)
      
      return {
        success: true,
        data: decryptedData,
        exportDate: new Date().toISOString()
      }
    } catch (error) {
      await SecurityMonitor.logSecurityEvent('data_export_failed', {
        ...exportLog,
        error: error instanceof Error ? error.message : 'Unknown error'
      }, 'medium')
      
      throw error
    }
  }

  // Automated data retention cleanup
  static async cleanupExpiredData() {
    const cleanupResults = []

    for (const [dataType, retentionDays] of Object.entries(this.RETENTION_POLICIES)) {
      try {
        const cutoffDate = new Date()
        cutoffDate.setDate(cutoffDate.getDate() - retentionDays)
        
        const deletedCount = await this.deleteExpiredData(dataType, cutoffDate)
        
        cleanupResults.push({
          dataType,
          deletedCount,
          cutoffDate: cutoffDate.toISOString()
        })
      } catch (error) {
        await SecurityMonitor.logSecurityEvent('data_cleanup_failed', {
          dataType,
          error: error instanceof Error ? error.message : 'Unknown error'
        }, 'medium')
      }
    }

    await SecurityMonitor.logSecurityEvent('data_cleanup_completed', {
      results: cleanupResults
    })

    return cleanupResults
  }

  private static async deleteFromDatabase(identifier: string, type: string) {
    // Implementation depends on your database structure
  }

  private static async deleteFromAnalytics(identifier: string, type: string) {
    // Implementation for analytics data deletion
  }

  private static async deleteFromCRM(identifier: string, type: string) {
    // Implementation for CRM data deletion
  }

  private static async deleteFromBackups(identifier: string, type: string) {
    // Mark for deletion in next backup cycle
  }

  private static async collectUserData(identifier: string, type: string) {
    // Collect data from all systems
    return {}
  }

  private static decryptUserData(userData: any) {
    // Decrypt sensitive fields for export
    return userData
  }

  private static async deleteExpiredData(dataType: string, cutoffDate: Date) {
    // Delete data older than cutoff date
    return 0
  }
}
```

## Security Checklist and Compliance

### Security Audit Checklist
```typescript
export const securityChecklist = {
  infrastructure: [
    { item: 'HTTPS enforced with HSTS', status: 'required' },
    { item: 'Security headers implemented', status: 'required' },
    { item: 'Content Security Policy configured', status: 'required' },
    { item: 'Rate limiting on all endpoints', status: 'required' },
    { item: 'DDoS protection enabled', status: 'required' },
    { item: 'Regular security updates', status: 'required' }
  ],
  application: [
    { item: 'Input validation and sanitization', status: 'required' },
    { item: 'CSRF protection implemented', status: 'required' },
    { item: 'SQL injection prevention', status: 'required' },
    { item: 'XSS protection measures', status: 'required' },
    { item: 'Secure session management', status: 'required' },
    { item: 'Error handling without info leakage', status: 'required' }
  ],
  data: [
    { item: 'Encryption at rest and in transit', status: 'required' },
    { item: 'PII data protection', status: 'required' },
    { item: 'Data retention policies', status: 'required' },
    { item: 'Secure backup procedures', status: 'required' },
    { item: 'Access controls and audit logs', status: 'required' },
    { item: 'LGPD/GDPR compliance measures', status: 'required' }
  ],
  monitoring: [
    { item: 'Security event logging', status: 'required' },
    { item: 'Real-time threat detection', status: 'required' },
    { item: 'Incident response procedures', status: 'required' },
    { item: 'Regular security assessments', status: 'recommended' },
    { item: 'Penetration testing', status: 'recommended' },
    { item: 'Vulnerability scanning', status: 'recommended' }
  ]
}
```

## Benefits of This Security Strategy

1. **Comprehensive Protection**: Multi-layered security approach
2. **Compliance**: LGPD/GDPR compliant data handling
3. **Threat Prevention**: Proactive security measures and monitoring
4. **Data Privacy**: Strong encryption and access controls
5. **Incident Response**: Automated detection and alerting
6. **User Trust**: Transparent privacy practices
7. **Legal Protection**: Compliance with data protection regulations
8. **Business Continuity**: Security measures that don't hinder performance