import 'package:maplibre_style_spec/src/gen/style.gen.dart';

class Source {
  const Source();

  factory Source.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    return switch (type) {
      'vector' => SourceVector.fromJson(json),
      'raster' => SourceRaster.fromJson(json),
      'raster-dem' => SourceRasterDem.fromJson(json),
      'geojson' => SourceGeoJson.fromJson(json),
      'video' => SourceVideo.fromJson(json),
      'image' => SourceImage.fromJson(json),
      _ => throw UnimplementedError('Source type $type not implemented'),
    };
  }
}
