import 'dart:convert';
import 'dart:io';

import 'package:maplibre_style_spec/src/gen/style.gen.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('JSON parsing test', () {
    test('maptiler-basic.json', () {
      final json = jsonDecode(
        File('test/fixtures/maptiler-basic-migrated.json').readAsStringSync(),
      );

      final style = Style.fromJson(json);
      print(style);
    });
  });
}
