import 'package:equatable/equatable.dart';

class Padding with EquatableMixin {
  const Padding({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  const Padding.all(num value)
      : top = value,
        right = value,
        bottom = value,
        left = value;

  final num top;
  final num right;
  final num bottom;
  final num left;

  factory Padding.fromJson(List<num> json) {
    if (json.length == 1) {
      return Padding.all(json[0]);
    } else if (json.length == 2) {
      final vertical = json[0];
      final horizontal = json[1];

      return Padding(top: vertical, right: horizontal, bottom: vertical, left: horizontal);
    } else if (json.length == 3) {
      final top = json[0];
      final horizontal = json[1];
      final bottom = json[2];

      return Padding(top: top, right: horizontal, bottom: bottom, left: horizontal);
    } else if (json.length == 4) {
      return Padding(
        top: json[0],
        right: json[1],
        bottom: json[2],
        left: json[3],
      );
    }

    throw Exception('Invalid padding value: $json');
  }

  @override
  List<Object?> get props => [top, right, bottom, left];

  @override
  bool get stringify => true;
}
