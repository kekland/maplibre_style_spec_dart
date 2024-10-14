// Contents of this file are adapted from the MapLibre GL Style Spec code:
// - `maplibre_style_spec/src/util/color_spaces.ts`

// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:maplibre_style_spec/maplibre_style_spec.dart';

typedef HclColor = (num h, num c, num l, num alpha);
typedef LabColor = (num l, num a, num b, num alpha);

extension HclColorExtension on HclColor {
  List<num> get asHclList => [this.$1, this.$2, this.$3, this.$4];
}

extension LabColorExtension on LabColor {
  List<num> get asLabList => [this.$1, this.$2, this.$3, this.$4];
}

// See https://observablehq.com/@mbostock/lab-and-rgb
const _Xn = 0.96422,
    _Yn = 1,
    _Zn = 0.82521,
    _t0 = 4 / 29,
    _t1 = 6 / 29,
    _t2 = 3 * _t1 * _t1,
    _t3 = _t1 * _t1 * _t1,
    _deg2rad = pi / 180,
    _rad2deg = 180 / pi;

HclColor hclColorFromColor(Color color) {
  final (l, a, b, alpha) = labColorFromColor(color);

  final c = sqrt(a * a + b * b);
  final h = (c * 10000).round() != 0 ? _constrainAngle(atan2(b, a) * _rad2deg) : double.nan;

  return (h, c, l, alpha);
}

Color colorFromHclColor(HclColor color) {
  var (h, c, l, alpha) = color;

  h = !h.isNaN ? h * _deg2rad : 0;
  return colorFromLabColor((l, c * cos(h), c * sin(h), alpha));
}

LabColor labColorFromColor(Color color) {
  final r = _rgb2xyz(color.r);
  final g = _rgb2xyz(color.g);
  final b = _rgb2xyz(color.b);

  num x, z;

  final y = _xyz2lab((0.2225045 * r + 0.7168786 * g + 0.0606169 * b) / _Yn);

  if (r == g && g == b) {
    x = z = y;
  } else {
    x = _xyz2lab((0.4360747 * r + 0.3850649 * g + 0.1430804 * b) / _Xn);
    z = _xyz2lab((0.0139322 * r + 0.0971045 * g + 0.7141733 * b) / _Zn);
  }

  final l = 116 * y - 16;
  return ((l < 0) ? l : l, 500 * (x - y), 200 * (y - z), color.a);
}

Color colorFromLabColor(LabColor color) {
  final (l, a, b, alpha) = color;

  num y = (l + 16) / 116;
  num x = a.isNaN ? y : y + a / 500;
  num z = b.isNaN ? y : y - b / 200;

  y = _Yn * _lab2xyz(y);
  x = _Xn * _lab2xyz(x);
  z = _Zn * _lab2xyz(z);

  return Color(
    r: _xyz2rgb(3.1338561 * x - 1.6168667 * y - 0.4906146 * z).toDouble(),
    g: _xyz2rgb(-0.9787684 * x + 1.9161415 * y + 0.0334540 * z).toDouble(),
    b: _xyz2rgb(0.0719453 * x - 0.2289914 * y + 1.4052427 * z).toDouble(),
    a: alpha.toDouble(),
  );
}

num _xyz2rgb(num x) {
  final _x = (x <= 0.00304) ? 12.92 * x : 1.055 * pow(x, 1 / 2.4) - 0.055;
  return _x.clamp(0, 1);
}

num _rgb2xyz(num x) {
  return (x <= 0.04045) ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4);
}

num _xyz2lab(num t) {
  return (t > _t3) ? pow(t, 1 / 3) : (t / _t2) + _t0;
}

num _lab2xyz(num t) {
  return (t > _t1) ? t * t * t : _t2 * (t - _t0);
}

num _constrainAngle(num angle) {
  return (angle %= 360) < 0 ? angle + 360 : angle;
}
