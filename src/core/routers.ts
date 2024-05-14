import { Router, RouterOptions } from 'express'

interface CustomRouterP {
  path: string
  options?: RouterOptions
}

export const createRouter = ({ path, options }: CustomRouterP) => {
  const router = Router(options)

  return {
    path,
    module: router
  }
}

export type CustomRouter = ReturnType<typeof createRouter>
