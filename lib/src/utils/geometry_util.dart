import 'package:geojson_vi/geojson_vi.dart';
import 'package:maplibre_style_spec/src/_src.dart';
import "dart:math" as math;

const extent = 8192;

List<double> getLngLatFromTileCoord(List<num> coord, ICanonicalTileID canonical) {
  final tilesAtZoom = math.pow(2, canonical.z);
  final x = (coord[0] / extent + canonical.x) / tilesAtZoom;
  final y = (coord[1] / extent + canonical.y) / tilesAtZoom;
  return [lngFromMercatorXfromLng(x), latFromMercatorY(y)];
}

num mercatorXfromLng(num lng) {
  return (180 + lng) / 360;
}

double lngFromMercatorXfromLng(num mercatorX) {
  return mercatorX * 360 - 180;
}

num mercatorYfromLat(num lat) {
  return (180 - (180 / math.pi * math.log(math.tan(math.pi / 4 + lat * math.pi / 360)))) / 360;
}

double latFromMercatorY(num mercatorY) {
  return 360 / math.pi * math.atan(math.exp((180 - mercatorY * 360) * math.pi / 180)) - 90;
}

num perp(List<num> v1, List<num> v2) {
  return (v1[0] * v2[1] - v1[1] * v2[0]);
}

bool twoSided(
  List<num> p1,
  List<num> p2,
  List<num> q1,
  List<num> q2,
) {
  final x1 = p1[0] - q1[0];
  final y1 = p1[1] - q1[1];
  final x2 = p2[0] - q1[0];
  final y2 = p2[1] - q1[1];
  final x3 = q2[0] - q1[0];
  final y3 = q2[1] - q1[1];
  final det1 = (x1 * y3 - x3 * y1);
  final det2 = (x2 * y3 - x3 * y2);
  if ((det1 > 0 && det2 < 0) || (det1 < 0 && det2 > 0)) return true;
  return false;
}

bool segmentIntersectSegment(
  List<num> a,
  List<num> b,
  List<num> c,
  List<num> d,
) {
  // check if two segments are parallel or not
  // precondition is end point a, b is inside polygon, if line a->b is
  // parallel to polygon edge c->d, then a->b won't intersect with c->d
  final List<num> vectorP = [b[0] - a[0], b[1] - a[1]];
  final List<num> vectorQ = [d[0] - c[0], d[1] - c[1]];
  if (perp(vectorQ, vectorP) == 0) return false;

  // If lines are intersecting with each other, the relative location should be:
  // a and b lie in different sides of segment c->d
  // c and d lie in different sides of segment a->b
  if (twoSided(a, b, c, d) && twoSided(c, d, a, b)) return true;
  return false;
}
