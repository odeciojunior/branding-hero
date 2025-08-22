# 1. Technology Stack Recommendations

## Core Framework: Next.js 14+ with App Router

### Primary Stack
```typescript
{
  "framework": "Next.js 14+",
  "runtime": "Node.js 18+",
  "language": "TypeScript 5+",
  "styling": "Tailwind CSS + Headless UI",
  "state": "Zustand + React Query",
  "cms": "Sanity CMS",
  "database": "PostgreSQL + Prisma",
  "hosting": "Vercel + Cloudflare",
  "monitoring": "Sentry + Vercel Analytics"
}
```

## Frontend Architecture

### React 18 with Server Components
- **Server Components**: For static content and SEO optimization
- **Client Components**: For interactive features and forms
- **Streaming**: Progressive page loading for better UX
- **Suspense**: Elegant loading states

### TypeScript Configuration
```typescript
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "ES6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{"name": "next"}],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/types/*": ["./src/types/*"]
    }
  }
}
```

## Styling & UI Framework

### Tailwind CSS + Headless UI
```typescript
// tailwind.config.ts
export default {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        serif: ['Playfair Display', 'serif'],
      },
      colors: {
        brand: {
          primary: '#1a365d',
          secondary: '#2d3748',
          accent: '#3182ce',
        },
        hero: {
          blue: '#0066CC',
          navy: '#003366',
          gray: '#6B7280',
        }
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.6s ease-out',
      }
    }
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
  ]
}
```

## State Management

### Zustand for Global State
```typescript
// stores/useAppStore.ts
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'

interface AppState {
  user: User | null
  theme: 'light' | 'dark'
  language: 'pt' | 'en' | 'es'
  setUser: (user: User | null) => void
  setTheme: (theme: 'light' | 'dark') => void
  setLanguage: (language: 'pt' | 'en' | 'es') => void
}

export const useAppStore = create<AppState>()(
  devtools(
    persist(
      (set) => ({
        user: null,
        theme: 'light',
        language: 'pt',
        setUser: (user) => set({ user }),
        setTheme: (theme) => set({ theme }),
        setLanguage: (language) => set({ language }),
      }),
      { name: 'hero-app-store' }
    )
  )
)
```

### React Query for Server State
```typescript
// lib/react-query.ts
import { QueryClient } from '@tanstack/react-query'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      retry: 3,
      refetchOnWindowFocus: false,
    },
  },
})
```

## Build Tools & Development

### Next.js Configuration
```typescript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
    typedRoutes: true,
    serverComponentsExternalPackages: ['@prisma/client'],
  },
  images: {
    domains: ['cdn.sanity.io', 'images.unsplash.com'],
    formats: ['image/webp', 'image/avif'],
  },
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
        ],
      },
    ]
  },
}

module.exports = nextConfig
```

## Package Dependencies

### Core Dependencies
```json
{
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "typescript": "^5.0.0",
    "@tailwindcss/typography": "^0.5.10",
    "@headlessui/react": "^1.7.17",
    "@heroicons/react": "^2.0.18",
    "zustand": "^4.4.6",
    "@tanstack/react-query": "^5.0.0",
    "framer-motion": "^10.16.4",
    "@sanity/client": "^6.8.0",
    "@sanity/image-url": "^1.0.2",
    "prisma": "^5.6.0",
    "@prisma/client": "^5.6.0",
    "zod": "^3.22.4",
    "react-hook-form": "^7.47.0",
    "@hookform/resolvers": "^3.3.2",
    "next-intl": "^3.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.8.10",
    "@types/react": "^18.2.33",
    "@types/react-dom": "^18.2.14",
    "tailwindcss": "^3.3.5",
    "eslint": "^8.52.0",
    "eslint-config-next": "^14.0.0",
    "prettier": "^3.0.3",
    "prettier-plugin-tailwindcss": "^0.5.6"
  }
}
```

## Development Workflow

### Code Quality Tools
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint --fix",
    "type-check": "tsc --noEmit",
    "format": "prettier --write .",
    "test": "jest",
    "test:watch": "jest --watch",
    "e2e": "playwright test"
  }
}
```

## Architecture Benefits

1. **Performance**: Server Components + Edge Runtime
2. **SEO**: Built-in optimization and SSG capabilities
3. **Developer Experience**: TypeScript + Hot reloading
4. **Scalability**: Incremental Static Regeneration
5. **Maintainability**: Component-based architecture
6. **Conversion Optimization**: Fast loading + smooth interactions

## Migration Strategy

### From Legacy Systems
1. **Content Migration**: Automated scripts for CMS transfer
2. **URL Preservation**: Redirect mapping for SEO
3. **Progressive Enhancement**: Gradual feature rollout
4. **Performance Monitoring**: Real-time metrics tracking

### Risk Mitigation
- **Staged Deployment**: Blue-green deployment strategy
- **Rollback Plan**: Instant reversion capabilities
- **Performance Budget**: Automated checks for regressions
- **User Testing**: A/B testing for critical paths