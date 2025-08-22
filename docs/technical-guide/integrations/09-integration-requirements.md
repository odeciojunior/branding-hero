# 9. Integration Requirements

## CRM Integration Strategy

### HubSpot CRM Integration
```typescript
// lib/integrations/hubspot.ts
import { Client } from '@hubspot/api-client'

export class HubSpotIntegration {
  private client: Client

  constructor() {
    this.client = new Client({ 
      accessToken: process.env.HUBSPOT_ACCESS_TOKEN 
    })
  }

  async createContact(contactData: {
    email: string
    firstName?: string
    lastName?: string
    phone?: string
    company?: string
    website?: string
    leadSource?: string
    serviceInterest?: string
  }) {
    try {
      const properties = {
        email: contactData.email,
        firstname: contactData.firstName || '',
        lastname: contactData.lastName || '',
        phone: contactData.phone || '',
        company: contactData.company || '',
        website: contactData.website || '',
        // Custom properties
        lead_source: contactData.leadSource || 'website',
        service_interest: contactData.serviceInterest || '',
        lead_status: 'new',
        lifecycle_stage: 'lead'
      }

      const response = await this.client.crm.contacts.basicApi.create({
        properties,
        associations: []
      })

      // Track in analytics
      await this.trackCRMEvent('contact_created', {
        hubspotId: response.id,
        email: contactData.email,
        source: contactData.leadSource
      })

      return {
        success: true,
        hubspotId: response.id,
        message: 'Contact created successfully'
      }
    } catch (error) {
      console.error('HubSpot contact creation failed:', error)
      
      // Log error for monitoring
      await this.logIntegrationError('hubspot_contact_creation', error)
      
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      }
    }
  }

  async createDeal(dealData: {
    contactId: string
    dealName: string
    amount?: number
    dealStage?: string
    serviceType?: string
    pipeline?: string
  }) {
    try {
      const properties = {
        dealname: dealData.dealName,
        amount: dealData.amount?.toString() || '0',
        dealstage: dealData.dealStage || 'appointmentscheduled',
        pipeline: dealData.pipeline || 'default',
        // Custom properties
        service_type: dealData.serviceType || '',
        lead_source: 'website'
      }

      const associations = [{
        to: { id: dealData.contactId },
        types: [{
          associationCategory: 'HUBSPOT_DEFINED',
          associationTypeId: 3 // Contact to Deal association
        }]
      }]

      const response = await this.client.crm.deals.basicApi.create({
        properties,
        associations
      })

      return {
        success: true,
        dealId: response.id,
        message: 'Deal created successfully'
      }
    } catch (error) {
      console.error('HubSpot deal creation failed:', error)
      await this.logIntegrationError('hubspot_deal_creation', error)
      
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      }
    }
  }

  async updateContactProperty(contactId: string, properties: Record<string, string>) {
    try {
      await this.client.crm.contacts.basicApi.update(contactId, {
        properties
      })

      return { success: true }
    } catch (error) {
      console.error('HubSpot contact update failed:', error)
      return { success: false, error }
    }
  }

  async searchContacts(email: string) {
    try {
      const response = await this.client.crm.contacts.searchApi.doSearch({
        filterGroups: [{
          filters: [{
            propertyName: 'email',
            operator: 'EQ',
            value: email
          }]
        }],
        properties: ['email', 'firstname', 'lastname', 'phone', 'company'],
        limit: 1
      })

      return {
        success: true,
        contacts: response.results
      }
    } catch (error) {
      console.error('HubSpot contact search failed:', error)
      return { success: false, error }
    }
  }

  private async trackCRMEvent(event: string, data: any) {
    // Integration with analytics system
    try {
      await fetch('/api/analytics/track', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          event: `crm_${event}`,
          properties: data
        })
      })
    } catch (error) {
      console.error('Failed to track CRM event:', error)
    }
  }

  private async logIntegrationError(operation: string, error: any) {
    // Log integration errors for monitoring
    try {
      await fetch('/api/monitoring/integration-error', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          service: 'hubspot',
          operation,
          error: error instanceof Error ? error.message : String(error),
          timestamp: new Date().toISOString()
        })
      })
    } catch (logError) {
      console.error('Failed to log integration error:', logError)
    }
  }
}

// Singleton instance
export const hubspot = new HubSpotIntegration()
```

### Alternative CRM Integration (Pipedrive)
```typescript
// lib/integrations/pipedrive.ts
export class PipedriveIntegration {
  private apiUrl = 'https://api.pipedrive.com/v1'
  private apiToken = process.env.PIPEDRIVE_API_TOKEN!

  async createPerson(personData: {
    name: string
    email: string[]
    phone: string[]
    orgId?: number
  }) {
    try {
      const response = await fetch(`${this.apiUrl}/persons?api_token=${this.apiToken}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(personData)
      })

      const result = await response.json()
      
      if (result.success) {
        return {
          success: true,
          personId: result.data.id,
          message: 'Person created successfully'
        }
      } else {
        throw new Error(result.error)
      }
    } catch (error) {
      console.error('Pipedrive person creation failed:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      }
    }
  }

  async createDeal(dealData: {
    title: string
    value: number
    currency: string
    personId: number
    pipelineId?: number
    stageId?: number
  }) {
    try {
      const response = await fetch(`${this.apiUrl}/deals?api_token=${this.apiToken}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(dealData)
      })

      const result = await response.json()
      
      if (result.success) {
        return {
          success: true,
          dealId: result.data.id,
          message: 'Deal created successfully'
        }
      } else {
        throw new Error(result.error)
      }
    } catch (error) {
      console.error('Pipedrive deal creation failed:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      }
    }
  }
}
```

## WhatsApp Business API Integration

### WhatsApp Cloud API Implementation
```typescript
// lib/integrations/whatsapp.ts
export class WhatsAppIntegration {
  private apiUrl = 'https://graph.facebook.com/v18.0'
  private phoneNumberId = process.env.WHATSAPP_PHONE_NUMBER_ID!
  private accessToken = process.env.WHATSAPP_ACCESS_TOKEN!

  async sendMessage(to: string, message: {
    type: 'text' | 'template' | 'image' | 'document'
    content: any
  }) {
    try {
      const payload = this.buildMessagePayload(to, message)
      
      const response = await fetch(
        `${this.apiUrl}/${this.phoneNumberId}/messages`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${this.accessToken}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(payload)
        }
      )

      const result = await response.json()
      
      if (response.ok) {
        // Track message sent
        await this.trackWhatsAppEvent('message_sent', {
          to,
          type: message.type,
          messageId: result.messages[0].id
        })

        return {
          success: true,
          messageId: result.messages[0].id,
          status: result.messages[0].message_status
        }
      } else {
        throw new Error(result.error?.message || 'WhatsApp API error')
      }
    } catch (error) {
      console.error('WhatsApp message sending failed:', error)
      await this.logIntegrationError('whatsapp_send_message', error)
      
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      }
    }
  }

  async sendWelcomeMessage(to: string, contactName: string) {
    const message = {
      type: 'template' as const,
      content: {
        name: 'hero_welcome',
        language: { code: 'pt_BR' },
        components: [
          {
            type: 'header',
            parameters: [
              {
                type: 'text',
                text: contactName
              }
            ]
          },
          {
            type: 'body',
            parameters: [
              {
                type: 'text',
                text: contactName
              }
            ]
          }
        ]
      }
    }

    return this.sendMessage(to, message)
  }

  async sendConsultationReminder(to: string, appointmentDetails: {
    date: string
    time: string
    consultantName: string
  }) {
    const message = {
      type: 'template' as const,
      content: {
        name: 'consultation_reminder',
        language: { code: 'pt_BR' },
        components: [
          {
            type: 'body',
            parameters: [
              {
                type: 'text',
                text: appointmentDetails.date
              },
              {
                type: 'text',
                text: appointmentDetails.time
              },
              {
                type: 'text',
                text: appointmentDetails.consultantName
              }
            ]
          }
        ]
      }
    }

    return this.sendMessage(to, message)
  }

  async handleWebhook(webhookData: any) {
    try {
      // Verify webhook signature
      if (!this.verifyWebhookSignature(webhookData)) {
        throw new Error('Invalid webhook signature')
      }

      const { entry } = webhookData
      
      for (const item of entry) {
        const { changes } = item
        
        for (const change of changes) {
          if (change.field === 'messages') {
            await this.processIncomingMessage(change.value)
          }
        }
      }

      return { success: true }
    } catch (error) {
      console.error('WhatsApp webhook processing failed:', error)
      return { success: false, error }
    }
  }

  private buildMessagePayload(to: string, message: any) {
    const basePayload = {
      messaging_product: 'whatsapp',
      to,
      type: message.type
    }

    switch (message.type) {
      case 'text':
        return {
          ...basePayload,
          text: { body: message.content }
        }
      
      case 'template':
        return {
          ...basePayload,
          template: message.content
        }
      
      case 'image':
        return {
          ...basePayload,
          image: message.content
        }
      
      default:
        throw new Error(`Unsupported message type: ${message.type}`)
    }
  }

  private verifyWebhookSignature(data: any): boolean {
    // Implement webhook signature verification
    return true // Simplified for example
  }

  private async processIncomingMessage(messageData: any) {
    // Process incoming WhatsApp messages
    // This could trigger automated responses or notifications
    const { messages, contacts } = messageData
    
    for (const message of messages || []) {
      await this.trackWhatsAppEvent('message_received', {
        from: message.from,
        type: message.type,
        messageId: message.id
      })
      
      // Auto-respond or forward to team
      await this.handleIncomingMessage(message, contacts[0])
    }
  }

  private async handleIncomingMessage(message: any, contact: any) {
    // Implement auto-response logic or forward to team
    if (message.type === 'text') {
      // Simple auto-response
      await this.sendMessage(message.from, {
        type: 'text',
        content: 'Obrigado por entrar em contato! Nossa equipe responderá em breve.'
      })
    }
  }

  private async trackWhatsAppEvent(event: string, data: any) {
    try {
      await fetch('/api/analytics/track', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          event: `whatsapp_${event}`,
          properties: data
        })
      })
    } catch (error) {
      console.error('Failed to track WhatsApp event:', error)
    }
  }

  private async logIntegrationError(operation: string, error: any) {
    try {
      await fetch('/api/monitoring/integration-error', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          service: 'whatsapp',
          operation,
          error: error instanceof Error ? error.message : String(error),
          timestamp: new Date().toISOString()
        })
      })
    } catch (logError) {
      console.error('Failed to log integration error:', logError)
    }
  }
}

export const whatsapp = new WhatsAppIntegration()
```

## Email Integration & Automation

### Email Service Provider Integration (SendGrid)
```typescript
// lib/integrations/email.ts
import sgMail from '@sendgrid/mail'

sgMail.setApiKey(process.env.SENDGRID_API_KEY!)

export class EmailIntegration {
  private fromEmail = process.env.FROM_EMAIL || 'contato@hero.com.br'
  private fromName = 'HERO Consultoria'

  async sendWelcomeEmail(to: string, contactName: string) {
    try {
      const msg = {
        to,
        from: {
          email: this.fromEmail,
          name: this.fromName
        },
        templateId: process.env.SENDGRID_WELCOME_TEMPLATE_ID!,
        dynamicTemplateData: {
          contact_name: contactName,
          company_name: 'HERO',
          consultation_link: `${process.env.NEXT_PUBLIC_APP_URL}/agendar`,
          unsubscribe_link: `${process.env.NEXT_PUBLIC_APP_URL}/unsubscribe`
        }
      }

      await sgMail.send(msg)
      
      await this.trackEmailEvent('welcome_sent', {
        to,
        templateId: msg.templateId
      })

      return { success: true }
    } catch (error) {
      console.error('Welcome email sending failed:', error)
      await this.logEmailError('send_welcome', error, to)
      return { success: false, error }
    }
  }

  async sendConsultationConfirmation(to: string, appointmentDetails: {
    contactName: string
    date: string
    time: string
    consultantName: string
    meetingLink?: string
  }) {
    try {
      const msg = {
        to,
        from: {
          email: this.fromEmail,
          name: this.fromName
        },
        templateId: process.env.SENDGRID_CONSULTATION_TEMPLATE_ID!,
        dynamicTemplateData: {
          ...appointmentDetails,
          company_name: 'HERO',
          reschedule_link: `${process.env.NEXT_PUBLIC_APP_URL}/reagendar`,
          calendar_link: this.generateCalendarLink(appointmentDetails)
        }
      }

      await sgMail.send(msg)
      
      await this.trackEmailEvent('consultation_confirmation_sent', {
        to,
        appointmentDate: appointmentDetails.date
      })

      return { success: true }
    } catch (error) {
      console.error('Consultation confirmation email failed:', error)
      await this.logEmailError('send_consultation_confirmation', error, to)
      return { success: false, error }
    }
  }

  async sendFollowUpEmail(to: string, followUpData: {
    contactName: string
    serviceInterest: string
    consultantName: string
    proposalLink?: string
  }) {
    try {
      const msg = {
        to,
        from: {
          email: this.fromEmail,
          name: this.fromName
        },
        templateId: process.env.SENDGRID_FOLLOWUP_TEMPLATE_ID!,
        dynamicTemplateData: {
          ...followUpData,
          company_name: 'HERO',
          contact_link: `${process.env.NEXT_PUBLIC_APP_URL}/contato`
        }
      }

      await sgMail.send(msg)
      
      await this.trackEmailEvent('followup_sent', {
        to,
        serviceInterest: followUpData.serviceInterest
      })

      return { success: true }
    } catch (error) {
      console.error('Follow-up email sending failed:', error)
      await this.logEmailError('send_followup', error, to)
      return { success: false, error }
    }
  }

  async addToNewsletterList(email: string, contactData: {
    firstName?: string
    lastName?: string
    company?: string
    interests?: string[]
  }) {
    try {
      const contact = {
        email,
        first_name: contactData.firstName || '',
        last_name: contactData.lastName || '',
        custom_fields: {
          company: contactData.company || '',
          interests: contactData.interests?.join(',') || '',
          source: 'website',
          signup_date: new Date().toISOString()
        }
      }

      // Add to SendGrid contact list
      const response = await fetch('https://api.sendgrid.com/v3/marketing/contacts', {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${process.env.SENDGRID_API_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          list_ids: [process.env.SENDGRID_NEWSLETTER_LIST_ID],
          contacts: [contact]
        })
      })

      if (response.ok) {
        await this.trackEmailEvent('newsletter_signup', {
          email,
          source: 'website'
        })
        return { success: true }
      } else {
        throw new Error(`SendGrid API error: ${response.status}`)
      }
    } catch (error) {
      console.error('Newsletter signup failed:', error)
      await this.logEmailError('newsletter_signup', error, email)
      return { success: false, error }
    }
  }

  private generateCalendarLink(appointmentDetails: any): string {
    const startDate = new Date(`${appointmentDetails.date} ${appointmentDetails.time}`)
    const endDate = new Date(startDate.getTime() + 60 * 60 * 1000) // 1 hour later
    
    const formatDate = (date: Date) => date.toISOString().replace(/[-:]/g, '').split('.')[0] + 'Z'
    
    const params = new URLSearchParams({
      action: 'TEMPLATE',
      text: `Consultoria HERO - ${appointmentDetails.consultantName}`,
      dates: `${formatDate(startDate)}/${formatDate(endDate)}`,
      details: `Consultoria estratégica com ${appointmentDetails.consultantName} da HERO.`,
      location: appointmentDetails.meetingLink || 'Online'
    })

    return `https://calendar.google.com/calendar/render?${params.toString()}`
  }

  private async trackEmailEvent(event: string, data: any) {
    try {
      await fetch('/api/analytics/track', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          event: `email_${event}`,
          properties: data
        })
      })
    } catch (error) {
      console.error('Failed to track email event:', error)
    }
  }

  private async logEmailError(operation: string, error: any, recipient?: string) {
    try {
      await fetch('/api/monitoring/integration-error', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          service: 'email',
          operation,
          error: error instanceof Error ? error.message : String(error),
          recipient,
          timestamp: new Date().toISOString()
        })
      })
    } catch (logError) {
      console.error('Failed to log email error:', logError)
    }
  }
}

export const email = new EmailIntegration()
```

## Form Handling & Processing

### Advanced Form Handler
```typescript
// pages/api/forms/contact.ts
import { NextApiRequest, NextApiResponse } from 'next'
import { validateAndSanitizeInput, contactFormSchema } from '@/lib/security/validation'
import { contactLimiter } from '@/lib/security/rate-limiting'
import { hubspot } from '@/lib/integrations/hubspot'
import { email } from '@/lib/integrations/email'
import { whatsapp } from '@/lib/integrations/whatsapp'
import { ConversionTracker } from '@/lib/analytics/conversion-tracking'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    // Rate limiting
    const rateLimitResult = await contactLimiter.checkLimit(req as any)
    if (!rateLimitResult.success) {
      return res.status(429).json({ 
        error: 'Too many requests. Please try again later.',
        retryAfter: rateLimitResult.resetTime
      })
    }

    // Validate and sanitize input
    const validationResult = validateAndSanitizeInput(contactFormSchema, req.body)
    if (!validationResult.success) {
      return res.status(400).json({ 
        error: 'Validation failed',
        details: validationResult.errors
      })
    }

    const data = validationResult.data

    // Honeypot check
    if (data.website) {
      return res.status(200).json({ success: true }) // Silent success for bots
    }

    // Process the contact form submission
    const processingResults = await processContactSubmission(data, req)

    // Track conversion
    ConversionTracker.trackConversion(ConversionTracker.GOALS.CONTACT_FORM, {
      value: 1000, // Estimated lead value
      service: data.service,
      source: req.headers.referer,
      medium: 'website'
    })

    return res.status(200).json({
      success: true,
      message: 'Mensagem enviada com sucesso! Entraremos em contato em breve.',
      processingResults
    })

  } catch (error) {
    console.error('Contact form processing error:', error)
    
    return res.status(500).json({
      error: 'Erro interno do servidor. Tente novamente mais tarde.'
    })
  }
}

async function processContactSubmission(data: any, req: NextApiRequest) {
  const results = {
    crm: { success: false },
    email: { success: false },
    whatsapp: { success: false },
    database: { success: false }
  }

  try {
    // 1. Create or update contact in CRM
    const crmResult = await hubspot.createContact({
      email: data.email,
      firstName: data.name.split(' ')[0],
      lastName: data.name.split(' ').slice(1).join(' '),
      phone: data.phone,
      company: data.company,
      leadSource: 'website_form',
      serviceInterest: data.service
    })
    results.crm = crmResult

    // 2. Send welcome email
    if (crmResult.success) {
      const emailResult = await email.sendWelcomeEmail(
        data.email,
        data.name.split(' ')[0]
      )
      results.email = emailResult
    }

    // 3. Send WhatsApp notification (if phone provided)
    if (data.phone && crmResult.success) {
      const whatsappResult = await whatsapp.sendWelcomeMessage(
        data.phone,
        data.name.split(' ')[0]
      )
      results.whatsapp = whatsappResult
    }

    // 4. Store in database
    const dbResult = await storeContactSubmission(data, req)
    results.database = dbResult

    // 5. Notify team
    await notifyTeam(data, results)

  } catch (error) {
    console.error('Error processing contact submission:', error)
  }

  return results
}

async function storeContactSubmission(data: any, req: NextApiRequest) {
  try {
    // Store in your database
    // Implementation depends on your database setup
    return { success: true }
  } catch (error) {
    console.error('Database storage failed:', error)
    return { success: false, error }
  }
}

async function notifyTeam(data: any, processingResults: any) {
  try {
    // Send notification to team via Slack, email, etc.
    const notification = {
      type: 'new_contact',
      data: {
        name: data.name,
        email: data.email,
        phone: data.phone,
        company: data.company,
        service: data.service,
        message: data.message
      },
      processingResults,
      timestamp: new Date().toISOString()
    }

    // Send to team notification endpoint
    await fetch(process.env.TEAM_NOTIFICATION_WEBHOOK!, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(notification)
    })
  } catch (error) {
    console.error('Team notification failed:', error)
  }
}
```

### Newsletter Subscription Handler
```typescript
// pages/api/forms/newsletter.ts
import { NextApiRequest, NextApiResponse } from 'next'
import { z } from 'zod'
import { email } from '@/lib/integrations/email'
import { hubspot } from '@/lib/integrations/hubspot'

const newsletterSchema = z.object({
  email: z.string().email('Email inválido'),
  firstName: z.string().min(1).optional(),
  interests: z.array(z.string()).optional(),
  source: z.string().optional()
})

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const validation = newsletterSchema.safeParse(req.body)
    if (!validation.success) {
      return res.status(400).json({ 
        error: 'Invalid data',
        details: validation.error.errors
      })
    }

    const { email: emailAddress, firstName, interests, source } = validation.data

    // Add to newsletter list
    const emailResult = await email.addToNewsletterList(emailAddress, {
      firstName,
      interests
    })

    // Add to CRM as newsletter subscriber
    if (emailResult.success) {
      await hubspot.createContact({
        email: emailAddress,
        firstName: firstName || '',
        leadSource: source || 'newsletter',
        serviceInterest: interests?.join(',') || ''
      })
    }

    // Track conversion
    ConversionTracker.trackConversion(ConversionTracker.GOALS.NEWSLETTER_SIGNUP, {
      value: 50, // Newsletter signup value
      source: source || 'website'
    })

    return res.status(200).json({
      success: true,
      message: 'Inscrição realizada com sucesso!'
    })

  } catch (error) {
    console.error('Newsletter subscription error:', error)
    return res.status(500).json({
      error: 'Erro interno. Tente novamente mais tarde.'
    })
  }
}
```

## Webhook Management

### Centralized Webhook Handler
```typescript
// pages/api/webhooks/index.ts
import { NextApiRequest, NextApiResponse } from 'next'
import { whatsapp } from '@/lib/integrations/whatsapp'
import { handleHubSpotWebhook } from '@/lib/integrations/hubspot-webhooks'
import { handleStripeWebhook } from '@/lib/integrations/stripe-webhooks'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const { source } = req.query

  try {
    switch (source) {
      case 'whatsapp':
        await whatsapp.handleWebhook(req.body)
        break
      
      case 'hubspot':
        await handleHubSpotWebhook(req.body)
        break
      
      case 'stripe':
        await handleStripeWebhook(req.body, req.headers)
        break
      
      default:
        return res.status(400).json({ error: 'Unknown webhook source' })
    }

    return res.status(200).json({ success: true })
  } catch (error) {
    console.error(`Webhook processing error (${source}):`, error)
    return res.status(500).json({ error: 'Webhook processing failed' })
  }
}

export const config = {
  api: {
    bodyParser: {
      sizeLimit: '1mb',
    },
  },
}
```

## Integration Testing & Monitoring

### Integration Health Checker
```typescript
// lib/integrations/health-checker.ts
export class IntegrationHealthChecker {
  async checkAllIntegrations() {
    const results = await Promise.allSettled([
      this.checkHubSpot(),
      this.checkWhatsApp(),
      this.checkEmail(),
      this.checkDatabase()
    ])

    return {
      hubspot: this.getResult(results[0]),
      whatsapp: this.getResult(results[1]),
      email: this.getResult(results[2]),
      database: this.getResult(results[3])
    }
  }

  private async checkHubSpot() {
    try {
      const result = await hubspot.searchContacts('test@example.com')
      return { status: 'healthy', responseTime: Date.now() }
    } catch (error) {
      return { 
        status: 'unhealthy', 
        error: error instanceof Error ? error.message : 'Unknown error' 
      }
    }
  }

  private async checkWhatsApp() {
    try {
      // Check WhatsApp API status
      const response = await fetch(`https://graph.facebook.com/v18.0/${process.env.WHATSAPP_PHONE_NUMBER_ID}`, {
        headers: {
          'Authorization': `Bearer ${process.env.WHATSAPP_ACCESS_TOKEN}`
        }
      })
      
      if (response.ok) {
        return { status: 'healthy', responseTime: Date.now() }
      } else {
        throw new Error(`HTTP ${response.status}`)
      }
    } catch (error) {
      return { 
        status: 'unhealthy', 
        error: error instanceof Error ? error.message : 'Unknown error' 
      }
    }
  }

  private async checkEmail() {
    try {
      // Check SendGrid API status
      const response = await fetch('https://api.sendgrid.com/v3/user/profile', {
        headers: {
          'Authorization': `Bearer ${process.env.SENDGRID_API_KEY}`
        }
      })
      
      if (response.ok) {
        return { status: 'healthy', responseTime: Date.now() }
      } else {
        throw new Error(`HTTP ${response.status}`)
      }
    } catch (error) {
      return { 
        status: 'unhealthy', 
        error: error instanceof Error ? error.message : 'Unknown error' 
      }
    }
  }

  private async checkDatabase() {
    try {
      // Database health check
      // Implementation depends on your database
      return { status: 'healthy', responseTime: Date.now() }
    } catch (error) {
      return { 
        status: 'unhealthy', 
        error: error instanceof Error ? error.message : 'Unknown error' 
      }
    }
  }

  private getResult(result: PromiseSettledResult<any>) {
    if (result.status === 'fulfilled') {
      return result.value
    } else {
      return {
        status: 'unhealthy',
        error: result.reason instanceof Error ? result.reason.message : 'Unknown error'
      }
    }
  }
}

export const integrationHealthChecker = new IntegrationHealthChecker()
```

## Benefits of This Integration Strategy

1. **Unified Customer Journey**: Seamless experience across all touchpoints
2. **Automated Workflows**: Reduce manual tasks and improve efficiency  
3. **Data Synchronization**: Consistent customer data across all systems
4. **Scalable Architecture**: Easy to add new integrations and features
5. **Monitoring & Alerting**: Proactive detection of integration issues
6. **Conversion Optimization**: Track and optimize the entire funnel
7. **Customer Communication**: Multi-channel communication strategy
8. **Business Intelligence**: Comprehensive analytics across all systems