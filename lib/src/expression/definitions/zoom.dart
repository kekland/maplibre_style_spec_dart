import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('ZoomExpression', rawName: 'zoom')
num zoomExpressionImpl(EvaluationContext context) => context.zoom;
