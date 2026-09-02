import { IsIn, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
export class IvAskDto {
  @IsString() @MinLength(2) @MaxLength(4000) message!: string;
  @IsOptional() @IsString() @IsIn(['ask','coach','analyze','idea','strategy','opportunity','learning','planning']) mode?: string;
}
