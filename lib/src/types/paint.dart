import 'package:maplibre_style_spec/src/gen/style.gen.dart';

class Paint {
  const Paint();

  factory Paint.fromJson(
    dynamic json, {
    required Layer$Type type,
  }) {
    return switch (type) {
      Layer$Type.background => PaintBackground.fromJson(json),
      Layer$Type.circle => PaintCircle.fromJson(json),
      Layer$Type.fill => PaintFill.fromJson(json),
      Layer$Type.fillExtrusion => PaintFillExtrusion.fromJson(json),
      Layer$Type.line => PaintLine.fromJson(json),
      Layer$Type.raster => PaintRaster.fromJson(json),
      Layer$Type.symbol => PaintSymbol.fromJson(json),
      Layer$Type.hillshade => PaintHillshade.fromJson(json),
      Layer$Type.heatmap => PaintHeatmap.fromJson(json),
    };
  }
}
