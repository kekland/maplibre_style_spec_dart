import 'dart:convert';
import 'dart:io';

import 'package:maplibre_style_spec/src/gen/style.gen.dart';

class StyleReader {
  static Future<Style> fromFile(File file) async {
    final jsonStr = await file.readAsString();
    return fromString(jsonStr);
  }

  static Future<Style> fromNetwork(Uri uri) async {
    final response = await HttpClient().getUrl(uri).then((request) => request.close());
    final jsonStr = await response.transform(utf8.decoder).join();

    return fromString(jsonStr);
  }

  static Future<Style> fromString(String jsonStr) async {
    return Style.fromJson(jsonDecode(jsonStr));
  }
}
