class ExpressionAnnotation {
  const ExpressionAnnotation(
    this.name, {
    required this.rawName,
    this.customFromJson,
  });

  final String rawName;
  final String name;
  final Object Function(List<dynamic> args)? customFromJson;
}
