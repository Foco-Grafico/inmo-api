import { createRouter } from '@/core/routers'
import { db } from '@/services/conn'
import { sql } from 'drizzle-orm'
import multer from 'multer'

const storage = multer.memoryStorage()

const upload = multer({ storage })

const authRouter = createRouter({
  path: '/auth'
})

const count = db.execute(sql`select * from auth.users` as any) // Convert the expression to 'unknown' before assigning it to 'count'
console.log(count)

const COUNT_TABLES = db.execute(sql`SELECT * FROM information_schema.tables WHERE table_schema = 'auth'`)
console.log(COUNT_TABLES)

authRouter.module.get('/login', upload.none(), (req, res) => {
  res.send('Login')
})

export default authRouter
