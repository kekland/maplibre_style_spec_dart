import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('Literal', rawName: 'literal')
T literalExpressionImpl<T>(EvaluationContext context, T value) => value;

@ExpressionAnnotation('CollatorExpression', rawName: 'collator')
Collator collatorExpressionImpl(
  EvaluationContext context,
  ({
    Expression<bool>? caseSensitive,
    Expression<bool>? diacriticSensitive,
    Expression<String>? locale,
  }) object,
) {
  final _locale = object.locale?.evaluate(context);

  return Collator(
    caseSensitive: object.caseSensitive?.evaluate(context) ?? false,
    diacriticSensitive: object.diacriticSensitive?.evaluate(context) ?? false,
    locale: _locale != null ? Locale(languageCode: _locale) : null,
  );
}

// TODO: Format

@ExpressionAnnotation('ImageExpression', rawName: 'image')
ResolvedImage imageExpressionImpl(
  EvaluationContext context,
  Expression<String> value,
) {
  final _value = value(context);

  // TODO
  _value;

  return ResolvedImage();
}

@ExpressionAnnotation('NumberFormat', rawName: 'number-format')
String numberFormatExpressionImpl(
  EvaluationContext context,
  Expression<num> number,
  ({
    Expression<String>? locale,
    Expression<String>? currency,
    Expression<int>? minFractionDigits,
    Expression<int>? maxFractionDigits,
  }) options,
) {
  final _number = number(context);
  final _locale = options.locale?.evaluate(context);
  final _currency = options.currency?.evaluate(context);
  final _minFractionDigits = options.minFractionDigits?.evaluate(context);
  final _maxFractionDigits = options.maxFractionDigits?.evaluate(context);

  // TODO: Intl
  _locale;
  _currency;
  _minFractionDigits;
  _maxFractionDigits;

  return _number.toString();
}

// ------------------------------------
// Assertions
// ------------------------------------

@ExpressionAnnotation('ArrayAssertion', rawName: 'array')
List arrayAssertionExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> value,
  Type? childType,
  int? childCount,
) {
  final _value = value(context);

  if (_value is! List) {
    throw Exception('Expected an array, got ${_value.runtimeType}');
  }

  if (childType != null) {
    for (final item in _value) {
      if (item.runtimeType != childType) {
        throw Exception('Expected an array of $childType, got ${item.runtimeType} instead.');
      }
    }
  }

  if (childCount != null) {
    if (_value.length != childCount) {
      throw Exception('Expected an array of length $childCount, got ${_value.length}');
    }
  }

  return _value;
}

T _assertionExpressionImpl<T>(
  EvaluationContext context,
  List<Expression<dynamic>> args,
) {
  for (var i = 0; i < args.length; i++) {
    final value = args[i](context);

    if (value.runtimeType == T) {
      return value;
    }

    if (i == args.length - 1) {
      throw Exception('Expected value to be of type $T, but found ${value.runtimeType} instead.');
    }
  }

  throw Exception('Assertion failed.');
}

@ExpressionAnnotation('BooleanAssertion', rawName: 'boolean')
bool booleanAssertionExpressionImpl(
  EvaluationContext context,
  List<Expression<dynamic>> args,
) {
  return _assertionExpressionImpl<bool>(context, args);
}

@ExpressionAnnotation('NumberAssertion', rawName: 'number')
num numberAssertionExpressionImpl(
  EvaluationContext context,
  List<Expression<dynamic>> args,
) {
  return _assertionExpressionImpl<num>(context, args);
}

@ExpressionAnnotation('StringAssertion', rawName: 'string')
String stringAssertionExpressionImpl(
  EvaluationContext context,
  List<Expression<dynamic>> args,
) {
  return _assertionExpressionImpl<String>(context, args);
}

@ExpressionAnnotation('ObjectAssertion', rawName: 'object')
Map<String, dynamic> objectAssertionExpressionImpl(
  EvaluationContext context,
  List<Expression<dynamic>> args,
) {
  return _assertionExpressionImpl<Map<String, dynamic>>(context, args);
}

String _typeOf(dynamic value) {
  if (value == null) return 'null';
  if (value is num) return 'number';
  if (value is String) return 'string';
  if (value is bool) return 'boolean';
  if (value is Map<String, dynamic>) return 'object';
  if (value is List) {
    if (value.isEmpty) return 'array';

    final childTypes = value.map(_typeOf).toSet();
    final childType = childTypes.length == 1 ? childTypes.first : 'value';

    return 'array<$childType, ${value.length}>';
  }

  throw 'Unsupported type: ${value.runtimeType}';
}

@ExpressionAnnotation('TypeOf', rawName: 'typeof')
String typeOfExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> value,
) {
  return _typeOf(value(context));
}

// ------------------------------------
// Coercion
// ------------------------------------

@ExpressionAnnotation('ToString', rawName: 'to-string')
String toStringExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> value,
) {
  final _value = value(context);

  if (_value == null) return '';
  if (_value is bool) {
    return _value ? 'true' : 'false';
  }
  if (_value is num) {
    return _value.toString();
  }
  if (_value is Color) {
    final _r = (_value.r * 255).round();
    final _g = (_value.g * 255).round();
    final _b = (_value.b * 255).round();
    final _a = _value.a;

    return 'rgba($_r, $_g, $_b, $_a)';
  }

  return _value.toString();
}

@ExpressionAnnotation('ToNumber', rawName: 'to-number')
num toNumberExpressionImpl(
  EvaluationContext context,
  List<Expression<dynamic>> values,
) {
  for (final value in values) {
    final _value = value(context);

    if (_value is num) return _value;
    if (_value is bool) return _value ? 1 : 0;
    if (_value is String) {
      final _number = num.tryParse(_value);

      if (_number != null) return _number;
    }
  }

  throw Exception('Could not convert any of the values to a number.');
}

@ExpressionAnnotation('ToBoolean', rawName: 'to-boolean')
bool toBooleanExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> value,
) {
  final _value = value(context);

  if (_value == '' || _value == 0 || _value == false || _value == null || (_value is num && _value.isNaN)) {
    return false;
  }

  return true;
}

@ExpressionAnnotation('ToColor', rawName: 'to-color')
Color toColorExpressionImpl(
  EvaluationContext context,
  List<Expression<dynamic>> values,
) {
  for (final value in values) {
    final _value = value(context);

    if (_value is Color) return _value;
    if (_value is List) {
      return Color.fromList(_value.cast<num>());
    }
    if (_value is String) {
      return Color.fromJson(_value);
    }
  }

  throw Exception('Could not convert any of the values to a color.');
}
