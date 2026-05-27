import { Controller, Get } from '@nestjs/common'

@Controller('api/health')
export class HealthController {
  @Get()
  health() {
    return {
      status: 'ok from Back, healthy ate lots of veggies',
    }
  }
}