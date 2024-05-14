import { createRouter } from '@/core/routers'
import multer from 'multer'
import { createDbConn } from 'app-data-source'
import { User } from '../../entity/user.entity'

const storage = multer.memoryStorage()

const upload = multer({ storage })

const authRouter = createRouter({
  path: '/auth'
})

authRouter.module.get('/login', upload.none(), (req, res) => {
  const db = createDbConn()

  db.getRepository(User).count().then(count => {
    res.json({ count })
  })
    .catch(console.error)
})

export default authRouter
