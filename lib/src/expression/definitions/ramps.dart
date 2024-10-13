import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('StepExpression', rawName: 'step')
T stepExpressionImpl<T>(
  EvaluationContext context,
  Expression<num> input,
  Expression<T> minOutput,
  List<(num, Expression<T>)> stops,
) {
  final _input = input(context);

  for (final (stop, output) in stops) {
    if (_input > stop) {
      return output(context);
    }
  }

  return minOutput(context);
}

@ExpressionAnnotation('InterpolateExpression', rawName: 'interpolate')
T interpolateExpressionImpl<T>(
  EvaluationContext context,
  Object options,
  Expression<num> input,
  List<(num, Expression<T>)> stops,
) {
  throw UnimplementedError();
}
