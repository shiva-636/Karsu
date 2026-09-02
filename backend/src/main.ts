import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: false });
  app.setGlobalPrefix('api');
  app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: false, forbidNonWhitelisted: false }));
  const origins = (process.env.CORS_ORIGIN ?? '').split(',').map((v: string) => v.trim()).filter(Boolean);
  app.enableCors({ origin: origins.length ? origins : true, credentials: true, methods: ['GET','HEAD','POST','PUT','PATCH','DELETE','OPTIONS'] });
  await app.listen(Number(process.env.PORT ?? 3000), '0.0.0.0');
}
bootstrap();
