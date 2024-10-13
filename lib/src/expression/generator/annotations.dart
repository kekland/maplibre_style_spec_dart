import 'package:maplibre_style_spec/src/_src.dart';

class ExpressionAnnotation {
  const ExpressionAnnotation(
    this.name, {
    required this.rawName,
    this.customFromJson,
  });

  final String rawName;
  final String name;
  final Expression Function(List<dynamic> args)? customFromJson;
}
