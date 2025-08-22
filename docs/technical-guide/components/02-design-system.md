# 2. Component Library & Design System Specifications

## Design System Architecture

### Foundation Layer
```typescript
// Design tokens structure
export const designTokens = {
  colors: {
    primary: {
      50: '#eff6ff',
      100: '#dbeafe',
      500: '#3b82f6',
      600: '#2563eb',
      900: '#1e3a8a'
    },
    hero: {
      blue: '#0066CC',
      navy: '#003366',
      gray: '#6B7280',
      success: '#10B981',
      warning: '#F59E0B',
      error: '#EF4444'
    }
  },
  typography: {
    fontFamily: {
      primary: ['Inter', 'system-ui', 'sans-serif'],
      secondary: ['Playfair Display', 'serif'],
      mono: ['JetBrains Mono', 'monospace']
    },
    fontSize: {
      xs: '0.75rem',
      sm: '0.875rem',
      base: '1rem',
      lg: '1.125rem',
      xl: '1.25rem',
      '2xl': '1.5rem',
      '3xl': '1.875rem',
      '4xl': '2.25rem',
      '5xl': '3rem'
    }
  },
  spacing: {
    px: '1px',
    0: '0px',
    1: '0.25rem',
    2: '0.5rem',
    4: '1rem',
    8: '2rem',
    16: '4rem',
    32: '8rem'
  },
  borderRadius: {
    none: '0px',
    sm: '0.25rem',
    md: '0.375rem',
    lg: '0.5rem',
    xl: '0.75rem',
    full: '9999px'
  }
}
```

## Component Architecture

### Base Components

#### Button Component
```typescript
// components/ui/Button.tsx
import { forwardRef, ButtonHTMLAttributes } from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none ring-offset-background',
  {
    variants: {
      variant: {
        default: 'bg-hero-blue text-white hover:bg-hero-navy',
        destructive: 'bg-red-500 text-white hover:bg-red-600',
        outline: 'border border-hero-blue text-hero-blue hover:bg-hero-blue hover:text-white',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
        ghost: 'hover:bg-gray-100 hover:text-gray-900',
        link: 'underline-offset-4 hover:underline text-hero-blue'
      },
      size: {
        default: 'h-10 py-2 px-4',
        sm: 'h-9 px-3 rounded-md',
        lg: 'h-11 px-8 rounded-md',
        xl: 'h-12 px-10 text-base'
      }
    },
    defaultVariants: {
      variant: 'default',
      size: 'default'
    }
  }
)

export interface ButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = 'Button'

export { Button, buttonVariants }
```

#### Card Component
```typescript
// components/ui/Card.tsx
import { forwardRef, HTMLAttributes } from 'react'
import { cn } from '@/lib/utils'

const Card = forwardRef<HTMLDivElement, HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        'rounded-lg border bg-white shadow-sm transition-shadow hover:shadow-md',
        className
      )}
      {...props}
    />
  )
)
Card.displayName = 'Card'

const CardHeader = forwardRef<HTMLDivElement, HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn('flex flex-col space-y-1.5 p-6', className)}
      {...props}
    />
  )
)
CardHeader.displayName = 'CardHeader'

const CardTitle = forwardRef<HTMLParagraphElement, HTMLAttributes<HTMLHeadingElement>>(
  ({ className, ...props }, ref) => (
    <h3
      ref={ref}
      className={cn('text-2xl font-semibold leading-none tracking-tight', className)}
      {...props}
    />
  )
)
CardTitle.displayName = 'CardTitle'

const CardContent = forwardRef<HTMLDivElement, HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn('p-6 pt-0', className)} {...props} />
  )
)
CardContent.displayName = 'CardContent'

export { Card, CardHeader, CardTitle, CardContent }
```

### Business Components

#### Hero Section Component
```typescript
// components/sections/HeroSection.tsx
import { Button } from '@/components/ui/Button'
import { ArrowRightIcon } from '@heroicons/react/24/outline'
import Image from 'next/image'

interface HeroSectionProps {
  title: string
  subtitle: string
  description: string
  ctaText: string
  ctaLink: string
  imageUrl: string
  imageAlt: string
}

export function HeroSection({
  title,
  subtitle,
  description,
  ctaText,
  ctaLink,
  imageUrl,
  imageAlt
}: HeroSectionProps) {
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-hero-blue to-hero-navy">
      <div className="absolute inset-0 bg-black/20" />
      <div className="relative mx-auto max-w-7xl px-6 py-24 sm:py-32 lg:px-8">
        <div className="grid grid-cols-1 gap-y-16 lg:grid-cols-2 lg:gap-x-16">
          <div className="flex flex-col justify-center">
            <h1 className="text-4xl font-bold tracking-tight text-white sm:text-6xl">
              {title}
            </h1>
            <p className="mt-6 text-xl leading-8 text-blue-100">
              {subtitle}
            </p>
            <p className="mt-4 text-lg text-blue-200">
              {description}
            </p>
            <div className="mt-10 flex items-center gap-x-6">
              <Button 
                size="xl" 
                variant="default"
                className="bg-white text-hero-blue hover:bg-gray-100"
              >
                {ctaText}
                <ArrowRightIcon className="ml-2 h-5 w-5" />
              </Button>
            </div>
          </div>
          <div className="relative lg:order-last">
            <Image
              src={imageUrl}
              alt={imageAlt}
              width={600}
              height={400}
              className="rounded-2xl object-cover shadow-xl"
              priority
            />
          </div>
        </div>
      </div>
    </section>
  )
}
```

#### Service Card Component
```typescript
// components/cards/ServiceCard.tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import Image from 'next/image'

interface ServiceCardProps {
  title: string
  description: string
  imageUrl: string
  features: string[]
  ctaText: string
  ctaLink: string
}

export function ServiceCard({
  title,
  description,
  imageUrl,
  features,
  ctaText,
  ctaLink
}: ServiceCardProps) {
  return (
    <Card className="h-full transition-transform hover:scale-105">
      <CardHeader>
        <div className="aspect-video relative mb-4 overflow-hidden rounded-lg">
          <Image
            src={imageUrl}
            alt={title}
            fill
            className="object-cover"
          />
        </div>
        <CardTitle className="text-hero-navy">{title}</CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col">
        <p className="text-gray-600 mb-4">{description}</p>
        <ul className="space-y-2 mb-6 flex-grow">
          {features.map((feature, index) => (
            <li key={index} className="flex items-start">
              <span className="mr-2 text-green-500">✓</span>
              <span className="text-sm text-gray-700">{feature}</span>
            </li>
          ))}
        </ul>
        <Button variant="outline" className="w-full">
          {ctaText}
        </Button>
      </CardContent>
    </Card>
  )
}
```

#### Contact Form Component
```typescript
// components/forms/ContactForm.tsx
import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Button } from '@/components/ui/Button'

const contactSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  email: z.string().email('Email inválido'),
  phone: z.string().min(10, 'Telefone inválido'),
  company: z.string().optional(),
  message: z.string().min(10, 'Mensagem deve ter pelo menos 10 caracteres')
})

type ContactFormData = z.infer<typeof contactSchema>

export function ContactForm() {
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [isSubmitted, setIsSubmitted] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset
  } = useForm<ContactFormData>({
    resolver: zodResolver(contactSchema)
  })

  const onSubmit = async (data: ContactFormData) => {
    setIsSubmitting(true)
    try {
      const response = await fetch('/api/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      })
      
      if (response.ok) {
        setIsSubmitted(true)
        reset()
      }
    } catch (error) {
      console.error('Erro ao enviar formulário:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  if (isSubmitted) {
    return (
      <div className="text-center p-8 bg-green-50 rounded-lg">
        <h3 className="text-lg font-semibold text-green-800 mb-2">
          Mensagem enviada com sucesso!
        </h3>
        <p className="text-green-600">
          Entraremos em contato em breve.
        </p>
      </div>
    )
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Nome *
          </label>
          <input
            {...register('name')}
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-hero-blue focus:border-transparent"
            placeholder="Seu nome completo"
          />
          {errors.name && (
            <p className="mt-1 text-sm text-red-600">{errors.name.message}</p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Email *
          </label>
          <input
            {...register('email')}
            type="email"
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-hero-blue focus:border-transparent"
            placeholder="seu@email.com"
          />
          {errors.email && (
            <p className="mt-1 text-sm text-red-600">{errors.email.message}</p>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Telefone *
          </label>
          <input
            {...register('phone')}
            type="tel"
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-hero-blue focus:border-transparent"
            placeholder="(11) 99999-9999"
          />
          {errors.phone && (
            <p className="mt-1 text-sm text-red-600">{errors.phone.message}</p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Empresa
          </label>
          <input
            {...register('company')}
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-hero-blue focus:border-transparent"
            placeholder="Nome da empresa"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Mensagem *
        </label>
        <textarea
          {...register('message')}
          rows={5}
          className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-hero-blue focus:border-transparent"
          placeholder="Descreva seu projeto ou necessidade..."
        />
        {errors.message && (
          <p className="mt-1 text-sm text-red-600">{errors.message.message}</p>
        )}
      </div>

      <Button
        type="submit"
        size="lg"
        className="w-full"
        disabled={isSubmitting}
      >
        {isSubmitting ? 'Enviando...' : 'Enviar Mensagem'}
      </Button>
    </form>
  )
}
```

## Accessibility Standards

### WCAG 2.1 AA Compliance
```typescript
// lib/accessibility.ts
export const accessibilityStandards = {
  colorContrast: {
    normal: '4.5:1',
    large: '3:1',
    enhanced: '7:1'
  },
  focusManagement: {
    visibleFocusIndicator: true,
    logicalTabOrder: true,
    skipLinks: true
  },
  semanticMarkup: {
    headingHierarchy: true,
    landmarkRoles: true,
    altText: true,
    ariaLabels: true
  },
  keyboardNavigation: {
    fullKeyboardAccess: true,
    escapeKey: true,
    enterActivation: true
  }
}
```

### Accessibility Components
```typescript
// components/accessibility/SkipLink.tsx
export function SkipLink() {
  return (
    <a
      href="#main-content"
      className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 bg-hero-blue text-white px-4 py-2 rounded-md z-50"
    >
      Pular para o conteúdo principal
    </a>
  )
}

// components/accessibility/FocusTrap.tsx
import { useEffect, useRef } from 'react'

interface FocusTrapProps {
  children: React.ReactNode
  active: boolean
}

export function FocusTrap({ children, active }: FocusTrapProps) {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!active || !containerRef.current) return

    const focusableElements = containerRef.current.querySelectorAll(
      'a[href], button, textarea, input, select, [tabindex]:not([tabindex="-1"])'
    )

    const firstElement = focusableElements[0] as HTMLElement
    const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Tab') {
        if (e.shiftKey) {
          if (document.activeElement === firstElement) {
            e.preventDefault()
            lastElement.focus()
          }
        } else {
          if (document.activeElement === lastElement) {
            e.preventDefault()
            firstElement.focus()
          }
        }
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    firstElement?.focus()

    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [active])

  return <div ref={containerRef}>{children}</div>
}
```

## Component Testing Strategy

### Unit Testing with Jest + Testing Library
```typescript
// __tests__/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from '@/components/ui/Button'

describe('Button Component', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('applies variant classes correctly', () => {
    render(<Button variant="outline">Outline Button</Button>)
    const button = screen.getByText('Outline Button')
    expect(button).toHaveClass('border-hero-blue')
  })

  it('handles click events', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click me</Button>)
    
    fireEvent.click(screen.getByText('Click me'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('is accessible', () => {
    render(<Button aria-label="Custom button">Icon only</Button>)
    expect(screen.getByLabelText('Custom button')).toBeInTheDocument()
  })
})
```

## Performance Optimization

### Component Lazy Loading
```typescript
// components/lazy/index.ts
import dynamic from 'next/dynamic'

export const LazyContactForm = dynamic(
  () => import('@/components/forms/ContactForm').then(mod => ({ default: mod.ContactForm })),
  {
    loading: () => <div className="animate-pulse bg-gray-200 h-96 rounded-lg" />,
    ssr: false
  }
)

export const LazyTestimonials = dynamic(
  () => import('@/components/sections/Testimonials'),
  {
    loading: () => <div className="animate-pulse bg-gray-200 h-64 rounded-lg" />
  }
)
```

### Bundle Optimization
```typescript
// next.config.js - Component bundle analysis
const bundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true'
})

module.exports = bundleAnalyzer({
  experimental: {
    optimizePackageImports: ['@heroicons/react']
  }
})
```

## Design System Benefits

1. **Consistency**: Unified visual language across all pages
2. **Efficiency**: Reusable components reduce development time
3. **Maintainability**: Centralized styling and behavior updates
4. **Accessibility**: Built-in WCAG compliance
5. **Performance**: Optimized components with lazy loading
6. **Developer Experience**: TypeScript integration and clear APIs