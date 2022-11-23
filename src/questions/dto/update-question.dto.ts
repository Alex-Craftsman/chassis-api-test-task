import { PartialType } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsOptional,
  MinLength,
  IsNumber,
  IsUUID,
  Validate,
} from 'class-validator';
import { EntityExistsConstraint } from 'src/validators/entity-exists.validator';

import { CreateQuestionDto } from './create-question.dto';

export class UpdateQuestionDto extends PartialType(CreateQuestionDto) {
  @IsOptional()
  @MinLength(3)
  @Transform(({ value }) => value.trim())
  name?: string;

  @IsOptional()
  @IsUUID()
  @Validate(EntityExistsConstraint, ['Section'], {
    message: 'Section Not Found',
  })
  sectionId?: string;

  @IsOptional()
  @IsNumber()
  orderBy?: number;
}
