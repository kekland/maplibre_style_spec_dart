import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/gen/expressions.gen.dart';
import 'package:maplibre_style_spec/src/gen/style.gen.dart';

export 'evaluation.dart';

class _FormattedStringAdapterExpression extends Expression<Formatted> {
  const _FormattedStringAdapterExpression(this.string);

  final Expression<String> string;

  @override
  Formatted evaluate(EvaluationContext context) => Formatted.fromJson(string(context));
}

abstract class Expression<T> {
  const Expression({Type? type}) : type = type ?? T;

  factory Expression.fromJson(dynamic args) {
    if (T == Color && args is String) return Literal<Color>(value: Color.fromJson(args)) as Expression<T>;
    if (T == Color && args is List<num>) return Literal<Color>(value: Color.fromList(args)) as Expression<T>;

    if (T == Formatted && args is String) return Literal<Formatted>(value: Formatted.fromJson(args)) as Expression<T>;

    if (T == Padding && args is num) return Literal<Padding>(value: Padding.fromJson([args])) as Expression<T>;

    if (args is String) {
      if (isTypeEnum<T>()) {
        return Literal<T>(value: parseEnumJson<T>(args)) as Expression<T>;
      }

      return Literal<String>(value: args) as Expression<T>;
    }

    if (args == null) return Literal<Null>(value: null) as Expression<T>;
    if (args is num) return Literal<num>(value: args) as Expression<T>;
    if (args is bool) return Literal<bool>(value: args) as Expression<T>;
    if (args is Map<String, dynamic>) return Literal<Map<String, dynamic>>(value: args) as Expression<T>;

    // TODO: Improve this somehow
    if (T == Formatted) {
      try {
        return expressionFromJson<T>(args);
      } catch (e) {
        return _FormattedStringAdapterExpression(expressionFromJson<String>(args)) as Expression<T>;
      }
    }

    return expressionFromJson<T>(args);
  }

  final Type type;

  T evaluate(EvaluationContext context);
  T call(EvaluationContext context) => evaluate(context);
}
