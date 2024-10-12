import 'dart:math' as math;

import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('Ln2', rawName: 'ln2')
num ln2ExpressionImpl(EvaluationContext context) => math.ln2;

@ExpressionAnnotation('Pi', rawName: 'pi')
num piExpressionImpl(EvaluationContext context) => math.pi;

@ExpressionAnnotation('E', rawName: 'e')
num eExpressionImpl(EvaluationContext context) => math.e;

@ExpressionAnnotation('Add', rawName: '+')
num addExpressionImpl(EvaluationContext context, List<Expression<num>> args) {
  return args.fold(0, (a, b) => a + b(context));
}

@ExpressionAnnotation('Multiply', rawName: '*')
num multiplyExpressionImpl(EvaluationContext context, List<Expression<num>> args) {
  return args.fold(1, (a, b) => a * b(context));
}

@ExpressionAnnotation('Minus', rawName: '-')
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

@ExpressionAnnotation('Divide', rawName: '/')
num divideExpressionImpl(
  EvaluationContext context,
  Expression<num> left,
  Expression<num> right,
) {
  return left(context) / right(context);
}

@ExpressionAnnotation('Mod', rawName: '%')
num modExpressionImpl(
  EvaluationContext context,
  Expression<num> left,
  Expression<num> right,
) {
  return left(context) % right(context);
}

@ExpressionAnnotation('Pow', rawName: '^')
num powExpressionImpl(
  EvaluationContext context,
  Expression<num> base,
  Expression<num> exponent,
) {
  return math.pow(base(context), exponent(context));
}

@ExpressionAnnotation('Sqrt', rawName: 'sqrt')
num sqrtExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.sqrt(value(context));
}

@ExpressionAnnotation('Log10', rawName: 'log10')
num log10ExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.log(value(context)) / math.ln10;
}

@ExpressionAnnotation('Ln', rawName: 'ln')
num lnExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.log(value(context));
}

@ExpressionAnnotation('Log2', rawName: 'log2')
num log2ExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.log(value(context)) / math.ln2;
}

@ExpressionAnnotation('Sin', rawName: 'sin')
num sinExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.sin(value(context));
}

@ExpressionAnnotation('Cos', rawName: 'cos')
num cosExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.cos(value(context));
}

@ExpressionAnnotation('Tan', rawName: 'tan')
num tanExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.tan(value(context));
}

@ExpressionAnnotation('Asin', rawName: 'asin')
num asinExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.asin(value(context));
}

@ExpressionAnnotation('Acos', rawName: 'acos')
num acosExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.acos(value(context));
}

@ExpressionAnnotation('Atan', rawName: 'atan')
num atanExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return math.atan(value(context));
}

@ExpressionAnnotation('Min', rawName: 'min')
num minExpressionImpl(
  EvaluationContext context,
  List<Expression<num>> args,
) {
  return args.map((e) => e(context)).reduce(math.min);
}

@ExpressionAnnotation('Max', rawName: 'max')
num maxExpressionImpl(
  EvaluationContext context,
  List<Expression<num>> args,
) {
  return args.map((e) => e(context)).reduce(math.max);
}

@ExpressionAnnotation('Abs', rawName: 'abs')
num absExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return value(context).abs();
}

@ExpressionAnnotation('Round', rawName: 'round')
num roundExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return value(context).round();
}

@ExpressionAnnotation('Ceil', rawName: 'ceil')
num ceilExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return value(context).ceilToDouble();
}

@ExpressionAnnotation('Floor', rawName: 'floor')
num floorExpressionImpl(
  EvaluationContext context,
  Expression<num> value,
) {
  return value(context).floorToDouble();
}

// TODO: Distance