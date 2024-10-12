import 'package:maplibre_style_spec/src/expression/expression.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('Let', rawName: 'let')
T letExpressionImpl<T>(
  EvaluationContext context,
  List<(String, Expression<Object?>)> bindings,
  Expression<T> child,
) {
  final newContext = context.extendWith(
    bindings: {
      for (final binding in bindings) binding.$1: binding.$2,
    },
  );

  return child.evaluate(newContext);
}

@ExpressionAnnotation('Var', rawName: 'var')
T varExpressionImpl<T>(
  EvaluationContext context,
  String name,
) {
  final binding = context.getBinding(name);

  if (binding == null) {
    throw Exception('Variable $name is not defined');
  }

  if (binding.type != T) {
    throw Exception('Variable $name has type ${binding.type} instead of $T');
  }

  return binding(context) as T;
}
