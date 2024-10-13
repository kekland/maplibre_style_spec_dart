import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('PropertiesExpression', rawName: 'properties')
Map<String, dynamic> propertiesExpressionImpl(EvaluationContext context) {
  return context.properties;
}

@ExpressionAnnotation('FeatureStateExpression', rawName: 'feature-state')
dynamic featureStateExpressionImpl(
  EvaluationContext context,
  Expression<String> key,
) {
  return context.getFeatureState(key(context));
}

@ExpressionAnnotation('GeometryTypeExpression', rawName: 'geometry-type')
String geometryTypeExpressionImpl(EvaluationContext context) {
  return context.geometryType;
}

@ExpressionAnnotation('IdExpression', rawName: 'id')
String? idExpressionImpl(EvaluationContext context) {
  return context.id;
}

@ExpressionAnnotation('LineProgressExpression', rawName: 'line-progress')
double lineProgressExpressionImpl(EvaluationContext context) {
  return context.lineProgress ?? 0.0;
}

@ExpressionAnnotation('AccumulatedExpression', rawName: 'accumulated')
double accumulatedExpressionImpl(
  EvaluationContext context,
  Expression<String> key,
) {
  // TODO
  return 0.0;
}

