class Locale {
  const Locale({
    required this.languageCode,
    this.scriptCode,
  });

  final String languageCode;
  final String? scriptCode;
}
