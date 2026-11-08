// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: ['@nuxtjs/tailwindcss', '@nuxtjs/supabase'],
  supabase: {
    // O controle de redirecionamento é gerenciado de forma explícita pelo middleware/auth.ts
    redirect: false,
    cookieOptions: {
      maxAge: 60 * 60 * 8,
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production'
    }
  },
  runtimeConfig: {
    public: {
      platformName: 'ImobiLit',
      clientBrand: 'LIT Capital',
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL || 'http://localhost:8000',
      supabaseUrl: process.env.SUPABASE_URL || 'https://kbnyesbkmablickwcwfw.supabase.co',
      supabaseKey: process.env.SUPABASE_KEY || ''
    }
  },
  app: {
    head: {
      title: 'ImobiLit by LIT Capital — Plataforma Multi-Serviços de Ativos & Capital',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1, viewport-fit=cover' },
        { name: 'theme-color', content: '#00384A' }
      ],
      link: [
        {
          rel: 'stylesheet',
          href: 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css'
        }
      ]
    }
  }
})
