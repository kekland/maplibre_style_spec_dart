import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('Case', rawName: 'case')
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

@ExpressionAnnotation('Match', rawName: 'match')
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

@ExpressionAnnotation('Coalesce', rawName: 'coalesce')
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

@ExpressionAnnotation('Equals', rawName: '==')
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
    _collator;
  }

  return _left == _right;
}

@ExpressionAnnotation('NotEquals', rawName: '!=')
bool notEqualsExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> left,
  Expression<dynamic> right,
  Expression<Collator>? collator,
) {
  return !equalsExpressionImpl(context, left, right, collator);
}

@ExpressionAnnotation('GreaterThan', rawName: '>')
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

@ExpressionAnnotation('LessThan', rawName: '<')
bool lessThanExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> left,
  Expression<dynamic> right,
  Expression<Collator>? collator,
) {
  return !greaterThanExpressionImpl(context, left, right, collator) && !equalsExpressionImpl(context, left, right, collator);
}

@ExpressionAnnotation('GreaterThanOrEquals', rawName: '>=')
bool greaterThanOrEqualsExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> left,
  Expression<dynamic> right,
  Expression<Collator>? collator,
) {
  return greaterThanExpressionImpl(context, left, right, collator) || equalsExpressionImpl(context, left, right, collator);
}

@ExpressionAnnotation('LessThanOrEquals', rawName: '<=')
bool lessThanOrEqualsExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> left,
  Expression<dynamic> right,
  Expression<Collator>? collator,
) {
  return lessThanExpressionImpl(context, left, right, collator) || equalsExpressionImpl(context, left, right, collator);
}

@ExpressionAnnotation('All', rawName: 'all')
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

@ExpressionAnnotation('Any', rawName: 'any')
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

@ExpressionAnnotation('Not', rawName: '!')
bool notExpressionImpl(
  EvaluationContext context,
  Expression<bool> expression,
) {
  return !expression(context);
}

// TODO: Within