// class TinyQueue<T> {
//   final List<T> data;
//   int length;
//   final Comparator<T> compare;

//   TinyQueue([Iterable<T>? data, Comparator<T>? compare])
//       : data = data?.toList() ?? [],
//         length = data?.length ?? 0,
//         compare = compare ?? ((a, b) => (a as Comparable).compareTo(b)) {
//     if (length > 0) {
//       for (var i = (length >> 1) - 1; i >= 0; i--) {
//         _down(i);
//       }
//     }
//   }

//   bool get isEmpty => length == 0;
//   bool get isNotEmpty => length > 0;

//   push(T item) {
//     data.add(item);
//     _up(length++);
//   }

//   T pop() {
//     final top = data.first;
//     final bottom = data.removeLast();

//     if (--length > 0) {
//       data[0] = bottom;
//       _down(0);
//     }

//     return top;
//   }

//   T peek() => data.first;

//   _up(int pos) {
//     final item = data[pos];
//     while (pos > 0) {
//       final parent = (pos - 1) >> 1;
//       final current = data[parent];
//       if (compare(item, current) >= 0) break;
//       data[pos] = current;
//       pos = parent;
//     }
//     data[pos] = item;
//   }

//   _down(int pos) {
//     final halfLength = length >> 1;
//     final item = data[pos];

//     while (pos < halfLength) {
//       int bestChild = (pos << 1) + 1;
//       final right = bestChild + 1;

//       if (right < length && compare(data[right], data[bestChild]) < 0) {
//         bestChild = right;
//       }
//       if (compare(data[bestChild], item) >= 0) break;

//       data[pos] = data[bestChild];
//       pos = bestChild;
//     }

//     data[pos] = item;
//   }
// }
