import 'package:maplibre_style_spec/src/types/locale.dart';

class Collator {
  const Collator({
    this.caseSensitive = false,
    this.diacriticSensitive = false,
    this.locale,
  });

  final bool caseSensitive;
  final bool diacriticSensitive;
  final Locale? locale;
}
