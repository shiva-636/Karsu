import { Body, Controller, Delete, Get, Param, Post, Put, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { IntelligenceService } from './intelligence.service';

@Controller('intelligence')
@UseGuards(AuthGuard)
export class IntelligenceController {
  constructor(private readonly service: IntelligenceService) {}
  @Get() findAll(@Req() req: any) { return this.service.findAll(req.user.userId); }
  @Get(':id') findOne(@Param('id') id: string, @Req() req: any) { return this.service.findOne(id, req.user.userId); }
  @Post() create(@Body() dto: Record<string, unknown>, @Req() req: any) { return this.service.create(req.user.userId, dto); }
  @Put(':id') update(@Param('id') id: string, @Body() dto: Record<string, unknown>, @Req() req: any) { return this.service.update(id, req.user.userId, dto); }
  @Delete(':id') remove(@Param('id') id: string, @Req() req: any) { return this.service.remove(id, req.user.userId); }
}
