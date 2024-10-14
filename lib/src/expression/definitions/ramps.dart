import 'dart:math';

import 'package:bezier/bezier.dart';
import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';
import 'package:maplibre_style_spec/src/utils/color_utils.dart';
import 'package:vector_math/vector_math.dart';

@ExpressionAnnotation('StepExpression', rawName: 'step')
T stepExpressionImpl<T>(
  EvaluationContext context,
  Expression<num> input,
  Expression<T> minOutput,
  List<(num, Expression<T>)> stops,
) {
  final _input = input(context);

  for (final (stop, output) in stops) {
    if (_input > stop) {
      return output(context);
    }
  }

  return minOutput(context);
}

sealed class InterpolationOptions {
  const InterpolationOptions();

  factory InterpolationOptions.fromJson(List json) {
    return switch (json[0] as String) {
      'linear' => LinearInterpolationOptions.fromJson(json),
      'exponential' => ExponentialInterpolationOptions.fromJson(json),
      'cubic-bezier' => CubicBezierInterpolationOptions.fromJson(json),
      _ => throw UnsupportedError('Unsupported interpolation type: ${json[0]}'),
    };
  }
}

class LinearInterpolationOptions extends InterpolationOptions {
  const LinearInterpolationOptions();

  factory LinearInterpolationOptions.fromJson(List json) {
    assert(json[0] == 'linear');
    return const LinearInterpolationOptions();
  }
}

class ExponentialInterpolationOptions extends InterpolationOptions {
  const ExponentialInterpolationOptions(this.base);

  factory ExponentialInterpolationOptions.fromJson(List json) {
    assert(json[0] == 'exponential');
    return ExponentialInterpolationOptions(json[1].toDouble());
  }

  final double base;
}

class CubicBezierInterpolationOptions extends InterpolationOptions {
  const CubicBezierInterpolationOptions(this.x1, this.y1, this.x2, this.y2);

  factory CubicBezierInterpolationOptions.fromJson(List json) {
    assert(json[0] == 'cubic-bezier');

    return CubicBezierInterpolationOptions(
      json[1].toDouble(),
      json[2].toDouble(),
      json[3].toDouble(),
      json[4].toDouble(),
    );
  }

  final double x1;
  final double y1;
  final double x2;
  final double y2;
}

@ExpressionAnnotation('InterpolateExpression', rawName: 'interpolate')
T interpolateExpressionImpl<T>(
  EvaluationContext context,
  InterpolationOptions options,
  Expression<num> input,
  List<(num, Expression<T>)> stops,
) {
  return _interpolateExpressionImpl(context, options, _ColorInterpolationMode.rgb, input, stops);
}

@ExpressionAnnotation('InterpolateHclExpression', rawName: 'interpolate-hcl')
Color interpolateHclExpressionImpl(
  EvaluationContext context,
  InterpolationOptions options,
  Expression<num> input,
  List<(num, Expression<Color>)> stops,
) {
  return _interpolateExpressionImpl(context, options, _ColorInterpolationMode.hcl, input, stops);
}

@ExpressionAnnotation('InterpolateLabExpression', rawName: 'interpolate-lab')
Color interpolateLabExpressionImpl(
  EvaluationContext context,
  InterpolationOptions options,
  Expression<num> input,
  List<(num, Expression<Color>)> stops,
) {
  return _interpolateExpressionImpl(context, options, _ColorInterpolationMode.lab, input, stops);
}

enum _ColorInterpolationMode {
  rgb,
  hcl,
  lab,
}

T _interpolateExpressionImpl<T>(
  EvaluationContext context,
  InterpolationOptions options,
  _ColorInterpolationMode colorInterpolationMode,
  Expression<num> input,
  List<(num, Expression<T>)> stops,
) {
  // Only one stop, return the output value
  if (stops.length == 1) {
    return stops.first.$2.evaluate(context);
  }

  final value = input.evaluate(context);

  // If value is less than first stop, return the first output value
  if (value < stops.first.$1) {
    return stops.first.$2.evaluate(context);
  }

  // If value is greater than the last stop, return the last output value
  if (value >= stops.last.$1) {
    return stops.last.$2.evaluate(context);
  }

  final index = _findStopLessThanOrEqualTo(stops.map((e) => e.$1).toList(), value);
  final t = _interpolationFactor(
    options,
    value,
    stops[index].$1,
    stops[index + 1].$1,
  );

  final a = stops[index].$2.evaluate(context);
  final b = stops[index + 1].$2.evaluate(context);

  if (T == num) return _interpolateNumber(a as num, b as num, t) as T;
  if (T == List<num>) return _interpolateNumberList(a as List<num>, b as List<num>, t) as T;
  if (T == Padding) return _interpolatePadding(a as Padding, b as Padding, t) as T;
  if (T == VariableAnchorOffsetCollection) {
    return _interpolateVariableAnchorOffsetCollection(
      a as VariableAnchorOffsetCollection,
      b as VariableAnchorOffsetCollection,
      t,
    ) as T;
  }

  if (T == Color) {
    return switch (colorInterpolationMode) {
      _ColorInterpolationMode.rgb => _interpolateColor(a as Color, b as Color, t) as T,
      _ColorInterpolationMode.hcl => _interpolateColorHcl(a as Color, b as Color, t) as T,
      _ColorInterpolationMode.lab => _interpolateColorLab(a as Color, b as Color, t) as T,
    };
  }

  throw UnimplementedError('Unsupported interpolation type: $T');
}

/// Translated from the original JavaScript implementation:
/// - `maplibre-style-spec/src/expression.stops.ts > findStopLessThanOrEqualTo`
int _findStopLessThanOrEqualTo(
  List<num> stops,
  num input,
) {
  final lastIndex = stops.length - 1;
  var lowerIndex = 0;
  var upperIndex = lastIndex;
  var currentIndex = 0;

  num currentValue, nextValue;

  while (lowerIndex <= upperIndex) {
    currentIndex = ((lowerIndex + upperIndex) / 2).floor();
    currentValue = stops[currentIndex];
    nextValue = stops[currentIndex + 1];

    if (currentValue <= input) {
      // Search complete
      if (currentIndex == lastIndex || input < nextValue) {
        return currentIndex;
      }

      lowerIndex = currentIndex + 1;
    } else {
      upperIndex = currentIndex - 1;
    }
  }

  return 0;
}

/// Translated from the original JavaScript implementation:
/// - `maplibre-style-spec/src/expression/definitions/interpolate.ts > Interpolate.interpolationFactor`
num _interpolationFactor(InterpolationOptions interpolation, num input, num lower, num upper) {
  num t = 0;

  if (interpolation is LinearInterpolationOptions) {
    t = _exponentialInterpolation(input, 1, lower, upper);
  } else if (interpolation is ExponentialInterpolationOptions) {
    t = _exponentialInterpolation(input, interpolation.base, lower, upper);
  } else if (interpolation is CubicBezierInterpolationOptions) {
    final bezier = CubicBezier([
      Vector2(0, 0),
      Vector2(interpolation.x1, interpolation.y1),
      Vector2(interpolation.x2, interpolation.y2),
      Vector2(1, 1),
    ]);

    final point = bezier.pointAt(_exponentialInterpolation(input, 1, lower, upper).toDouble());
    t = point.y;
  }

  return t;
}

/// Translated from the original JavaScript implementation:
/// - `maplibre-style-spec/src/expression/definitions/interpolate.ts > exponentialInterpolation`
num _exponentialInterpolation(num input, num base, num lowerValue, num upperValue) {
  final difference = upperValue - lowerValue;
  final progress = input - lowerValue;

  if (difference == 0) {
    return 0;
  } else if (base == 1) {
    return progress / difference;
  } else {
    return (pow(base, progress) - 1) / (pow(base, difference) - 1);
  }
}

num _interpolateNumber(num a, num b, num t) {
  return a + (b - a) * t;
}

List<num> _interpolateNumberList(List<num> a, List<num> b, num t) {
  return List.generate(a.length, (i) => _interpolateNumber(a[i], b[i], t));
}

Color _interpolateColor(Color a, Color b, num t) {
  final list = _interpolateNumberList(a.toRgbaList(), b.toRgbaList(), t);
  return Color(r: list[0].toDouble(), g: list[1].toDouble(), b: list[2].toDouble(), a: list[3].toDouble());
}

Color _interpolateColorHcl(Color a, Color b, num t) {
  final (hue0, chroma0, light0, alphaF) = hclColorFromColor(a);
  final (hue1, chroma1, light1, alphaT) = hclColorFromColor(b);

  num? hue, chroma;

  if (!hue0.isNaN && !hue1.isNaN) {
    var dh = hue1 - hue0;

    if (hue1 > hue0 && dh > 180) {
      dh -= 360;
    } else if (hue1 < hue0 && hue0 - hue1 > 180) {
      dh += 360;
    }

    hue = hue0 + t * dh;
  } else if (!hue0.isNaN) {
    hue = hue0;
    if (light1 == 1 || light1 == 0) {
      chroma = chroma0;
    }
  } else if (!hue1.isNaN) {
    hue = hue1;
    if (light0 == 1 || light0 == 0) {
      chroma = chroma1;
    }
  } else {
    hue = double.nan;
  }

  return colorFromHclColor((
    hue,
    chroma ?? _interpolateNumber(chroma0, chroma1, t),
    _interpolateNumber(light0, light1, t),
    _interpolateNumber(alphaF, alphaT, t),
  ));
}

Color _interpolateColorLab(Color a, Color b, num t) {
  final aLab = labColorFromColor(a);
  final bLab = labColorFromColor(b);

  final outLabList = _interpolateNumberList(aLab.asLabList, bLab.asLabList, t);
  final outLabColor = (outLabList[0], outLabList[1], outLabList[2], outLabList[3]);

  return colorFromLabColor(outLabColor);
}

Padding _interpolatePadding(Padding a, Padding b, num t) {
  return Padding(
    top: _interpolateNumber(a.top, b.top, t),
    right: _interpolateNumber(a.right, b.right, t),
    bottom: _interpolateNumber(a.bottom, b.bottom, t),
    left: _interpolateNumber(a.left, b.left, t),
  );
}

VariableAnchorOffsetCollection _interpolateVariableAnchorOffsetCollection(
  VariableAnchorOffsetCollection a,
  VariableAnchorOffsetCollection b,
  num t,
) {
  throw UnimplementedError();
}
