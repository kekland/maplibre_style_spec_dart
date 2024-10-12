class Padding {
  const Padding({
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    this.left = 0.0,
  });

  const Padding.all(double value)
      : top = value,
        right = value,
        bottom = value,
        left = value;

  final double top;
  final double right;
  final double bottom;
  final double left;

  factory Padding.fromJson(List<num> json) {
    if (json.length == 1) {
      return Padding.all(json[0].toDouble());
    } else if (json.length == 2) {
      final vertical = json[0].toDouble();
      final horizontal = json[1].toDouble();

      return Padding(top: vertical, right: horizontal, bottom: vertical, left: horizontal);
    } else if (json.length == 3) {
      final top = json[0].toDouble();
      final horizontal = json[1].toDouble();
      final bottom = json[2].toDouble();

      return Padding(top: top, right: horizontal, bottom: bottom, left: horizontal);
    } else if (json.length == 4) {
      return Padding(
        top: json[0].toDouble(),
        right: json[1].toDouble(),
        bottom: json[2].toDouble(),
        left: json[3].toDouble(),
      );
    }

    throw Exception('Invalid padding value: $json');
  }
}
