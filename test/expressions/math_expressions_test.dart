import 'dart:math' as math;

import 'package:maplibre_style_spec/src/_src.dart';
import 'package:test/test.dart';

void main() {
  group('Math expressions', () {
    group('ln2', () {
      test('should evaluate correctly', () {
        final expression = Ln2Expression();
        expect(expression.evaluate(EvaluationContext.empty()), math.ln2);
      });

      test('should serialize correctly', () {
        final expression = Ln2Expression.fromJson(['ln2']);
        expect(expression, const Ln2Expression());
      });
    });
  });
}
