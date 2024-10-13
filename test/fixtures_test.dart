import 'dart:convert';
import 'dart:io';

import 'package:maplibre_style_spec/src/gen/style.gen.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Fixtures JSON parsing test', () {
    final fixtures = Directory('test/fixtures').listSync();

    for (final entity in fixtures) {
      if (entity is File && entity.path.endsWith('.json') && !entity.path.endsWith('-original.json')) {
        final name = entity.path.split('/').last.split('.').first;

        test(name, () {
          final json = jsonDecode(entity.readAsStringSync());
          final style = Style.fromJson(json);

          expect(style, isNotNull);
        });
      }
    }
  });
}
