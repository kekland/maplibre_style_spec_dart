import 'package:maplibre_style_spec/src/_src.dart';

export 'evaluation.dart';

class _FormattedStringAdapterExpression extends Expression<Formatted> {
  const _FormattedStringAdapterExpression(this.string);

  final Expression<String> string;

  @override
  Formatted evaluate(EvaluationContext context) => Formatted.fromJson(string(context));
}

bool _isJsonListWithElementType<T>(List<dynamic> json) {
  for (final element in json) {
    if (element is! T) return false;
  }

  return true;
}

abstract class Expression<T> {
  const Expression({Type? type}) : type = type ?? T;

  factory Expression.fromJson(dynamic args) {
    // TODO: Literal parsing can be moved to Literal class, and by using a custom factory constructor there.

    // [Color] literals
    if (T == Color) {
      if (args is String) {
        return LiteralExpression<Color>(value: Color.fromJson(args)) as Expression<T>;
      } else if (args is List && _isJsonListWithElementType<num>(args)) {
        return LiteralExpression<Color>(value: Color.fromList(args as List<num>)) as Expression<T>;
      }
    }

    // [Formatted] literals
    if (T == Formatted) {
      if (args is String) {
        return LiteralExpression<Formatted>(value: Formatted.fromJson(args)) as Expression<T>;
      }

      // TODO: Improve this somehow
      try {
        return expressionFromJson<T>(args);
      } catch (e) {
        return _FormattedStringAdapterExpression(expressionFromJson<String>(args)) as Expression<T>;
      }
    }

    // [Padding] literals
    if (T == Padding && args is num) {
      return LiteralExpression<Padding>(value: Padding.fromJson([args])) as Expression<T>;
    }

    // [Enum] or [String] literals
    if (args is String) {
      if (isTypeEnum<T>()) {
        return LiteralExpression<T>(value: parseEnumJson<T>(args)) as Expression<T>;
      }

      return LiteralExpression<String>(value: args) as Expression<T>;
    }

    // Other common literals
    if (args == null) return LiteralExpression<Null>(value: null) as Expression<T>;
    if (args is num) return LiteralExpression<num>(value: args) as Expression<T>;
    if (args is bool) return LiteralExpression<bool>(value: args) as Expression<T>;
    if (args is Map<String, dynamic>) return LiteralExpression<Map<String, dynamic>>(value: args) as Expression<T>;

    return expressionFromJson<T>(args);
  }

  final Type type;

  T evaluate(EvaluationContext context);
  T call(EvaluationContext context) => evaluate(context);
}
