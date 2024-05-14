import { DataSource } from 'typeorm'

export const createDbConn = () => new DataSource({
  type: 'postgres',
  host: 'localhost',
  port: 5432,
  username: 'postgres',
  database: 'inmo',
  entities: ['src/entity/*.js'],
  logging: true,
  synchronize: true
})
