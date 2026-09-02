import { Body, Controller, Get, Put, Req, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
  constructor(private readonly service: UsersService) {}
  @Get('me') async me(@Req() req: any) { const user = await this.service.findOne(req.user.userId); return this.service.publicProfile(user); }
  @Put('me') update(@Req() req: any, @Body() dto: Record<string, unknown>) { return this.service.update(req.user.userId, dto); }
}
