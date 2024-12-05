import 'package:equatable/equatable.dart';
import 'package:maplibre_style_spec/src/types/locale.dart';

class Collator with EquatableMixin {
  const Collator({
    this.caseSensitive = false,
    this.diacriticSensitive = false,
    this.locale,
  });

  final bool caseSensitive;
  final bool diacriticSensitive;
  final Locale? locale;
  
  @override
  List<Object?> get props => [caseSensitive, diacriticSensitive, locale];

  @override
  bool get stringify => true;
}
