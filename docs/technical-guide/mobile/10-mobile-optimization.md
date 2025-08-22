# 10. Mobile Optimization Guidelines

## Mobile-First Design Strategy

### Responsive Design Principles
```typescript
// tailwind.config.ts - Mobile-first breakpoints
export default {
  theme: {
    screens: {
      // Mobile-first breakpoints
      'xs': '475px',
      'sm': '640px',   // Small tablets
      'md': '768px',   // Tablets
      'lg': '1024px',  // Small laptops
      'xl': '1280px',  // Desktops
      '2xl': '1536px', // Large desktops
    },
    extend: {
      // Mobile-optimized spacing
      spacing: {
        'safe-top': 'env(safe-area-inset-top)',
        'safe-bottom': 'env(safe-area-inset-bottom)',
        'safe-left': 'env(safe-area-inset-left)',
        'safe-right': 'env(safe-area-inset-right)',
      },
      
      // Touch-friendly sizes
      minHeight: {
        'touch': '44px',  // iOS minimum touch target
        'touch-android': '48px', // Android minimum touch target
      },
      
      // Mobile typography
      fontSize: {
        'mobile-xs': ['12px', { lineHeight: '16px' }],
        'mobile-sm': ['14px', { lineHeight: '20px' }],
        'mobile-base': ['16px', { lineHeight: '24px' }],
        'mobile-lg': ['18px', { lineHeight: '28px' }],
        'mobile-xl': ['20px', { lineHeight: '32px' }],
        'mobile-2xl': ['24px', { lineHeight: '36px' }],
        'mobile-3xl': ['30px', { lineHeight: '42px' }],
      }
    }
  },
  plugins: [
    // Custom plugin for mobile utilities
    function({ addUtilities, theme }) {
      addUtilities({
        '.touch-target': {
          minHeight: theme('minHeight.touch'),
          minWidth: theme('minHeight.touch'),
        },
        '.touch-target-android': {
          minHeight: theme('minHeight.touch-android'),
          minWidth: theme('minHeight.touch-android'),
        },
        '.safe-area': {
          paddingTop: 'env(safe-area-inset-top)',
          paddingBottom: 'env(safe-area-inset-bottom)',
          paddingLeft: 'env(safe-area-inset-left)',
          paddingRight: 'env(safe-area-inset-right)',
        }
      })
    }
  ]
}
```

### Mobile-Optimized Components
```typescript
// components/mobile/MobileHeader.tsx
import { useState, useEffect } from 'react'
import { Bars3Icon, XMarkIcon } from '@heroicons/react/24/outline'
import { motion, AnimatePresence } from 'framer-motion'

export function MobileHeader() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20)
    }
    
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  // Prevent body scroll when menu is open
  useEffect(() => {
    if (isMenuOpen) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = 'unset'
    }
    
    return () => {
      document.body.style.overflow = 'unset'
    }
  }, [isMenuOpen])

  return (
    <>
      <header className={`
        fixed top-0 left-0 right-0 z-50 transition-all duration-300
        ${scrolled 
          ? 'bg-white/95 backdrop-blur-sm shadow-sm' 
          : 'bg-transparent'
        }
        safe-area
      `}>
        <div className="flex items-center justify-between px-4 py-3">
          {/* Logo */}
          <div className="flex-shrink-0">
            <img 
              src="/logo-hero.svg" 
              alt="HERO" 
              className="h-8 w-auto"
            />
          </div>

          {/* Menu Toggle */}
          <button
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            className="touch-target flex items-center justify-center rounded-md p-2 text-gray-700 hover:bg-gray-100"
            aria-label="Toggle menu"
          >
            {isMenuOpen ? (
              <XMarkIcon className="h-6 w-6" />
            ) : (
              <Bars3Icon className="h-6 w-6" />
            )}
          </button>
        </div>
      </header>

      {/* Mobile Menu Overlay */}
      <AnimatePresence>
        {isMenuOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-40 bg-black/50"
            onClick={() => setIsMenuOpen(false)}
          />
        )}
      </AnimatePresence>

      {/* Mobile Menu */}
      <AnimatePresence>
        {isMenuOpen && (
          <motion.nav
            initial={{ x: '100%' }}
            animate={{ x: 0 }}
            exit={{ x: '100%' }}
            transition={{ type: 'tween', ease: 'easeInOut', duration: 0.3 }}
            className="fixed top-0 right-0 bottom-0 z-50 w-80 max-w-[85vw] bg-white shadow-xl safe-area"
          >
            <div className="flex flex-col h-full">
              {/* Menu Header */}
              <div className="flex items-center justify-between p-4 border-b">
                <img src="/logo-hero.svg" alt="HERO" className="h-8" />
                <button
                  onClick={() => setIsMenuOpen(false)}
                  className="touch-target rounded-md p-2 hover:bg-gray-100"
                >
                  <XMarkIcon className="h-6 w-6" />
                </button>
              </div>

              {/* Menu Items */}
              <div className="flex-1 overflow-y-auto py-4">
                <MobileMenuItems onItemClick={() => setIsMenuOpen(false)} />
              </div>

              {/* Menu Footer */}
              <div className="p-4 border-t bg-gray-50">
                <MobileMenuFooter />
              </div>
            </div>
          </motion.nav>
        )}
      </AnimatePresence>
    </>
  )
}

function MobileMenuItems({ onItemClick }: { onItemClick: () => void }) {
  const menuItems = [
    { href: '/', label: 'Início' },
    { href: '/servicos', label: 'Serviços' },
    { href: '/sobre', label: 'Sobre' },
    { href: '/cases', label: 'Cases' },
    { href: '/blog', label: 'Blog' },
    { href: '/contato', label: 'Contato' }
  ]

  return (
    <div className="space-y-1">
      {menuItems.map((item, index) => (
        <motion.a
          key={item.href}
          href={item.href}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: index * 0.1 }}
          onClick={onItemClick}
          className="
            block px-4 py-3 text-lg font-medium text-gray-900 
            hover:bg-gray-50 active:bg-gray-100 transition-colors
            touch-target
          "
        >
          {item.label}
        </motion.a>
      ))}
    </div>
  )
}

function MobileMenuFooter() {
  return (
    <div className="space-y-3">
      <a
        href="/agendar"
        className="
          block w-full rounded-lg bg-hero-blue px-4 py-3 text-center 
          text-white font-medium hover:bg-hero-navy transition-colors
          touch-target
        "
      >
        Agendar Consultoria
      </a>
      
      <div className="flex items-center justify-center space-x-4">
        <a
          href="tel:+5511999999999"
          className="
            flex items-center space-x-2 text-sm text-gray-600 
            hover:text-hero-blue transition-colors touch-target
          "
        >
          <span>📞</span>
          <span>(11) 99999-9999</span>
        </a>
      </div>
    </div>
  )
}
```

### Touch-Optimized Form Components
```typescript
// components/mobile/MobileForm.tsx
import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { contactFormSchema } from '@/lib/validation'

export function MobileContactForm() {
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [focusedField, setFocusedField] = useState<string | null>(null)

  const {
    register,
    handleSubmit,
    formState: { errors },
    watch
  } = useForm({
    resolver: zodResolver(contactFormSchema),
    mode: 'onBlur'
  })

  const onSubmit = async (data: any) => {
    setIsSubmitting(true)
    try {
      const response = await fetch('/api/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      })
      
      if (response.ok) {
        // Handle success
      }
    } catch (error) {
      console.error('Form submission error:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      {/* Mobile-optimized input fields */}
      <MobileInputField
        label="Nome completo"
        type="text"
        placeholder="Seu nome"
        error={errors.name?.message}
        isFocused={focusedField === 'name'}
        onFocus={() => setFocusedField('name')}
        onBlur={() => setFocusedField(null)}
        {...register('name')}
      />

      <MobileInputField
        label="Email"
        type="email"
        placeholder="seu@email.com"
        error={errors.email?.message}
        isFocused={focusedField === 'email'}
        onFocus={() => setFocusedField('email')}
        onBlur={() => setFocusedField(null)}
        {...register('email')}
      />

      <MobileInputField
        label="Telefone"
        type="tel"
        placeholder="(11) 99999-9999"
        error={errors.phone?.message}
        isFocused={focusedField === 'phone'}
        onFocus={() => setFocusedField('phone')}
        onBlur={() => setFocusedField(null)}
        {...register('phone')}
      />

      <MobileSelectField
        label="Serviço de interesse"
        options={[
          { value: '', label: 'Selecione um serviço' },
          { value: 'strategy', label: 'Estratégia Empresarial' },
          { value: 'branding', label: 'Branding & Design' },
          { value: 'digital', label: 'Transformação Digital' },
          { value: 'consulting', label: 'Consultoria Geral' }
        ]}
        error={errors.service?.message}
        {...register('service')}
      />

      <MobileTextAreaField
        label="Mensagem"
        placeholder="Descreva seu projeto ou necessidade..."
        rows={4}
        error={errors.message?.message}
        isFocused={focusedField === 'message'}
        onFocus={() => setFocusedField('message')}
        onBlur={() => setFocusedField(null)}
        {...register('message')}
      />

      {/* Submit button with loading state */}
      <button
        type="submit"
        disabled={isSubmitting}
        className="
          w-full rounded-lg bg-hero-blue px-6 py-4 text-white font-medium
          hover:bg-hero-navy disabled:opacity-50 disabled:cursor-not-allowed
          transition-all duration-200 touch-target
          focus:ring-4 focus:ring-hero-blue/25 focus:outline-none
        "
      >
        {isSubmitting ? (
          <div className="flex items-center justify-center space-x-2">
            <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            <span>Enviando...</span>
          </div>
        ) : (
          'Enviar Mensagem'
        )}
      </button>
    </form>
  )
}

// Mobile-optimized input component
const MobileInputField = React.forwardRef<HTMLInputElement, {
  label: string
  type: string
  placeholder: string
  error?: string
  isFocused?: boolean
  onFocus?: () => void
  onBlur?: () => void
}>((props, ref) => {
  const { label, type, placeholder, error, isFocused, onFocus, onBlur, ...inputProps } = props

  return (
    <div className="space-y-2">
      <label className="block text-sm font-medium text-gray-700">
        {label}
      </label>
      <div className="relative">
        <input
          ref={ref}
          type={type}
          placeholder={placeholder}
          onFocus={onFocus}
          onBlur={onBlur}
          className={`
            w-full rounded-lg border px-4 py-3 text-base
            transition-all duration-200 touch-target
            focus:ring-4 focus:ring-hero-blue/25 focus:border-hero-blue focus:outline-none
            ${error 
              ? 'border-red-300 bg-red-50' 
              : isFocused 
                ? 'border-hero-blue bg-white' 
                : 'border-gray-300 bg-white'
            }
            ${isFocused ? 'shadow-lg' : 'shadow-sm'}
          `}
          {...inputProps}
        />
        {error && (
          <div className="absolute inset-y-0 right-0 flex items-center pr-3">
            <span className="text-red-500">⚠️</span>
          </div>
        )}
      </div>
      {error && (
        <p className="text-sm text-red-600">{error}</p>
      )}
    </div>
  )
})
```

## Progressive Web App (PWA) Implementation

### PWA Configuration
```typescript
// next.config.js - PWA setup
const withPWA = require('next-pwa')({
  dest: 'public',
  register: true,
  skipWaiting: true,
  runtimeCaching: [
    {
      urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
      handler: 'CacheFirst',
      options: {
        cacheName: 'google-fonts',
        expiration: {
          maxEntries: 4,
          maxAgeSeconds: 365 * 24 * 60 * 60 // 365 days
        }
      }
    },
    {
      urlPattern: /^https:\/\/cdn\.sanity\.io\/.*/i,
      handler: 'StaleWhileRevalidate',
      options: {
        cacheName: 'sanity-images',
        expiration: {
          maxEntries: 60,
          maxAgeSeconds: 30 * 24 * 60 * 60 // 30 days
        }
      }
    },
    {
      urlPattern: /\/api\/.*/i,
      handler: 'NetworkFirst',
      options: {
        cacheName: 'api-cache',
        expiration: {
          maxEntries: 20,
          maxAgeSeconds: 5 * 60 // 5 minutes
        },
        networkTimeoutSeconds: 10
      }
    }
  ],
  buildExcludes: [/middleware-manifest\.json$/]
})

module.exports = withPWA({
  // Your existing Next.js config
})
```

### PWA Manifest
```json
// public/manifest.json
{
  "name": "HERO Consultoria - Estratégia e Crescimento",
  "short_name": "HERO",
  "description": "Transformamos negócios através de estratégias personalizadas, branding inovador e soluções digitais.",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#0066CC",
  "orientation": "portrait-primary",
  "categories": ["business", "consulting", "strategy"],
  "lang": "pt-BR",
  "icons": [
    {
      "src": "/icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "/icons/icon-96x96.png",
      "sizes": "96x96",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "/icons/icon-128x128.png",
      "sizes": "128x128",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "/icons/icon-144x144.png",
      "sizes": "144x144",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "/icons/icon-152x152.png",
      "sizes": "152x152",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "/icons/icon-384x384.png",
      "sizes": "384x384",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable any"
    }
  ],
  "screenshots": [
    {
      "src": "/screenshots/mobile-home.png",
      "sizes": "390x844",
      "type": "image/png",
      "form_factor": "narrow",
      "label": "Home page"
    },
    {
      "src": "/screenshots/mobile-services.png",
      "sizes": "390x844",
      "type": "image/png",
      "form_factor": "narrow",
      "label": "Services page"
    }
  ],
  "shortcuts": [
    {
      "name": "Agendar Consultoria",
      "short_name": "Agendar",
      "description": "Agende uma consultoria estratégica",
      "url": "/agendar",
      "icons": [
        {
          "src": "/icons/shortcut-calendar.png",
          "sizes": "192x192"
        }
      ]
    },
    {
      "name": "Contato",
      "short_name": "Contato",
      "description": "Entre em contato conosco",
      "url": "/contato",
      "icons": [
        {
          "src": "/icons/shortcut-contact.png",
          "sizes": "192x192"
        }
      ]
    }
  ],
  "related_applications": [],
  "prefer_related_applications": false
}
```

### Service Worker with Push Notifications
```typescript
// public/sw.js - Custom service worker
const CACHE_NAME = 'hero-v1'
const OFFLINE_PAGE = '/offline'

// Install event
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll([
        '/',
        '/offline',
        '/manifest.json',
        '/icons/icon-192x192.png'
      ])
    })
  )
})

// Activate event
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName)
          }
        })
      )
    })
  )
})

// Fetch event with offline fallback
self.addEventListener('fetch', (event) => {
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request).catch(() => {
        return caches.match(OFFLINE_PAGE)
      })
    )
  } else {
    event.respondWith(
      caches.match(event.request).then((response) => {
        return response || fetch(event.request)
      })
    )
  }
})

// Push notification handling
self.addEventListener('push', (event) => {
  const options = {
    body: event.data ? event.data.text() : 'Nova mensagem da HERO',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/badge-72x72.png',
    vibrate: [200, 100, 200],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'explore',
        title: 'Ver detalhes',
        icon: '/icons/checkmark.png'
      },
      {
        action: 'close',
        title: 'Fechar',
        icon: '/icons/xmark.png'
      }
    ]
  }

  event.waitUntil(
    self.registration.showNotification('HERO Consultoria', options)
  )
})

// Notification click handling
self.addEventListener('notificationclick', (event) => {
  event.notification.close()

  if (event.action === 'explore') {
    // Open the app and navigate to a specific page
    event.waitUntil(
      clients.openWindow('/')
    )
  }
})
```

## Mobile Performance Optimization

### Image Optimization for Mobile
```typescript
// components/mobile/MobileImage.tsx
import Image from 'next/image'
import { useState } from 'react'

interface MobileImageProps {
  src: string
  alt: string
  width: number
  height: number
  priority?: boolean
  className?: string
  sizes?: string
}

export function MobileImage({
  src,
  alt,
  width,
  height,
  priority = false,
  className = '',
  sizes = '(max-width: 768px) 100vw, 50vw'
}: MobileImageProps) {
  const [isLoading, setIsLoading] = useState(true)
  const [hasError, setHasError] = useState(false)

  return (
    <div className={`relative overflow-hidden ${className}`}>
      {!hasError ? (
        <Image
          src={src}
          alt={alt}
          width={width}
          height={height}
          priority={priority}
          sizes={sizes}
          placeholder="blur"
          blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAAIAAoDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAhEAACAQMDBQAAAAAAAAAAAAABAgMABAUGIWGRkqGx0f/EABUBAQEAAAAAAAAAAAAAAAAAAAMF/8QAGhEAAgIDAAAAAAAAAAAAAAAAAAECEgMRkf/aAAwDAQACEQMRAD8AltJagyeH0AthI5xdrLcNM91BF5pX2HaH9bcfaSXWGaRmknyEkayRUyRJGI8eRjp5+VkrWey9nOz2eWONvpOpL6kVRc6wBvyPhMNjVlrUnTJBMJCcdxPqvhZJYokl7eXWWpPLG0WciNDe2V5mLWR8TLN8q7Ea0wStBu6T8bQZptZaKOjgvEi3LmSr8tJQ8FnGawO4bCAShSANkj1VbSO/Pq8LwDOdSXDXPvE="
          onLoadingComplete={() => setIsLoading(false)}
          onError={() => setHasError(true)}
          className={`
            duration-700 ease-in-out
            ${isLoading
              ? 'scale-110 blur-2xl grayscale'
              : 'scale-100 blur-0 grayscale-0'
            }
          `}
          style={{
            maxWidth: '100%',
            height: 'auto',
          }}
        />
      ) : (
        // Fallback for broken images
        <div className="flex items-center justify-center bg-gray-200 text-gray-500 h-full">
          <span>Imagem não disponível</span>
        </div>
      )}
      
      {/* Loading indicator */}
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-gray-100">
          <div className="w-8 h-8 border-2 border-gray-300 border-t-hero-blue rounded-full animate-spin" />
        </div>
      )}
    </div>
  )
}
```

### Mobile-Specific Layout Hook
```typescript
// hooks/useMobileLayout.ts
import { useState, useEffect } from 'react'

export function useMobileLayout() {
  const [isMobile, setIsMobile] = useState(false)
  const [isTablet, setIsTablet] = useState(false)
  const [orientation, setOrientation] = useState<'portrait' | 'landscape'>('portrait')
  const [viewportHeight, setViewportHeight] = useState(0)

  useEffect(() => {
    const checkDevice = () => {
      const width = window.innerWidth
      const height = window.innerHeight
      
      setIsMobile(width < 768)
      setIsTablet(width >= 768 && width < 1024)
      setOrientation(width > height ? 'landscape' : 'portrait')
      setViewportHeight(height)
    }

    checkDevice()
    window.addEventListener('resize', checkDevice)
    window.addEventListener('orientationchange', checkDevice)

    return () => {
      window.removeEventListener('resize', checkDevice)
      window.removeEventListener('orientationchange', checkDevice)
    }
  }, [])

  return {
    isMobile,
    isTablet,
    isDesktop: !isMobile && !isTablet,
    orientation,
    viewportHeight,
    // Utility functions
    isMobilePortrait: isMobile && orientation === 'portrait',
    isMobileLandscape: isMobile && orientation === 'landscape',
    hasNotch: viewportHeight > 800 && isMobile, // Rough estimate for devices with notch
  }
}
```

### Touch Gesture Support
```typescript
// hooks/useSwipeGesture.ts
import { useState, useRef, useCallback } from 'react'

interface SwipeGestureOptions {
  onSwipeLeft?: () => void
  onSwipeRight?: () => void
  onSwipeUp?: () => void
  onSwipeDown?: () => void
  threshold?: number
}

export function useSwipeGesture(options: SwipeGestureOptions) {
  const {
    onSwipeLeft,
    onSwipeRight,
    onSwipeUp,
    onSwipeDown,
    threshold = 50
  } = options

  const touchStart = useRef<{ x: number; y: number } | null>(null)
  const [isSwiping, setIsSwiping] = useState(false)

  const handleTouchStart = useCallback((e: React.TouchEvent) => {
    const touch = e.touches[0]
    touchStart.current = { x: touch.clientX, y: touch.clientY }
    setIsSwiping(true)
  }, [])

  const handleTouchMove = useCallback((e: React.TouchEvent) => {
    if (!touchStart.current) return
    
    // Prevent scrolling during swipe
    if (isSwiping) {
      e.preventDefault()
    }
  }, [isSwiping])

  const handleTouchEnd = useCallback((e: React.TouchEvent) => {
    if (!touchStart.current) return

    const touch = e.changedTouches[0]
    const deltaX = touch.clientX - touchStart.current.x
    const deltaY = touch.clientY - touchStart.current.y

    const absDeltaX = Math.abs(deltaX)
    const absDeltaY = Math.abs(deltaY)

    // Determine swipe direction
    if (Math.max(absDeltaX, absDeltaY) > threshold) {
      if (absDeltaX > absDeltaY) {
        // Horizontal swipe
        if (deltaX > 0) {
          onSwipeRight?.()
        } else {
          onSwipeLeft?.()
        }
      } else {
        // Vertical swipe
        if (deltaY > 0) {
          onSwipeDown?.()
        } else {
          onSwipeUp?.()
        }
      }
    }

    touchStart.current = null
    setIsSwiping(false)
  }, [onSwipeLeft, onSwipeRight, onSwipeUp, onSwipeDown, threshold])

  return {
    handleTouchStart,
    handleTouchMove,
    handleTouchEnd,
    isSwiping
  }
}
```

## Mobile-Specific Features

### Click-to-Call Integration
```typescript
// components/mobile/ClickToCall.tsx
import { PhoneIcon } from '@heroicons/react/24/outline'
import { useMobileLayout } from '@/hooks/useMobileLayout'

interface ClickToCallProps {
  phoneNumber: string
  displayNumber?: string
  className?: string
  trackingLabel?: string
}

export function ClickToCall({
  phoneNumber,
  displayNumber,
  className = '',
  trackingLabel = 'phone_call'
}: ClickToCallProps) {
  const { isMobile } = useMobileLayout()

  const handleClick = () => {
    // Track the phone call event
    if (typeof gtag !== 'undefined') {
      gtag('event', 'phone_call_initiated', {
        event_category: 'contact',
        event_label: trackingLabel,
        value: 1
      })
    }

    // On mobile, the tel: link will open the phone app
    // On desktop, it might not do anything, so we could show instructions
    if (!isMobile) {
      alert(`Ligue para: ${displayNumber || phoneNumber}`)
    }
  }

  return (
    <a
      href={`tel:${phoneNumber}`}
      onClick={handleClick}
      className={`
        inline-flex items-center space-x-2 rounded-lg px-4 py-3
        bg-green-600 text-white hover:bg-green-700 transition-colors
        touch-target focus:ring-4 focus:ring-green-600/25 focus:outline-none
        ${className}
      `}
    >
      <PhoneIcon className="h-5 w-5" />
      <span className="font-medium">
        {isMobile ? 'Ligar agora' : displayNumber || phoneNumber}
      </span>
    </a>
  )
}
```

### WhatsApp Integration
```typescript
// components/mobile/WhatsAppButton.tsx
import { ChatBubbleLeftRightIcon } from '@heroicons/react/24/outline'

interface WhatsAppButtonProps {
  phoneNumber: string
  message?: string
  className?: string
  position?: 'fixed' | 'inline'
}

export function WhatsAppButton({
  phoneNumber,
  message = 'Olá! Gostaria de saber mais sobre os serviços da HERO.',
  className = '',
  position = 'inline'
}: WhatsAppButtonProps) {
  const handleClick = () => {
    const encodedMessage = encodeURIComponent(message)
    const whatsappUrl = `https://wa.me/${phoneNumber}?text=${encodedMessage}`
    
    // Track WhatsApp click
    if (typeof gtag !== 'undefined') {
      gtag('event', 'whatsapp_click', {
        event_category: 'contact',
        event_label: 'whatsapp_button',
        value: 1
      })
    }

    window.open(whatsappUrl, '_blank')
  }

  const baseClasses = `
    inline-flex items-center space-x-2 rounded-full px-4 py-3
    bg-green-500 text-white hover:bg-green-600 transition-all duration-200
    shadow-lg hover:shadow-xl transform hover:scale-105
    touch-target focus:ring-4 focus:ring-green-500/25 focus:outline-none
  `

  const positionClasses = position === 'fixed' 
    ? 'fixed bottom-6 right-6 z-50' 
    : ''

  return (
    <button
      onClick={handleClick}
      className={`${baseClasses} ${positionClasses} ${className}`}
      aria-label="Abrir conversa no WhatsApp"
    >
      <ChatBubbleLeftRightIcon className="h-6 w-6" />
      <span className="font-medium">WhatsApp</span>
    </button>
  )
}
```

### Mobile Analytics Events
```typescript
// lib/mobile-analytics.ts
export class MobileAnalytics {
  static trackMobileEvent(action: string, data?: Record<string, any>) {
    // Enhanced mobile-specific analytics
    const mobileData = {
      ...data,
      device_type: 'mobile',
      user_agent: navigator.userAgent,
      screen_width: window.screen.width,
      screen_height: window.screen.height,
      viewport_width: window.innerWidth,
      viewport_height: window.innerHeight,
      pixel_ratio: window.devicePixelRatio,
      connection: (navigator as any).connection?.effectiveType || 'unknown',
      timestamp: Date.now()
    }

    // Send to analytics
    if (typeof gtag !== 'undefined') {
      gtag('event', action, {
        event_category: 'mobile_interaction',
        custom_parameters: mobileData
      })
    }

    // Send to custom analytics endpoint
    fetch('/api/analytics/mobile', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        action,
        data: mobileData
      })
    }).catch(console.error)
  }

  static trackScrollDepth(percentage: number) {
    this.trackMobileEvent('mobile_scroll_depth', {
      percentage,
      page: window.location.pathname
    })
  }

  static trackTouchInteraction(element: string, action: 'tap' | 'long_press' | 'swipe') {
    this.trackMobileEvent('mobile_touch_interaction', {
      element,
      action,
      page: window.location.pathname
    })
  }

  static trackFormFieldFocus(fieldName: string) {
    this.trackMobileEvent('mobile_form_field_focus', {
      field_name: fieldName,
      page: window.location.pathname
    })
  }

  static trackOrientationChange(orientation: 'portrait' | 'landscape') {
    this.trackMobileEvent('mobile_orientation_change', {
      orientation,
      page: window.location.pathname
    })
  }
}
```

## Mobile Testing Strategy

### Mobile Testing Tools
```typescript
// tests/mobile.test.ts
import { test, expect, devices } from '@playwright/test'

// Test on multiple mobile devices
const mobileDevices = [
  'iPhone 12',
  'iPhone 12 Pro',
  'iPhone SE',
  'Pixel 5',
  'Samsung Galaxy S21',
  'iPad'
]

mobileDevices.forEach(deviceName => {
  test.describe(`Mobile tests on ${deviceName}`, () => {
    test.use({ ...devices[deviceName] })

    test('should load homepage correctly', async ({ page }) => {
      await page.goto('/')
      
      // Check if page loads
      await expect(page.locator('h1')).toBeVisible()
      
      // Check if mobile menu is present
      await expect(page.locator('[aria-label="Toggle menu"]')).toBeVisible()
      
      // Check Core Web Vitals
      const lcp = await page.evaluate(() => {
        return new Promise(resolve => {
          new PerformanceObserver(list => {
            const entries = list.getEntries()
            const lastEntry = entries[entries.length - 1]
            resolve(lastEntry.startTime)
          }).observe({ entryTypes: ['largest-contentful-paint'] })
        })
      })
      
      expect(lcp).toBeLessThan(2500) // LCP should be under 2.5s
    })

    test('should handle touch interactions', async ({ page }) => {
      await page.goto('/')
      
      // Test menu toggle
      const menuButton = page.locator('[aria-label="Toggle menu"]')
      await menuButton.tap()
      
      // Check if menu opens
      await expect(page.locator('nav')).toBeVisible()
      
      // Test swipe gesture (if implemented)
      await page.touchscreen.tap(100, 100)
      await page.mouse.move(100, 100)
      await page.mouse.move(300, 100)
    })

    test('should handle forms correctly', async ({ page }) => {
      await page.goto('/contato')
      
      // Fill out contact form
      await page.fill('[name="name"]', 'Test User')
      await page.fill('[name="email"]', 'test@example.com')
      await page.fill('[name="phone"]', '11999999999')
      await page.fill('[name="message"]', 'Test message')
      
      // Check if fields are properly sized for touch
      const nameField = page.locator('[name="name"]')
      const boundingBox = await nameField.boundingBox()
      expect(boundingBox?.height).toBeGreaterThan(44) // iOS touch target minimum
    })

    test('should load images efficiently', async ({ page }) => {
      await page.goto('/')
      
      // Check if images have proper loading attributes
      const images = page.locator('img')
      const count = await images.count()
      
      for (let i = 0; i < count; i++) {
        const img = images.nth(i)
        const loading = await img.getAttribute('loading')
        const alt = await img.getAttribute('alt')
        
        // Check lazy loading for non-critical images
        if (i > 0) { // First image might be priority
          expect(loading).toBe('lazy')
        }
        
        // Check alt text
        expect(alt).toBeTruthy()
      }
    })
  })
})
```

## Benefits of This Mobile Strategy

1. **Mobile-First Experience**: Optimized for mobile users from the ground up
2. **Touch-Friendly Interface**: All interactive elements are properly sized
3. **Fast Loading**: Optimized images and lazy loading for mobile networks
4. **Offline Capability**: PWA features for offline browsing
5. **Native App Feel**: App-like experience with proper gestures and animations
6. **Performance Monitoring**: Mobile-specific analytics and Core Web Vitals tracking
7. **Cross-Device Testing**: Comprehensive testing across multiple devices
8. **Accessibility**: WCAG compliance with mobile accessibility standards