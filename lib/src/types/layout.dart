import 'package:maplibre_style_spec/src/gen/style.gen.dart';

class Layout {
  const Layout();

  factory Layout.fromJson(
    Map<String, dynamic> json, {
    required Layer$Type type,
  }) {
    return switch (type) {
      Layer$Type.background => LayoutBackground.fromJson(json),
      Layer$Type.circle => LayoutCircle.fromJson(json),
      Layer$Type.fill => LayoutFill.fromJson(json),
      Layer$Type.fillExtrusion => LayoutFillExtrusion.fromJson(json),
      Layer$Type.line => LayoutLine.fromJson(json),
      Layer$Type.raster => LayoutRaster.fromJson(json),
      Layer$Type.symbol => LayoutSymbol.fromJson(json),
      Layer$Type.hillshade => LayoutHillshade.fromJson(json),
      Layer$Type.heatmap => LayoutHeatmap.fromJson(json),
    };
  }
}
