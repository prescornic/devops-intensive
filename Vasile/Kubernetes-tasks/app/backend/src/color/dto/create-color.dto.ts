import { IsString } from 'class-validator'

export class CreateColorDto {
  @IsString()
  currentColor: string
}