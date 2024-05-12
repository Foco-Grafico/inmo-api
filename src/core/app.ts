import express, { Express } from 'express'
import cors from 'cors'

export const createApp = () => {
  const app = configApp(express())

  return app
}

const configApp = (app: Express) => {
  app.use(express.json())
  app.use(cors({
    origin: '*',
    methods: '*',
    allowedHeaders: '*',
    credentials: true
  }))

  return app
}

export const serveApp = (app: Express) => {
  const port = process.env.PORT ?? 3000

  app.listen(port, () => {
    console.log(`Server running on port ${port}`)
  })
}
