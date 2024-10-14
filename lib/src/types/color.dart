import 'package:csslib/parser.dart' as css;

class Color {
  const Color({
    required this.r,
    required this.g,
    required this.b,
    this.a = 1.0,
  });

  factory Color.fromList(List<num> value) {
    return Color(
      r: value[0] / 255,
      g: value[1] / 255,
      b: value[2] / 255,
      a: value.length == 4 ? value[3].toDouble() : 1.0,
    );
  }

  factory Color.fromJson(String value) {
    // Convert percentages to 0-1 range because csslib doesn't support it
    // Collect [number]% and divide by 100
    var _value = value;

    // TODO: Color parsing with csslib sucks :( Maybe rewrite?
    final regex = RegExp(r'(\d+(\.\d+)?)%');
    _value = _value.replaceAllMapped(regex, (match) {
      final percentage = double.parse(match.group(1)!);
      return (percentage / 100).toString();
    });

    if (_value.startsWith('#')) {
      // Check for 3/4 digit hex
      if (_value.length == 4 || _value.length == 5) {
        // Duplicate each character, because csslib doesn't support 3/4 digit hex values
        _value = '#${_value.split('').skip(1).map((e) => e * 2).join()}';
      }
    }

    if (_value.startsWith('hsl')) {
      final inBrackets = _value.split('(').last.split(')').first;
      final parts = inBrackets.split(',').map((e) => e.trim()).toList();

      final h = double.parse(parts[0]);

      // H should be in range 0..1
      parts[0] = (h / 360).toString();

      if (_value.startsWith('hsla')) {
        _value = 'hsla(${parts.join(',')})';
      } else {
        _value = 'hsl(${parts.join(',')})';
      }
    }

    final _color = css.Color.css(_value);

    return Color(
      r: _color.rgba.r / 255,
      g: _color.rgba.g / 255,
      b: _color.rgba.b / 255,
      a: _color.rgba.a?.toDouble() ?? 1.0,
    );
  }

  final double r;
  final double g;
  final double b;
  final double a;

  List<double> toRgbaList() => [r, g, b, a];

  @override
  String toString() {
    return 'Color(r: $r, g: $g, b: $b, a: $a)';
  }
}
