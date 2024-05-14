import { createRouter } from '@/core/routers'
import multer from 'multer'

const storage = multer.memoryStorage()

const upload = multer({ storage })

const authRouter = createRouter({
  path: '/auth'
})

authRouter.module.get('/login', upload.none(), (req, res) => {
  res.send('Login')
})

export default authRouter
