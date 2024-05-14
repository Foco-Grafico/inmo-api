import { createApp, serveApp } from '@/core/app'

serveApp(createApp())
  .catch(console.error)
