import 'dart:math';

const num re = 6378.137; // equatorial radius
const num fe = 1 / 298.257223563; // flattening

const num e2 = fe * (2 - fe);
const num rad = pi / 180;

class CheapRuler {
  late num kx;
  late num ky;

  CheapRuler(num lat) {
    // Curvature formulas from https://en.wikipedia.org/wiki/Earth_radius#Meridional
    final num m = rad * re * 1000;
    final num coslat = cos(lat * rad);
    final num w2 = 1 / (1 - e2 * (1 - coslat * coslat));
    final num w = sqrt(w2);

    // multipliers for converting longitude and latitude degrees into distance
    kx = m * w * coslat; // based on normal radius of curvature
    ky = m * w * w2 * (1 - e2); // based on meridional radius of curvature
  }

  /// Given two points of the form [longitude, latitude], returns the distance.
  ///
  /// @param a - point [longitude, latitude]
  /// @param b - point [longitude, latitude]
  /// @returns distance
  /// @example
  /// final distance = ruler.distance([30.5, 50.5], [30.51, 50.49]);
  num distance(List<num> a, List<num> b) {
    final num dx = wrap(a[0] - b[0]) * kx;
    final num dy = (a[1] - b[1]) * ky;
    return sqrt(dx * dx + dy * dy);
  }

  /// Returns a map of the form {point, index, t}, where point is closest point on the line
  /// from the given point, index is the start index of the segment with the closest point,
  /// and t is a parameter from 0 to 1 that indicates where the closest point is on that segment.
  ///
  /// @param line - an array of points that form the line
  /// @param p - point [longitude, latitude]
  /// @returns the nearest point, its index in the array and the proportion along the line
  /// @example
  /// final point = ruler.pointOnLine(line, [-67.04, 50.5])['point'];
  pointOnLine(List<List<num>> line, List<num> p) {
    num minDist = double.infinity;
    num? minX, minY;
    int? minI;
    num? minT;

    for (int i = 0; i < line.length - 1; i++) {
      num x = line[i][0];
      num y = line[i][1];
      num dx = wrap(line[i + 1][0] - x) * kx;
      num dy = (line[i + 1][1] - y) * ky;
      num t = 0;

      if (dx != 0 || dy != 0) {
        t = (wrap(p[0] - x) * kx * dx + (p[1] - y) * ky * dy) / (dx * dx + dy * dy);

        if (t > 1) {
          x = line[i + 1][0];
          y = line[i + 1][1];
        } else if (t > 0) {
          x += (dx / kx) * t;
          y += (dy / ky) * t;
        }
      }

      dx = wrap(p[0] - x) * kx;
      dy = (p[1] - y) * ky;

      final num sqDist = dx * dx + dy * dy;
      if (sqDist < minDist) {
        minDist = sqDist;
        minX = x;
        minY = y;
        minI = i;
        minT = t;
      }
    }

    return (
      point: [minX, minY],
      index: minI,
      t: max(0, min(1, minT ?? 0)),
    );
  }

  num wrap(num deg) {
    while (deg < -180) {
      deg += 360;
    }
    while (deg > 180) {
      deg -= 360;
    }
    return deg;
  }
}
