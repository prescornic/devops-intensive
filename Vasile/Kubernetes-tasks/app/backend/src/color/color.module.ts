import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { ColorEntity } from './color.entity'
import { ColorController } from './color.controller'
import { ColorService } from './color.service'

@Module({
  imports: [TypeOrmModule.forFeature([ColorEntity])],
  controllers: [ColorController],
  providers: [ColorService],
})
export class ColorModule {}