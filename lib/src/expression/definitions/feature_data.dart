import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('Properties', rawName: 'properties')
Map<String, dynamic> propertiesExpressionImpl(EvaluationContext context) {
  return context.properties;
}

@ExpressionAnnotation('FeatureState', rawName: 'feature-state')
dynamic featureStateExpressionImpl(
  EvaluationContext context,
  Expression<String> key,
) {
  return context.getFeatureState(key(context));
}

@ExpressionAnnotation('GeometryType', rawName: 'geometry-type')
String geometryTypeExpressionImpl(EvaluationContext context) {
  return context.geometryType;
}

@ExpressionAnnotation('Id', rawName: 'id')
String? idExpressionImpl(EvaluationContext context) {
  return context.id;
}

@ExpressionAnnotation('LineProgress', rawName: 'line-progress')
double lineProgressExpressionImpl(EvaluationContext context) {
  return context.lineProgress ?? 0.0;
}

@ExpressionAnnotation('Accumulated', rawName: 'accumulated')
double accumulatedExpressionImpl(
  EvaluationContext context,
  Expression<String> key,
) {
  // TODO
  return 0.0;
}

