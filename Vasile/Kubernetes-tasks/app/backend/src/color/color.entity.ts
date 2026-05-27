import { Column, Entity, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm'

@Entity()
export class ColorEntity {
  @PrimaryGeneratedColumn()
  id: number

  @Column()
  currentColor: string

  @CreateDateColumn()
  createdAt: Date
}