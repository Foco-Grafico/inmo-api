import { Pool } from '@neondatabase/serverless' // Import SQLWrapper
import { drizzle } from 'drizzle-orm/neon-http'

const pool = new Pool({ connectionString: process.env.PUBLIC_RIZZLE_DATABASE_URL ?? '' })
export const db = drizzle(pool as any)
