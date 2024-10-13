import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('CaseExpression', rawName: 'case')
T caseExpressionImpl<T>(
  EvaluationContext context,
  List<(Expression<bool> test, Expression<T> output)> branches,
  Expression<T> fallback,
) {
  for (final (test, output) in branches) {
    if (test(context)) {
      return output(context);
    }
  }

  return fallback(context);
}

@ExpressionAnnotation('MatchExpression', rawName: 'match')
T matchExpressionImpl<T>(
  EvaluationContext context,
  Expression<dynamic> input,
  List<(dynamic test, Expression<T> output)> branches,
  Expression<T> fallback,
) {
  final inputValue = input(context);

  for (final (test, output) in branches) {
    if (test is List) {
      if (test.contains(inputValue)) {
        return output(context);
      }
    } else if (test == inputValue) {
      return output(context);
    }
  }

  return fallback(context);
}

@ExpressionAnnotation('CoalesceExpression', rawName: 'coalesce')
T coalesceExpressionImpl<T>(
  EvaluationContext context,
  List<Expression<T>> expressions,
) {
  for (final expression in expressions) {
    final value = expression(context);

    if (value != null) {
      return value;
    }
  }
  
  throw Exception('All expressions returned null');
}

@ExpressionAnnotation('EqualsExpression', rawName: '==')
bool equalsExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> left,
  Expression<dynamic> right,
  Expression<Collator>? collator,
) {
  final _left = left(context);
  final _right = right(context);
  final _collator = collator?.evaluate(context);

  if (_left.runtimeType != _right.runtimeType) {
    throw Exception('Cannot compare different types: ${_left.runtimeType} and ${_right.runtimeType}');
  }

  if (_left is String && _right is String) {
    // TODO: Collator

    // Collation probably will not exist in Dart for a while.
    // Consider using icu4c bindings.
    _collator;
  }

  return _left == _right;
}

@ExpressionAnnotation('NotEqualsExpression', rawName: '!=')
bool notEqualsExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> left,
  Expression<dynamic> right,
  Expression<Collator>? collator,
) {
  return !equalsExpressionImpl(context, left, right, collator);
}

@ExpressionAnnotation('GreaterThanExpression', rawName: '>')
bool greaterThanExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> left,
  Expression<dynamic> right,
  Expression<Collator>? collator,
) {
  final _left = left(context);
  final _right = right(context);
  final _collator = collator?.evaluate(context);

  if (_left.runtimeType != _right.runtimeType) {
    throw Exception('Cannot compare different types: ${_left.runtimeType} and ${_right.runtimeType}');
  }

  if (_left is String && _right is String) {
    // TODO: Collator
    _collator;
    return _left.compareTo(_right) > 0;
  }

  if (_left is num && _right is num) {
    return _left > _right;
  }

  throw Exception('Unsupported types for "greater than" operator: ${_left.runtimeType} and ${_right.runtimeType}');
}

@ExpressionAnnotation('LessThanExpression', rawName: '<')
bool lessThanExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> left,
  Expression<dynamic> right,
  Expression<Collator>? collator,
) {
  return !greaterThanExpressionImpl(context, left, right, collator) && !equalsExpressionImpl(context, left, right, collator);
}

@ExpressionAnnotation('GreaterThanOrEqualsExpression', rawName: '>=')
bool greaterThanOrEqualsExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> left,
  Expression<dynamic> right,
  Expression<Collator>? collator,
) {
  return greaterThanExpressionImpl(context, left, right, collator) || equalsExpressionImpl(context, left, right, collator);
}

@ExpressionAnnotation('LessThanOrEqualsExpression', rawName: '<=')
bool lessThanOrEqualsExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> left,
  Expression<dynamic> right,
  Expression<Collator>? collator,
) {
  return lessThanExpressionImpl(context, left, right, collator) || equalsExpressionImpl(context, left, right, collator);
}

@ExpressionAnnotation('AllExpression', rawName: 'all')
bool allExpressionImpl(
  EvaluationContext context,
  List<Expression<bool>> expressions,
) {
  for (final expression in expressions) {
    if (!expression(context)) {
      return false;
    }
  }

  return true;
}

@ExpressionAnnotation('AnyExpression', rawName: 'any')
bool anyExpressionImpl(
  EvaluationContext context,
  List<Expression<bool>> expressions,
) {
  for (final expression in expressions) {
    if (expression(context)) {
      return true;
    }
  }

  return false;
}

@ExpressionAnnotation('NotExpression', rawName: '!')
bool notExpressionImpl(
  EvaluationContext context,
  Expression<bool> expression,
) {
  return !expression(context);
}

// TODO: Within