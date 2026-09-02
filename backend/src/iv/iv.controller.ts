import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { IvService } from './iv.service';
import { IvAskDto } from './dto/iv-ask.dto';

@Controller('iv')
@UseGuards(AuthGuard)
export class IvController {
  constructor(private readonly iv: IvService) {}
  @Post('ask') ask(@Body() dto: IvAskDto, @Req() req: any) {
    return this.iv.respond({ ...dto, userId: req.user.userId } as any);
  }
}
