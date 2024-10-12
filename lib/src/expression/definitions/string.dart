import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('IsSupportedScript', rawName: 'is-supported-script')
bool isSupportedScriptExpressionImpl(
  EvaluationContext context,
  Expression<String> value,
) {
  final _value = value(context);

  // TODO: Implement
  _value;

  return true;
}

@ExpressionAnnotation('Upcase', rawName: 'upcase')
String upcaseExpressionImpl(
  EvaluationContext context,
  Expression<String> value,
) {
  final _value = value(context);
  return _value.toUpperCase();
}

@ExpressionAnnotation('Downcase', rawName: 'downcase')
String downcaseExpressionImpl(
  EvaluationContext context,
  Expression<String> value,
) {
  final _value = value(context);
  return _value.toLowerCase();
}

@ExpressionAnnotation('Concat', rawName: 'concat')
String concatExpressionImpl(
  EvaluationContext context,
  List<Expression<dynamic>> values,
) {
  return values.map((value) => value(context)).join();
}

@ExpressionAnnotation('ResolvedLocale', rawName: 'resolved-locale')
String resolvedLocaleExpressionImpl(
  EvaluationContext context,
  Expression<Collator> collator,
) {
  final _collator = collator(context);

  // TODO: System locale
  return _collator.locale?.languageCode ?? '';
}
