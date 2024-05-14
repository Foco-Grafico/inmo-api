import { createApp, serveApp } from '@/core/app'
import 'reflect-metadata'

serveApp(createApp())
  .catch(console.error)
