import 'package:equatable/equatable.dart';

class Locale with EquatableMixin {
  const Locale({
    required this.languageCode,
    this.scriptCode,
  });

  final String languageCode;
  final String? scriptCode;

  @override
  List<Object?> get props => [languageCode, scriptCode];

  @override
  bool get stringify => true;
}
