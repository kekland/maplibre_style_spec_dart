import 'dart:convert';
import 'dart:io';

import 'package:maplibre_style_spec/src/_src.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

Map<String, dynamic> _getFixturesInDirectory(Directory directory) {
  final fixtures = <String, dynamic>{};

  for (final entity in directory.listSync()) {
    if (entity is File && entity.path.endsWith('.json')) {
      final name = entity.path.split('/').last.split('.').first;
      fixtures[name] = jsonDecode(entity.readAsStringSync());
    }
  }

  return fixtures;
}

void main() {
  group('[Fixtures] Style JSON parsing', () {
    final fixtures = _getFixturesInDirectory(Directory('test/fixtures/styles'));

    for (final name in fixtures.keys) {
      final json = fixtures[name];

      test(name, () {
        final style = Style.fromJson(json);
        expect(style, isNotNull);
      });
    }
  });

  group('[Fixtures] TileJSON parsing', () {
    final fixtures = _getFixturesInDirectory(Directory('test/fixtures/tilejson'));

    for (final name in fixtures.keys) {
      final json = fixtures[name];

      test(name, () {
        final style = $TileJson.fromJson(json);
        expect(style, isNotNull);
      });
    }
  });
}
