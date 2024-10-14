import 'dart:math';

import 'package:bezier/bezier.dart';
import 'package:color_models/color_models.dart' as cm;
import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';
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

  // If value is greater than the last stop, return the last output value
  if (value > stops.last.$1) {
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

  if (T == num) return _interpolateNumber(t, a as num, b as num) as T;
  if (T == List<num>) return _interpolateNumberList(t, a as List<num>, b as List<num>) as T;
  if (T == Padding) return _interpolatePadding(t, a as Padding, b as Padding) as T;
  if (T == VariableAnchorOffsetCollection) {
    return _interpolateVariableAnchorOffsetCollection(
      t,
      a as VariableAnchorOffsetCollection,
      b as VariableAnchorOffsetCollection,
    ) as T;
  }

  if (T == Color) {
    return switch (colorInterpolationMode) {
      _ColorInterpolationMode.rgb => _interpolateColor(t, a as Color, b as Color) as T,
      _ColorInterpolationMode.hcl => _interpolateColorHcl(t, a as Color, b as Color) as T,
      _ColorInterpolationMode.lab => _interpolateColorLab(t, a as Color, b as Color) as T,
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

num _interpolateNumber(num t, num a, num b) {
  return a + (b - a) * t;
}

List<num> _interpolateNumberList(num t, List<num> a, List<num> b) {
  return List.generate(a.length, (i) => _interpolateNumber(t, a[i], b[i]));
}

Color _interpolateColor(num t, Color a, Color b) {
  final list = _interpolateNumberList(t, a.toRgbaList(), b.toRgbaList());
  return Color(r: list[0].toDouble(), g: list[1].toDouble(), b: list[2].toDouble(), a: list[3].toDouble());
}

Color _interpolateColorHcl(num t, Color a, Color b) {
  // color_models doesn't support CIE L*C*h*
  throw UnimplementedError();
}

Color _interpolateColorLab(num t, Color a, Color b) {
  final aModel = cm.RgbColor(a.r * 255, a.b * 255, a.g * 255, (a.a * 255).round());
  final bModel = cm.RgbColor(b.r * 255, b.b * 255, b.g * 255, (b.a * 255).round());

  final aLab = aModel.toLabColor();
  final bLab = bModel.toLabColor();

  final result = aLab.interpolate(bLab, t.toDouble());
  final resultRgb = result.toRgbColor();

  return Color(r: resultRgb.red / 255, g: resultRgb.green / 255, b: resultRgb.blue / 255, a: resultRgb.alpha / 255);
}

Padding _interpolatePadding(num t, Padding a, Padding b) {
  final top = _interpolateNumber(t, a.top, b.top);
  final right = _interpolateNumber(t, a.right, b.right);
  final bottom = _interpolateNumber(t, a.bottom, b.bottom);
  final left = _interpolateNumber(t, a.left, b.left);

  return Padding(top: top, right: right, bottom: bottom, left: left);
}

VariableAnchorOffsetCollection _interpolateVariableAnchorOffsetCollection(
  num t,
  VariableAnchorOffsetCollection a,
  VariableAnchorOffsetCollection b,
) {
  throw UnimplementedError();
}
