# 3. CMS Integration Strategy

## Headless CMS Architecture: Sanity

### Why Sanity for HERO
- **Developer Experience**: React-based studio with TypeScript support
- **Content Modeling**: Flexible schema design for complex content structures
- **Real-time Collaboration**: Multiple editors working simultaneously
- **Image Optimization**: Built-in CDN with automatic image processing
- **Internationalization**: Native multi-language support
- **API Performance**: GraphQL and REST APIs with edge caching
- **Revision History**: Complete version control for all content changes

### Sanity Studio Configuration

#### Project Setup
```typescript
// sanity.config.ts
import { defineConfig } from 'sanity'
import { deskTool } from 'sanity/desk'
import { visionTool } from '@sanity/vision'
import { media } from 'sanity-plugin-media'
import { internationalizedArray } from 'sanity-plugin-internationalized-array'

import { schemas } from './schemas'
import { structure } from './desk-structure'

export default defineConfig({
  name: 'hero-cms',
  title: 'HERO Content Management',
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
  apiVersion: '2023-12-01',
  basePath: '/admin',
  
  plugins: [
    deskTool({
      structure,
    }),
    visionTool(),
    media(),
    internationalizedArray({
      languages: [
        { id: 'pt', title: 'Português' },
        { id: 'en', title: 'English' },
        { id: 'es', title: 'Español' }
      ],
      defaultLanguages: ['pt'],
      fieldTypes: ['string', 'text', 'richText']
    })
  ],
  
  schema: {
    types: schemas,
  },
  
  studio: {
    components: {
      logo: () => <img src="/hero-logo.svg" alt="HERO" width={120} />,
    },
  },
})
```

### Content Schemas

#### Page Schema
```typescript
// schemas/page.ts
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'page',
  title: 'Páginas',
  type: 'document',
  icon: () => '📄',
  fields: [
    defineField({
      name: 'title',
      title: 'Título da Página',
      type: 'internationalizedArrayString',
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'slug',
      title: 'URL da Página',
      type: 'slug',
      options: {
        source: 'title.pt',
        maxLength: 96,
      },
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'seo',
      title: 'SEO',
      type: 'seo',
    }),
    defineField({
      name: 'sections',
      title: 'Seções da Página',
      type: 'array',
      of: [
        { type: 'heroSection' },
        { type: 'servicesSection' },
        { type: 'aboutSection' },
        { type: 'testimonialsSection' },
        { type: 'contactSection' },
        { type: 'contentSection' },
        { type: 'ctaSection' }
      ]
    }),
    defineField({
      name: 'publishedAt',
      title: 'Data de Publicação',
      type: 'datetime',
      initialValue: () => new Date().toISOString()
    }),
    defineField({
      name: 'status',
      title: 'Status',
      type: 'string',
      options: {
        list: [
          { title: 'Rascunho', value: 'draft' },
          { title: 'Publicado', value: 'published' },
          { title: 'Arquivado', value: 'archived' }
        ]
      },
      initialValue: 'draft'
    })
  ],
  preview: {
    select: {
      title: 'title.pt',
      slug: 'slug.current',
      status: 'status'
    },
    prepare({ title, slug, status }) {
      return {
        title: title || 'Sem título',
        subtitle: `/${slug} • ${status}`,
      }
    }
  }
})
```

#### Hero Section Schema
```typescript
// schemas/sections/heroSection.ts
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'heroSection',
  title: 'Seção Hero',
  type: 'object',
  icon: () => '🎯',
  fields: [
    defineField({
      name: 'title',
      title: 'Título Principal',
      type: 'internationalizedArrayString',
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'subtitle',
      title: 'Subtítulo',
      type: 'internationalizedArrayString',
    }),
    defineField({
      name: 'description',
      title: 'Descrição',
      type: 'internationalizedArrayText',
    }),
    defineField({
      name: 'backgroundImage',
      title: 'Imagem de Fundo',
      type: 'image',
      options: {
        hotspot: true,
      },
      fields: [
        {
          name: 'alt',
          title: 'Texto Alternativo',
          type: 'string',
          validation: Rule => Rule.required()
        }
      ]
    }),
    defineField({
      name: 'cta',
      title: 'Call to Action',
      type: 'object',
      fields: [
        {
          name: 'text',
          title: 'Texto do Botão',
          type: 'internationalizedArrayString',
        },
        {
          name: 'link',
          title: 'Link',
          type: 'url',
        },
        {
          name: 'style',
          title: 'Estilo do Botão',
          type: 'string',
          options: {
            list: [
              { title: 'Primário', value: 'primary' },
              { title: 'Secundário', value: 'secondary' },
              { title: 'Outline', value: 'outline' }
            ]
          }
        }
      ]
    }),
    defineField({
      name: 'settings',
      title: 'Configurações',
      type: 'object',
      fields: [
        {
          name: 'height',
          title: 'Altura da Seção',
          type: 'string',
          options: {
            list: [
              { title: 'Padrão (60vh)', value: 'default' },
              { title: 'Tela Cheia (100vh)', value: 'fullscreen' },
              { title: 'Compacta (40vh)', value: 'compact' }
            ]
          },
          initialValue: 'default'
        },
        {
          name: 'overlay',
          title: 'Sobreposição',
          type: 'number',
          description: 'Opacidade da sobreposição (0-100)',
          validation: Rule => Rule.min(0).max(100),
          initialValue: 20
        }
      ]
    })
  ],
  preview: {
    select: {
      title: 'title.pt',
      media: 'backgroundImage'
    },
    prepare({ title, media }) {
      return {
        title: `Hero: ${title || 'Sem título'}`,
        media
      }
    }
  }
})
```

#### Services Section Schema
```typescript
// schemas/sections/servicesSection.ts
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'servicesSection',
  title: 'Seção de Serviços',
  type: 'object',
  icon: () => '💼',
  fields: [
    defineField({
      name: 'title',
      title: 'Título da Seção',
      type: 'internationalizedArrayString',
    }),
    defineField({
      name: 'description',
      title: 'Descrição',
      type: 'internationalizedArrayText',
    }),
    defineField({
      name: 'services',
      title: 'Serviços',
      type: 'array',
      of: [
        {
          type: 'reference',
          to: [{ type: 'service' }]
        }
      ],
      validation: Rule => Rule.max(6)
    }),
    defineField({
      name: 'layout',
      title: 'Layout',
      type: 'string',
      options: {
        list: [
          { title: 'Grade 2x2', value: 'grid-2' },
          { title: 'Grade 3x2', value: 'grid-3' },
          { title: 'Carrossel', value: 'carousel' },
          { title: 'Lista', value: 'list' }
        ]
      },
      initialValue: 'grid-3'
    })
  ],
  preview: {
    select: {
      title: 'title.pt',
      serviceCount: 'services'
    },
    prepare({ title, serviceCount }) {
      const count = serviceCount?.length || 0
      return {
        title: `Serviços: ${title || 'Sem título'}`,
        subtitle: `${count} serviço${count !== 1 ? 's' : ''}`
      }
    }
  }
})
```

#### Service Document Schema
```typescript
// schemas/service.ts
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'service',
  title: 'Serviços',
  type: 'document',
  icon: () => '🔧',
  fields: [
    defineField({
      name: 'name',
      title: 'Nome do Serviço',
      type: 'internationalizedArrayString',
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'slug',
      title: 'URL do Serviço',
      type: 'slug',
      options: {
        source: 'name.pt',
        maxLength: 96,
      },
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'shortDescription',
      title: 'Descrição Curta',
      type: 'internationalizedArrayText',
      description: 'Para listagens e cards',
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'fullDescription',
      title: 'Descrição Completa',
      type: 'internationalizedArrayRichText',
    }),
    defineField({
      name: 'features',
      title: 'Características',
      type: 'array',
      of: [
        {
          type: 'object',
          fields: [
            {
              name: 'title',
              title: 'Título',
              type: 'internationalizedArrayString',
            },
            {
              name: 'description',
              title: 'Descrição',
              type: 'internationalizedArrayText',
            }
          ]
        }
      ]
    }),
    defineField({
      name: 'image',
      title: 'Imagem do Serviço',
      type: 'image',
      options: {
        hotspot: true,
      },
      fields: [
        {
          name: 'alt',
          title: 'Texto Alternativo',
          type: 'string',
          validation: Rule => Rule.required()
        }
      ]
    }),
    defineField({
      name: 'category',
      title: 'Categoria',
      type: 'reference',
      to: [{ type: 'serviceCategory' }]
    }),
    defineField({
      name: 'price',
      title: 'Preço',
      type: 'object',
      fields: [
        {
          name: 'type',
          title: 'Tipo de Preço',
          type: 'string',
          options: {
            list: [
              { title: 'Fixo', value: 'fixed' },
              { title: 'A partir de', value: 'from' },
              { title: 'Sob consulta', value: 'quote' }
            ]
          }
        },
        {
          name: 'value',
          title: 'Valor',
          type: 'number',
          hidden: ({ parent }) => parent?.type === 'quote'
        },
        {
          name: 'currency',
          title: 'Moeda',
          type: 'string',
          options: {
            list: [
              { title: 'Real (R$)', value: 'BRL' },
              { title: 'Dólar ($)', value: 'USD' },
              { title: 'Euro (€)', value: 'EUR' }
            ]
          },
          initialValue: 'BRL',
          hidden: ({ parent }) => parent?.type === 'quote'
        }
      ]
    }),
    defineField({
      name: 'seo',
      title: 'SEO',
      type: 'seo',
    })
  ],
  preview: {
    select: {
      title: 'name.pt',
      subtitle: 'shortDescription.pt',
      media: 'image'
    }
  }
})
```

### SEO Schema
```typescript
// schemas/objects/seo.ts
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'seo',
  title: 'SEO',
  type: 'object',
  fields: [
    defineField({
      name: 'metaTitle',
      title: 'Meta Título',
      type: 'internationalizedArrayString',
      description: 'Título que aparece nos resultados do Google (máx. 60 caracteres)',
      validation: Rule => Rule.max(60)
    }),
    defineField({
      name: 'metaDescription',
      title: 'Meta Descrição',
      type: 'internationalizedArrayText',
      description: 'Descrição que aparece nos resultados do Google (máx. 160 caracteres)',
      validation: Rule => Rule.max(160)
    }),
    defineField({
      name: 'keywords',
      title: 'Palavras-chave',
      type: 'array',
      of: [{ type: 'string' }],
      options: {
        layout: 'tags'
      }
    }),
    defineField({
      name: 'ogImage',
      title: 'Imagem para Redes Sociais',
      type: 'image',
      description: 'Imagem que aparece quando o link é compartilhado (1200x630px)',
      options: {
        hotspot: true,
      },
      fields: [
        {
          name: 'alt',
          title: 'Texto Alternativo',
          type: 'string',
        }
      ]
    }),
    defineField({
      name: 'noIndex',
      title: 'Não Indexar',
      type: 'boolean',
      description: 'Impede que esta página apareça nos resultados de busca',
      initialValue: false
    }),
    defineField({
      name: 'canonicalUrl',
      title: 'URL Canônica',
      type: 'url',
      description: 'URL oficial desta página (para evitar conteúdo duplicado)'
    })
  ]
})
```

## Content Management Workflows

### Editorial Workflow
```typescript
// workflows/editorial.ts
export const editorialWorkflow = {
  states: ['draft', 'review', 'approved', 'published', 'archived'],
  
  permissions: {
    editor: ['draft', 'review'],
    reviewer: ['review', 'approved'],
    admin: ['draft', 'review', 'approved', 'published', 'archived']
  },
  
  notifications: {
    onSubmitForReview: ['reviewers'],
    onApprove: ['editors', 'admins'],
    onPublish: ['all']
  }
}
```

### Content Validation
```typescript
// lib/content-validation.ts
import { z } from 'zod'

export const pageValidation = z.object({
  title: z.object({
    pt: z.string().min(1, 'Título em português é obrigatório'),
    en: z.string().optional(),
    es: z.string().optional()
  }),
  slug: z.object({
    current: z.string().regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, 'Slug inválido')
  }),
  seo: z.object({
    metaTitle: z.object({
      pt: z.string().max(60, 'Meta título deve ter no máximo 60 caracteres')
    }),
    metaDescription: z.object({
      pt: z.string().max(160, 'Meta descrição deve ter no máximo 160 caracteres')
    })
  }).optional()
})
```

## Frontend Integration

### Sanity Client Setup
```typescript
// lib/sanity.ts
import { createClient } from '@sanity/client'
import imageUrlBuilder from '@sanity/image-url'

export const client = createClient({
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID!,
  dataset: process.env.NEXT_PUBLIC_SANITY_DATASET!,
  apiVersion: '2023-12-01',
  useCdn: true,
  token: process.env.SANITY_API_TOKEN,
})

const builder = imageUrlBuilder(client)

export function urlFor(source: any) {
  return builder.image(source)
}

// GROQ Queries
export const queries = {
  pages: `*[_type == "page" && status == "published"] | order(publishedAt desc)`,
  
  pageBySlug: `*[_type == "page" && slug.current == $slug && status == "published"][0] {
    ...,
    sections[] {
      ...,
      _type == "servicesSection" => {
        ...,
        services[]-> {
          name,
          slug,
          shortDescription,
          image,
          price
        }
      }
    }
  }`,
  
  services: `*[_type == "service"] | order(name.pt asc) {
    name,
    slug,
    shortDescription,
    image,
    category-> {
      name,
      slug
    }
  }`,
  
  serviceBySlug: `*[_type == "service" && slug.current == $slug][0] {
    ...,
    category-> {
      name,
      slug
    }
  }`
}
```

### Data Fetching Hooks
```typescript
// hooks/useSanityData.ts
import { useQuery } from '@tanstack/react-query'
import { client, queries } from '@/lib/sanity'

export function usePage(slug: string) {
  return useQuery({
    queryKey: ['page', slug],
    queryFn: () => client.fetch(queries.pageBySlug, { slug }),
    staleTime: 5 * 60 * 1000, // 5 minutes
  })
}

export function useServices() {
  return useQuery({
    queryKey: ['services'],
    queryFn: () => client.fetch(queries.services),
    staleTime: 10 * 60 * 1000, // 10 minutes
  })
}

// Static generation for pages
export async function getStaticPaths() {
  const pages = await client.fetch(`*[_type == "page" && status == "published"].slug.current`)
  
  return {
    paths: pages.map((slug: string) => ({ params: { slug } })),
    fallback: 'blocking'
  }
}

export async function getStaticProps({ params }: { params: { slug: string } }) {
  const page = await client.fetch(queries.pageBySlug, { slug: params.slug })
  
  if (!page) {
    return { notFound: true }
  }
  
  return {
    props: { page },
    revalidate: 60 // Revalidate every minute
  }
}
```

### Real-time Preview
```typescript
// lib/sanity-preview.ts
import { client } from './sanity'

export function usePreview(query: string, params: any) {
  const [data, setData] = useState(null)
  
  useEffect(() => {
    const subscription = client
      .listen(query, params, { visibility: 'query' })
      .subscribe((update) => {
        if (update.result) {
          setData(update.result)
        }
      })
    
    return () => subscription.unsubscribe()
  }, [query, params])
  
  return data
}
```

## Performance Optimization

### Image Optimization
```typescript
// components/SanityImage.tsx
import Image from 'next/image'
import { urlFor } from '@/lib/sanity'

interface SanityImageProps {
  image: any
  alt: string
  width?: number
  height?: number
  className?: string
  priority?: boolean
}

export function SanityImage({
  image,
  alt,
  width = 800,
  height = 600,
  className,
  priority = false
}: SanityImageProps) {
  if (!image) return null
  
  const imageUrl = urlFor(image)
    .width(width)
    .height(height)
    .quality(85)
    .format('webp')
    .url()
  
  return (
    <Image
      src={imageUrl}
      alt={alt || image.alt || ''}
      width={width}
      height={height}
      className={className}
      priority={priority}
      placeholder="blur"
      blurDataURL={urlFor(image).width(20).height(20).blur(50).url()}
    />
  )
}
```

### Content Caching
```typescript
// lib/cache.ts
import { unstable_cache } from 'next/cache'
import { client } from './sanity'

export const getCachedPage = unstable_cache(
  async (slug: string) => {
    return client.fetch(queries.pageBySlug, { slug })
  },
  ['page'],
  {
    revalidate: 60,
    tags: ['sanity']
  }
)

export const getCachedServices = unstable_cache(
  async () => {
    return client.fetch(queries.services)
  },
  ['services'],
  {
    revalidate: 300,
    tags: ['sanity', 'services']
  }
)
```

## Content Deployment Strategy

### Webhook Integration
```typescript
// pages/api/revalidate.ts
import { NextApiRequest, NextApiResponse } from 'next'
import { revalidateTag } from 'next/cache'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' })
  }
  
  const { type, slug } = req.body
  
  try {
    // Revalidate specific pages based on content type
    if (type === 'page') {
      await res.revalidate(`/${slug}`)
    } else if (type === 'service') {
      await res.revalidate('/servicos')
      await res.revalidate(`/servicos/${slug}`)
    }
    
    // Revalidate cache tags
    revalidateTag('sanity')
    
    return res.json({ revalidated: true })
  } catch (err) {
    return res.status(500).json({ message: 'Error revalidating' })
  }
}
```

## Multi-language Support

### Language Detection
```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server'
import { createIntlMiddleware } from 'next-intl/middleware'

const intlMiddleware = createIntlMiddleware({
  locales: ['pt', 'en', 'es'],
  defaultLocale: 'pt',
  localePrefix: 'as-needed'
})

export default function middleware(request: NextRequest) {
  return intlMiddleware(request)
}

export const config = {
  matcher: ['/((?!api|_next|.*\\..*).*)']
}
```

## Benefits of This CMS Strategy

1. **Developer Experience**: React-based studio with familiar tools
2. **Content Flexibility**: Modular content blocks for any page layout
3. **Performance**: Edge caching and optimized image delivery
4. **SEO Optimization**: Built-in meta fields and structured data
5. **Scalability**: Handles high traffic with global CDN
6. **Collaboration**: Real-time editing and approval workflows
7. **Multi-language**: Native internationalization support
8. **Cost Effective**: Pay-as-you-scale pricing model