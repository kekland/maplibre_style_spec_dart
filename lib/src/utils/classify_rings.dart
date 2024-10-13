import 'package:collection/collection.dart';
import 'package:maplibre_style_spec/src/utils/ring_with_area.dart';
import 'package:rbush/rbush.dart';

int compareAreas(RingWithArea a, RingWithArea b) {
  return (b.area! - a.area!).toInt();
}

num calculateSignedArea(List<List<num>> ring) {
  num sum = 0;
  for (int i = 0, len = ring.length, j = len - 1; i < len; j = i++) {
    final p1 = ring[i];
    final p2 = ring[j];
    sum += (p2[0] - p1[0]) * (p1[1] + p2[1]);
  }
  return sum;
}

List<List<RingWithArea>> classifyRings<T extends List<num>>(
  List<RingWithArea<T>> rings, [
  int maxRings = 0,
]) {
  final len = rings.length;

  if (len <= 1) return [rings];

  List<List<RingWithArea>> polygons = [];
  List<RingWithArea>? polygon;
  bool? ccw;

  for (final ring in rings) {
    final area = calculateSignedArea(ring.getValue());
    if (area == 0) continue;

    ring.area = area.abs();

    ccw ??= area < 0;

    if (ccw == area < 0) {
      if (polygon != null) polygons.add(polygon);
      polygon = [ring];
    } else {
      polygon!.add(ring);
    }
  }
  if (polygon != null) polygons.add(polygon);

  // Earcut performance degrades with the # of rings in a polygon. For this
  // reason, we limit strip out all but the `maxRings` largest rings.
  if (maxRings > 1) {
    for (int j = 0; j < polygons.length; j++) {
      if (polygons[j].length <= maxRings) continue;
      quickSelect<RingWithArea>(polygons[j], maxRings, 1, polygons[j].length - 1, compareAreas);
      polygons[j] = polygons[j].slice(0, maxRings);
    }
  }

  return polygons;
}
