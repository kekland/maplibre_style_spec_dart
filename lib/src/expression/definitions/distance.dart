// TODO: Distance

import 'package:geojson_vi/geojson_vi.dart';
import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/utils/cheap_ruler.dart';
import 'package:maplibre_style_spec/src/utils/classify_rings.dart';
import 'package:maplibre_style_spec/src/utils/geometry_util.dart';
import 'dart:math' as math;

import 'package:maplibre_style_spec/src/utils/points_to_polygon_dist.dart';
import 'package:maplibre_style_spec/src/utils/ring_with_area.dart';

List<GeoJSONGeometry> toSimpleGeomerty(GeoJSON geoJson) {
  if (geoJson is GeoJSONMultiPolygon) {
    return geoJson.coordinates.map((polygon) {
      return GeoJSONPolygon(polygon);
    }).toList();
  }
  if (geoJson is GeoJSONMultiLineString) {
    return geoJson.coordinates.map((lineString) {
      return GeoJSONLineString(lineString);
    }).toList();
  }
  if (geoJson is GeoJSONMultiPoint) {
    return geoJson.coordinates.map((point) {
      return GeoJSONPoint(point);
    }).toList();
  }

  return [
    GeoJSONGeometry.fromMap(
      geoJson.toMap(),
    ),
  ];
}

num pointToGeometryDistance(EvaluationContext context, List<GeoJSONGeometry> simpleGeometry) {
  final GeoJSON? ctxFeature = context.feature;
  if (ctxFeature is! GeoJSONPoint) {
    return double.infinity;
  }

  final List<List<double>> pointPosition = [ctxFeature.coordinates].map((p) {
    return getLngLatFromTileCoord(
      p,
      context.canonical!,
    );
  }).toList();
  final ruler = CheapRuler(pointPosition[0][1]);
  num dist = double.infinity;

  for (final geometry in simpleGeometry) {
    if (geometry is GeoJSONPoint) {
      dist = math.min(
        dist,
        pointSetToPointSetDistance(
          pointPosition,
          false,
          [geometry.coordinates],
          false,
          ruler,
          dist,
        ),
      );
    } else if (geometry is GeoJSONLineString) {
      dist = math.min(
        dist,
        pointSetToPointSetDistance(
          pointPosition,
          false,
          geometry.coordinates,
          true,
          ruler,
          dist,
        ),
      );
    } else if (geometry is GeoJSONPolygon) {
      dist = math.min(
        dist,
        pointsToPolygonDistance(pointPosition, false, geometry.coordinates, ruler, dist),
      );
    }
    if (dist == 0.0) {
      return dist;
    }
  }

  return dist;
}

num lineStringToGeometryDistance(EvaluationContext context, List<GeoJSONGeometry> simpleGeometry) {
  final GeoJSON? ctxFeature = context.feature;
  if (ctxFeature is! GeoJSONLineString) {
    return double.infinity;
  }
  final tileLine = ctxFeature.coordinates;
  final linePositions = tileLine.map((p) => getLngLatFromTileCoord(p, context.canonical!)).toList();

  if (tileLine.isEmpty) {
    return double.infinity;
  }

  final ruler = CheapRuler(linePositions[0][1]);
  num dist = double.infinity;

  for (final geometry in simpleGeometry) {
    if (geometry is GeoJSONPoint) {
      dist = math.min(
        dist,
        pointSetToPointSetDistance(
          linePositions,
          true,
          [geometry.coordinates],
          false,
          ruler,
          dist,
        ),
      );
    } else if (geometry is GeoJSONLineString) {
      dist = math.min(
        dist,
        pointSetToPointSetDistance(
          linePositions,
          true,
          geometry.coordinates,
          true,
          ruler,
          dist,
        ),
      );
    } else if (geometry is GeoJSONPolygon) {
      dist = math.min(
        dist,
        pointsToPolygonDistance(
          linePositions,
          true,
          geometry.coordinates,
          ruler,
          dist,
        ),
      );
    }
    if (dist == 0.0) {
      return dist;
    }
  }

  return dist;
}

bool boxWithinBox(List<num> bbox1, List<num> bbox2) {
  if (bbox1[0] <= bbox2[0]) return false;
  if (bbox1[2] >= bbox2[2]) return false;
  if (bbox1[1] <= bbox2[1]) return false;
  if (bbox1[3] >= bbox2[3]) return false;
  return true;
}

bool polygonIntersect(
  List<List<List<double>>> poly1,
  List<List<List<double>>> poly2,
) {
  for (final ring in poly1) {
    for (final point in ring) {
      if (pointWithinPolygon(point, poly2, true)) {
        return true;
      }
    }
  }
  return false;
}

num polygonToPolygonDistance(List<List<List<double>>> polygon1, List<List<List<double>>> polygon2, CheapRuler ruler,
    [num currentMiniDist = double.infinity]) {
  final bbox1 = GeoJSONPolygon(polygon1).bbox;
  ;
  final bbox2 = GeoJSONPolygon(polygon2).bbox;
  if (currentMiniDist != double.infinity && bboxToBBoxDistance(bbox1, bbox2, ruler) >= currentMiniDist) {
    return currentMiniDist;
  }

  if (boxWithinBox(bbox1, bbox2)) {
    if (polygonIntersect(polygon1, polygon2)) {
      return 0.0;
    }
  } else if (polygonIntersect(polygon2, polygon1)) {
    return 0.0;
  }

  num dist = double.infinity;
  for (final ring1 in polygon1) {
    for (int i = 0, len1 = ring1.length, l = len1 - 1; i < len1; l = i++) {
      final p1 = ring1[l];
      final p2 = ring1[i];
      for (final ring2 in polygon2) {
        for (int j = 0, len2 = ring2.length, k = len2 - 1; j < len2; k = j++) {
          final q1 = ring2[k];
          final q2 = ring2[j];
          if (segmentIntersectSegment(p1, p2, q1, q2)) {
            return 0.0;
          }
          dist = math.min(dist, segmentToSegmentDistance(p1, p2, q1, q2, ruler));
        }
      }
    }
  }
  return dist;
}

num polygonToGeometryDistance(EvaluationContext context, List<GeoJSONGeometry> simpleGeometry) {
  final GeoJSON? ctxFeature = context.feature;
  if (ctxFeature is! GeoJSONPolygon) {
    return double.infinity;
  }
  final tilePolygon = ctxFeature.coordinates;
  if (tilePolygon.isEmpty || tilePolygon[0].isEmpty) {
    return double.infinity;
  }

  final polygons = classifyRings(
          tilePolygon.map((val) {
            return RingWithArea(null, val);
          }).toList(),
          0)
//
      .map((polygon) {
    return polygon.map((ring) {
      return ring.getValue().map((p) {
        return getLngLatFromTileCoord(p, context.canonical!);
      }).toList();
    }).toList();
  }).toList();

  final ruler = CheapRuler(polygons[0][0][0][1]);
  num dist = double.infinity;
  for (final geometry in simpleGeometry) {
    for (final polygon in polygons) {
      //
      if (geometry is GeoJSONPoint) {
        dist = math.min(
          dist,
          pointsToPolygonDistance(
            [geometry.coordinates],
            false,
            polygon,
            ruler,
            dist,
          ),
        );
      } else if (geometry is GeoJSONLineString) {
        dist = math.min(
          dist,
          pointsToPolygonDistance(
            geometry.coordinates,
            true,
            polygon,
            ruler,
            dist,
          ),
        );
      } else if (geometry is GeoJSONPolygon) {
        dist = math.min(
          dist,
          polygonToPolygonDistance(
            polygon,
            geometry.coordinates,
            ruler,
            dist,
          ),
        );
      }
      if (dist == 0.0) {
        return dist;
      }

      //
    }
  }
  return dist;
}

class DistanceExpression extends Expression<num> {
  const DistanceExpression({
    required this.geoJson,
    required this.simpleGeometry,
  });

  factory DistanceExpression.fromJson(List<dynamic> args) {
    assert(args[0] == 'distance', 'Invalid expression type: ${args[0]}, expected [distance]');
    assert(args.length == 2, 'Invalid args length ');
    final geoJson = GeoJSON.fromJSON(args[1]);

    if (geoJson is GeoJSONFeatureCollection) {
      return DistanceExpression(
        geoJson: geoJson,
        simpleGeometry: geoJson.features
            .map((feature) {
              return toSimpleGeomerty(feature!);
            })
            .expand((i) => i)
            .toList(),
      );
    }
    if (geoJson is GeoJSONFeature) {
      return DistanceExpression(
        geoJson: geoJson,
        simpleGeometry: toSimpleGeomerty(geoJson.geometry!),
      );
    }
    {
      return DistanceExpression(
        geoJson: geoJson,
        simpleGeometry: toSimpleGeomerty(geoJson),
      );
    }
  }

  final GeoJSON geoJson;
  final List<GeoJSONGeometry> simpleGeometry;

  @override
  num evaluate(EvaluationContext context) {
    if (context.feature == null || context.canonical == null) {
      return double.infinity;
    }
    if (context.feature is GeoJSONPoint) {
      return pointToGeometryDistance(context, simpleGeometry);
    } else if (context.feature is GeoJSONLineString) {
      return lineStringToGeometryDistance(context, simpleGeometry);
    } else if (context.feature is GeoJSONPolygon) {
      return polygonToGeometryDistance(context, simpleGeometry);
    }
    return double.infinity;
  }
}
