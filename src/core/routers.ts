import { RequestHandler, Router, RouterOptions } from 'express'
import { ParsedQs } from 'qs'

export interface ParamsDictionary {
  [key: string]: string
}

type RemoveTail<S extends string, Tail extends string> = S extends `${infer P}${Tail}` ? P : S
type GetRouteParameter<S extends string> = RemoveTail<
RemoveTail<RemoveTail<S, `/${string}`>, `-${string}`>,
    `.${string}`
>

export type RouteParameters<Route extends string> = string extends Route ? ParamsDictionary
  : Route extends `${string}(${string}` ? ParamsDictionary // TODO: handling for regex parameters
    : Route extends `${string}:${infer Rest}` ?
        & (
          GetRouteParameter<Rest> extends never ? ParamsDictionary
            : GetRouteParameter<Rest> extends `${infer ParamName}?` ? { [P in ParamName]?: string }
              : { [P in GetRouteParameter<Rest>]: string }
        )
        & (Rest extends `${GetRouteParameter<Rest>}${infer Next}` ? RouteParameters<Next> : unknown)
      : {}

interface CreateControllerP<
Route extends string,
P = RouteParameters<Route>,
ResBody = any,
ReqBody = any,
ReqQuery = ParsedQs,
LocalsObj extends Record<string, any> = Record<string, any>
> {
  method: 'get' | 'post' | 'put' | 'delete' | 'patch' | 'options' | 'head' | 'connect' | 'trace'
  path: Route
  handlers: Array<RequestHandler<P, ResBody, ReqBody, ReqQuery, LocalsObj>>
}

export const createController = <
Route extends string,
P = RouteParameters<Route>,
ResBody = any,
ReqBody = any,
ReqQuery = ParsedQs,
LocalsObj extends Record<string, any> = Record<string, any>
>({ method, path, handlers }: CreateControllerP<Route, P, ResBody, ReqBody, ReqQuery, LocalsObj>) => {
  return {
    method,
    path,
    handlers
  }
}

interface CustomRouterP {
  path: string
  controllers?: Array<ReturnType<typeof createController>>
  options?: RouterOptions
}

export const createRouter = ({ controllers = [], path, options }: CustomRouterP) => {
  const router = Router(options)

  controllers.forEach(controller => {
    router[controller.method](controller.path, ...controller.handlers)
  })

  return {
    path,
    module: router
  }
}

export type CustomRouter = ReturnType<typeof createRouter>
