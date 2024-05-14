import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm'

@Entity({
  name: 'users',
  schema: 'auth'
})
export class User {
  @PrimaryGeneratedColumn()
    id!: number

  @Column()
    firstName!: string

  @Column()
    lastName!: string
}
