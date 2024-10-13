import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('ToRgbaExpression', rawName: 'to-rgba')
List<num> toRgbaExpressionImpl(
  EvaluationContext context,
  Expression<Color> value,
) {
  final color = value(context);
  return [color.r * 255.0, color.g * 255.0, color.b * 255.0, color.a];
}

@ExpressionAnnotation('RgbExpression', rawName: 'rgb')
Color rgbExpressionImpl(
  EvaluationContext context,
  Expression<num> r,
  Expression<num> g,
  Expression<num> b,
) {
  return Color(
    r: r(context) / 255.0,
    g: g(context) / 255.0,
    b: b(context) / 255.0,
  );
}

@ExpressionAnnotation('RgbaExpression', rawName: 'rgba')
Color rgbaExpressionImpl(
  EvaluationContext context,
  Expression<num> r,
  Expression<num> g,
  Expression<num> b,
  Expression<num> a,
) {
  return Color(
    r: r(context) / 255.0,
    g: g(context) / 255.0,
    b: b(context) / 255.0,
    a: a(context).toDouble(),
  );
}
