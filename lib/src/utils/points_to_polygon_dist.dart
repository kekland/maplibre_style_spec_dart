import 'package:collection/collection.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:maplibre_style_spec/src/utils/cheap_ruler.dart';
import 'package:maplibre_style_spec/src/utils/geometry_util.dart';
import 'dart:math' as math;

import 'package:maplibre_style_spec/src/utils/tiny_queue.dart';
import 'package:rbush/rbush.dart';

const minPointsSize = 100;
const minLinePointsSize = 50;

typedef IndexRange = (int, int);
typedef DistPair = (num, IndexRange, IndexRange);

(IndexRange?, IndexRange?) splitRange(
  IndexRange range,
  bool isLine,
) {
  if (range.$1 > range.$2) {
    return (null, null);
  }
  final size = getRangeSize(range);
  if (isLine) {
    if (size == 2) {
      return (range, null);
    }

    final size1 = (size / 2).floor();
    return (
      (range.$1, range.$1 + size1),
      (range.$1 + size1, range.$2),
    );
  }
  if (size == 1) {
    return (range, null);
  }
  final size1 = (size / 2).floor() - 1;
  return (
    (range.$1, range.$1 + size1),
    (range.$1 + size1 + 1, range.$2),
  );
}

int compareDistPair(DistPair a, DistPair b) {
  return (b.$1 - a.$1).toInt();
}

int getRangeSize(IndexRange range) {
  return range.$2 - range.$1 + 1;
}

bool isRangeSafe(IndexRange range, num threshold) {
  return range.$2 >= range.$1 && range.$2 < threshold;
}

bool pointOnBoundary(List<num> p, List<num> p1, List<num> p2) {
  final x1 = p[0] - p1[0];
  final y1 = p[1] - p1[1];
  final x2 = p[0] - p2[0];
  final y2 = p[1] - p2[1];
  return (x1 * y2 - x2 * y1 == 0) && (x1 * x2 <= 0) && (y1 * y2 <= 0);
}

bool rayIntersect(List<num> p, List<num> p1, List<num> p2) {
  return ((p1[1] > p[1]) != (p2[1] > p[1])) && (p[0] < (p2[0] - p1[0]) * (p[1] - p1[1]) / (p2[1] - p1[1]) + p1[0]);
}

bool pointWithinPolygon(List<num> point, List<List<List<num>>> rings, [bool trueIfOnBoundary = false]) {
  bool inside = false;
  for (final ring in rings) {
    for (int j = 0; j < ring.length - 1; j++) {
      if (pointOnBoundary(point, ring[j], ring[j + 1])) return trueIfOnBoundary;
      if (rayIntersect(point, ring[j], ring[j + 1])) inside = !inside;
    }
  }
  return inside;
}

num pointToLineDistance(
  List<num> point,
  List<List<num>> line,
  CheapRuler ruler,
) {
  final nearestPoint = ruler.pointOnLine(line, point);
  return ruler.distance(point, nearestPoint.point);
}

num segmentToSegmentDistance(
  List<num> p1,
  List<num> p2,
  List<num> q1,
  List<num> q2,
  CheapRuler ruler,
) {
  final dist1 = math.min(pointToLineDistance(p1, [q1, q2], ruler), pointToLineDistance(p2, [q1, q2], ruler));
  final dist2 = math.min(pointToLineDistance(q1, [p1, p2], ruler), pointToLineDistance(q2, [p1, p2], ruler));
  return math.min(dist1, dist2);
}

num lineToPolygonDistance(
    List<List<double>> line, IndexRange range, List<List<List<double>>> polygon, CheapRuler ruler) {
  if (!isRangeSafe(range, line.length)) {
    return double.infinity;
  }

  for (int i = range.$1; i <= range.$2; ++i) {
    if (pointWithinPolygon(line[i], polygon, true)) {
      return 0.0;
    }
  }

  num dist = double.infinity;
  for (int i = range.$1; i < range.$2; ++i) {
    final p1 = line[i];
    final p2 = line[i + 1];
    for (final ring in polygon) {
      for (int j = 0, len = ring.length, k = len - 1; j < len; k = j++) {
        final q1 = ring[k];
        final q2 = ring[j];
        if (segmentIntersectSegment(p1, p2, q1, q2)) {
          return 0.0;
        }
        dist = math.min(
          dist,
          segmentToSegmentDistance(
            p1,
            p2,
            q1,
            q2,
            ruler,
          ),
        );
      }
    }
  }
  return dist;
}

num pointToPolygonDistance(
  List<double> point,
  List<List<List<double>>> polygon,
  CheapRuler ruler,
) {
  if (pointWithinPolygon(point, polygon, true)) {
    return 0.0;
  }
  num dist = double.infinity;
  for (final ring in polygon) {
    final front = ring[0];
    final back = ring[ring.length - 1];
    if (front != back) {
      dist = math.min(dist, pointToLineDistance(point, [back, front], ruler));
      if (dist == 0.0) {
        return dist;
      }
    }
    final nearestPoint = ruler.pointOnLine(ring, point);
    dist = math.min(dist, ruler.distance(point, nearestPoint.point));
    if (dist == 0.0) {
      return dist;
    }
  }
  return dist;
}

bool isValidBBox(List bbox) {
  return (bbox[0] != -double.infinity &&
      bbox[1] != -double.infinity &&
      bbox[2] != double.infinity &&
      bbox[3] != double.infinity);
}

num lineToLineDistance(
  List<List<double>> line1,
  IndexRange range1,
  List<List<double>> line2,
  IndexRange range2,
  CheapRuler ruler,
) {
  final rangeSafe = isRangeSafe(range1, line1.length) && isRangeSafe(range2, line2.length);
  if (!rangeSafe) {
    return double.infinity;
  }

  num dist = double.infinity;
  for (int i = range1.$1; i < range1.$2; ++i) {
    final p1 = line1[i];
    final p2 = line1[i + 1];
    for (int j = range2.$1; j < range2.$2; ++j) {
      final q1 = line2[j];
      final q2 = line2[j + 1];
      if (segmentIntersectSegment(p1, p2, q1, q2)) {
        return 0.0;
      }
      dist = math.min(
        dist,
        segmentToSegmentDistance(p1, p2, q1, q2, ruler),
      );
    }
  }
  return dist;
}

num bboxToBBoxDistance(
  List<num> bbox1,
  List<num> bbox2,
  CheapRuler ruler,
) {
  if (!isValidBBox(bbox1) || !isValidBBox(bbox2)) {
    return double.infinity;
  }
  num dx = 0.0;
  num dy = 0.0;
  // bbox1 in left side
  if (bbox1[2] < bbox2[0]) {
    dx = bbox2[0] - bbox1[2];
  }
  // bbox1 in right side
  if (bbox1[0] > bbox2[2]) {
    dx = bbox1[0] - bbox2[2];
  }
  // bbox1 in above side
  if (bbox1[1] > bbox2[3]) {
    dy = bbox1[1] - bbox2[3];
  }
  // bbox1 in down side
  if (bbox1[3] < bbox2[1]) {
    dy = bbox2[1] - bbox1[3];
  }
  return ruler.distance([0.0, 0.0], [dx, dy]);
}

void updateBBox(List<double> bbox, List<double> coord) {
  bbox[0] = math.min(bbox[0], coord[0]);
  bbox[1] = math.min(bbox[1], coord[1]);
  bbox[2] = math.max(bbox[2], coord[0]);
  bbox[3] = math.max(bbox[3], coord[1]);
}

List<double> getBBox(List<List<double>> coords, IndexRange range) {
  if (!isRangeSafe(range, coords.length)) {
    return [double.infinity, double.infinity, -double.infinity, -double.infinity];
  }

  final bbox = [double.infinity, double.infinity, -double.infinity, -double.infinity];
  for (int i = range.$1; i <= range.$2; ++i) {
    updateBBox(bbox, coords[i]);
  }
  return bbox;
}

updateQueue(
  TinyQueue<DistPair> distQueue,
  num miniDist,
  CheapRuler ruler,
  List<List<double>> points,
  List<double> polyBBox, [
  IndexRange? rangeA,
]) {
  if (rangeA == null) {
    return;
  }
  final tempDist = bboxToBBoxDistance(getBBox(points, rangeA), polyBBox, ruler);

  if (tempDist < miniDist) {
    distQueue.push((tempDist, rangeA, (0, 0)));
  }
}

num pointsToPointsDistance(
  List<List<double>> points1,
  IndexRange range1,
  List<List<double>> points2,
  IndexRange range2,
  CheapRuler ruler,
) {
  final rangeSafe = isRangeSafe(range1, points1.length) && isRangeSafe(range2, points2.length);
  if (!rangeSafe) {
    return double.infinity;
  }

  num dist = double.infinity;
  for (int i = range1.$1; i <= range1.$2; ++i) {
    for (int j = range2.$1; j <= range2.$2; ++j) {
      dist = math.min(dist, ruler.distance(points1[i], points2[j]));
      if (dist == 0.0) {
        return dist;
      }
    }
  }
  return dist;
}

void updateQueueTwoSets(
  TinyQueue<DistPair> distQueue,
  num miniDist,
  CheapRuler ruler,
  List<List<double>> pointSet1,
  List<List<double>> pointSet2, [
  IndexRange? range1,
  IndexRange? range2,
]) {
  if (range1 == null || range2 == null) {
    return;
  }
  final tempDist = bboxToBBoxDistance(getBBox(pointSet1, range1), getBBox(pointSet2, range2), ruler);
  // Insert new pair to the queue if the bbox distance is less than
  // miniDist, The pair with biggest distance will be at the top
  if (tempDist < miniDist) {
    distQueue.push((tempDist, range1, range2));
  }
}

num pointSetToPointSetDistance(
  List<List<double>> pointSet1,
  bool isLine1,
  List<List<double>> pointSet2,
  bool isLine2,
  CheapRuler ruler, [
  num currentMiniDist = double.infinity,
]) {
  num miniDist = math.min(
    currentMiniDist,
    ruler.distance(pointSet1[0], pointSet2[0]),
  );
  if (miniDist == 0.0) {
    return miniDist;
  }

  final distQueue = TinyQueue<DistPair>([(0, (0, pointSet1.length - 1), (0, pointSet2.length - 1))], compareDistPair);

  while (distQueue.length > 0) {
    final distPair = distQueue.pop();
    if (distPair.$1 >= miniDist) {
      continue;
    }

    final rangeA = distPair.$2;
    final rangeB = distPair.$3;
    final threshold1 = isLine1 ? minLinePointsSize : minPointsSize;
    final threshold2 = isLine2 ? minLinePointsSize : minPointsSize;

    if (getRangeSize(rangeA) <= threshold1 && getRangeSize(rangeB) <= threshold2) {
      if (!isRangeSafe(rangeA, pointSet1.length) && isRangeSafe(rangeB, pointSet2.length)) {
        return double.infinity;
      }

      num tempDist;
      if (isLine1 && isLine2) {
        tempDist = lineToLineDistance(
          pointSet1,
          rangeA,
          pointSet2,
          rangeB,
          ruler,
        );
        miniDist = math.min(miniDist, tempDist);
      } else if (isLine1 && !isLine2) {
        final sublibe = pointSet1.slice(rangeA.$1, rangeA.$2 + 1);
        for (int i = rangeB.$1; i <= rangeB.$2; ++i) {
          tempDist = pointToLineDistance(pointSet2[i], sublibe, ruler);
          miniDist = math.min(miniDist, tempDist);
          if (miniDist == 0.0) {
            return miniDist;
          }
        }
      } else if (!isLine1 && isLine2) {
        final sublibe = pointSet2.slice(rangeB.$1, rangeB.$2 + 1);
        for (int i = rangeA.$1; i <= rangeA.$2; ++i) {
          tempDist = pointToLineDistance(pointSet1[i], sublibe, ruler);
          miniDist = math.min(miniDist, tempDist);
          if (miniDist == 0.0) {
            return miniDist;
          }
        }
      } else {
        tempDist = pointsToPointsDistance(
          pointSet1,
          rangeA,
          pointSet2,
          rangeB,
          ruler,
        );
        miniDist = math.min(miniDist, tempDist);
      }
    } else {
      final newRangesA = splitRange(rangeA, isLine1);
      final newRangesB = splitRange(rangeB, isLine2);
      updateQueueTwoSets(distQueue, miniDist, ruler, pointSet1, pointSet2, newRangesA.$1, newRangesB.$1);
      updateQueueTwoSets(distQueue, miniDist, ruler, pointSet1, pointSet2, newRangesA.$1, newRangesB.$2);
      updateQueueTwoSets(distQueue, miniDist, ruler, pointSet1, pointSet2, newRangesA.$2, newRangesB.$1);
      updateQueueTwoSets(distQueue, miniDist, ruler, pointSet1, pointSet2, newRangesA.$2, newRangesB.$2);
    }
  }
  return miniDist;
}

num pointsToPolygonDistance(
  List<List<double>> points,
  bool isLine,
  List<List<List<double>>> polygon,
  CheapRuler ruler, [
  num currentMiniDist = double.infinity,
]) {
  num miniDist = math.min(
    ruler.distance(points[0], polygon[0][0]),
    currentMiniDist,
  );
  if (miniDist == 0) {
    return miniDist;
  }

  final distQueue = TinyQueue<DistPair>(
    [(0, (0, points.length - 1), (0, 0))],
    compareDistPair,
  );
  final polyBBox = GeoJSONPolygon(polygon).bbox;
  while (distQueue.length > 0) {
    final distPair = distQueue.pop();
    if (distPair.$1 >= miniDist) {
      continue;
    }

    final range = distPair.$2;
    final threshold = isLine ? minLinePointsSize : minPointsSize;

    if (getRangeSize(range) <= threshold) {
      if (!isRangeSafe(range, threshold)) {
        return double.infinity;
      }

      if (isLine) {
        final tempDist = lineToPolygonDistance(points, range, polygon, ruler);
        if (tempDist == double.infinity || tempDist == 0) {
          return tempDist;
        }
        miniDist = math.min(miniDist, tempDist);
      } else {
        for (int i = range.$1; i <= range.$2; ++i) {
          final tempDist = pointToPolygonDistance(points[i], polygon, ruler);
          miniDist = math.min(miniDist, tempDist);
          if (miniDist == 0.0) {
            return 0.0;
          }
        }
      }
    } else {
      final newRangesA = splitRange(range, isLine);
      updateQueue(
        distQueue,
        miniDist,
        ruler,
        points,
        polyBBox,
        newRangesA.$1,
      );
      updateQueue(
        distQueue,
        miniDist,
        ruler,
        points,
        polyBBox,
        newRangesA.$2,
      );
    }
  }

  return miniDist;
}
