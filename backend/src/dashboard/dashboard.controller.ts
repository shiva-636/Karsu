import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { DashboardService } from './dashboard.service';

@Controller('dashboard')
@UseGuards(AuthGuard)
export class DashboardController {
  constructor(private readonly service: DashboardService) {}
  @Get('snapshot') snapshot(@Req() req: any) { return this.service.snapshot(req.user.userId); }
}
