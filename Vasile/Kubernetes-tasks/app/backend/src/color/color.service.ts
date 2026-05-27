import { Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { ColorEntity } from './color.entity'
import { CreateColorDto } from './dto/create-color.dto'

@Injectable()
export class ColorService {
  constructor(
    @InjectRepository(ColorEntity)
    private readonly colorRepository: Repository<ColorEntity>,
  ) {}

  async create(createColorDto: CreateColorDto) {
    const color = this.colorRepository.create(createColorDto)

    return this.colorRepository.save(color)
  }

  async getLatest() {
    return this.colorRepository.find({
      order: {
        createdAt: 'DESC',
      },
      take: 1,
    })
  }
}