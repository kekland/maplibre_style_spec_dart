import 'dart:developer';
import 'dart:math' as math;

import 'package:geojson_vi/geojson_vi.dart';
import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('Ln2Expression', rawName: 'ln2')
num ln2ExpressionImpl(EvaluationContext context) => math.ln2;

@ExpressionAnnotation('PiExpression', rawName: 'pi')
num piExpressionImpl(EvaluationContext context) => math.pi;

@ExpressionAnnotation('EExpression', rawName: 'e')
num eExpressionImpl(EvaluationContext context) => math.e;

@ExpressionAnnotation('AddExpression', rawName: '+')
num addExpressionImpl(EvaluationContext context, List<Expression<num>> args) {
  return args.fold(0, (a, b) => a + b(context));
}

@ExpressionAnnotation('MultiplyExpression', rawName: '*')
num multiplyExpressionImpl(EvaluationContext context, List<Expression<num>> args) {
  return args.fold(1, (a, b) => a * b(context));
}

@ExpressionAnnotation('MinusExpression', rawName: '-')
num minusExpressionImpl(
  EvaluationContext context,
  Expression<num> left,
  Expression<num>? right,
) {
  if (right == null) {
    return -left(context);
  }

  return left(context) - right(context);
}

@ExpressionAnnotation('DivideExpression', rawName: '/')
num divideExpressionImpl(
  EvaluationContext context,
  Expression<num> left,
  Expression<num> right,
) {
  return left(context) / right(context);
}

@ExpressionAnnotation('ModExpression', rawName: '%')
num modExpressionImpl(
  EvaluationContext context,
  Expression<num> left,
  Expression<num> right,
) {
  return left(context) % right(context);
}

@ExpressionAnnotation('PowExpression', rawName: '^')
num powExpressionImpl(
  EvaluationContext context,
  Expression<num> base,
  Expression<num> exponent,
) {
  return math.pow(base(context), exponent(context));
}

@ExpressionAnnotation('SqrtExpression', rawName: 'sqrt')
num sqrtExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.sqrt(value(context));
}

@ExpressionAnnotation('Log10Expression', rawName: 'log10')
num log10ExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.log(value(context)) / math.ln10;
}

@ExpressionAnnotation('LnExpression', rawName: 'ln')
num lnExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.log(value(context));
}

@ExpressionAnnotation('Log2Expression', rawName: 'log2')
num log2ExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.log(value(context)) / math.ln2;
}

@ExpressionAnnotation('SinExpression', rawName: 'sin')
num sinExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.sin(value(context));
}

@ExpressionAnnotation('CosExpression', rawName: 'cos')
num cosExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.cos(value(context));
}

@ExpressionAnnotation('TanExpression', rawName: 'tan')
num tanExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.tan(value(context));
}

@ExpressionAnnotation('AsinExpression', rawName: 'asin')
num asinExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.asin(value(context));
}

@ExpressionAnnotation('AcosExpression', rawName: 'acos')
num acosExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.acos(value(context));
}

@ExpressionAnnotation('AtanExpression', rawName: 'atan')
num atanExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.atan(value(context));
}

@ExpressionAnnotation('MinExpression', rawName: 'min')
num minExpressionImpl(
  EvaluationContext context,
  List<Expression<num>> args,
) {
  return args.map((e) => e(context)).reduce(math.min);
}

@ExpressionAnnotation('MaxExpression', rawName: 'max')
num maxExpressionImpl(
  EvaluationContext context,
  List<Expression<num>> args,
) {
  return args.map((e) => e(context)).reduce(math.max);
}

@ExpressionAnnotation('AbsExpression', rawName: 'abs')
num absExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return value(context).abs();
}

@ExpressionAnnotation('RoundExpression', rawName: 'round')
num roundExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return value(context).round();
}

@ExpressionAnnotation('CeilExpression', rawName: 'ceil')
num ceilExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return value(context).ceilToDouble();
}

@ExpressionAnnotation('FloorExpression', rawName: 'floor')
num floorExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return value(context).floorToDouble();
}
