import express, { Express } from 'express'
import cors from 'cors'
import { findAllModulesPaths, importAllModules } from './find-modules'
import { resolve } from 'path'
import { CustomRouter } from './routers'

export const createApp = async () => {
  const app = await configApp(express())

  return app
}

const configApp = async (app: Express) => {
  app.use(express.json())
  app.use(cors({
    origin: '*',
    methods: '*',
    allowedHeaders: '*',
    credentials: true
  }))

  const routers = await importAllModules(findAllModulesPaths(resolve(__dirname, '../app'))) as CustomRouter[]

  routers.forEach(router => {
    console.log(router.module)
    app.use(router.path, router.module)
  })

  return app
}

export const serveApp = async (app: Promise<Express>) => {
  const port = process.env.PORT ?? 3000

  const resolvedApp = await app

  resolvedApp.listen(port, () => {
    console.log(`Server running on port ${port}`)
  })
}
