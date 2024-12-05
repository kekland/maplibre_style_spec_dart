import 'package:equatable/equatable.dart';
import 'package:maplibre_style_spec/src/types/resolved_image.dart';

class FormattedSection with EquatableMixin {
  const FormattedSection({
    required this.text,
    this.image,
    this.scale,
    this.fontStack,
    this.textColor,
  });

  final String text;
  final ResolvedImage? image;
  final num? scale;
  final String? fontStack;
  final num? textColor;

  @override
  List<Object?> get props => [text, image, scale, fontStack, textColor];

  @override
  bool get stringify => true;
}

class Formatted with EquatableMixin {
  const Formatted({
    required this.sections,
  });

  const Formatted.empty() : sections = const [];

  final List<FormattedSection> sections;

  factory Formatted.fromJson(String unformatted) {
    return Formatted(sections: [FormattedSection(text: unformatted)]);
  }

  @override
  List<Object?> get props => [sections];

  @override
  bool get stringify => true;
}
