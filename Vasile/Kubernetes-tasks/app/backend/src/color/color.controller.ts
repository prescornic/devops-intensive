import { Body, Controller, Get, Post } from '@nestjs/common'
import { ColorService } from './color.service'
import { CreateColorDto } from './dto/create-color.dto'

@Controller('api/colors')
export class ColorController {
  constructor(private readonly colorService: ColorService) {}

  @Post()
  create(@Body() createColorDto: CreateColorDto) {
    return this.colorService.create(createColorDto)
  }

  @Get('latest')
  getLatest() {
    return this.colorService.getLatest()
  }
}