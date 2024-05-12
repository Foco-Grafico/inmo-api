import { createController, createRouter } from '@/core/routers'
import multer from 'multer'

const storage = multer.memoryStorage()

const upload = multer({ storage })

const middleware = upload.none()

const authRouter = createRouter({
  path: '/auth',
  controllers: [
    createController({
      method: 'get',
      path: '/login',
      handlers: [
        (req, res) => res.send('Login')
      ]
    })
  ]
})

export default authRouter
