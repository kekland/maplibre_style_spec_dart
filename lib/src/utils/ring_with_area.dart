class RingWithArea<T extends List<num>> {
  num? area;
  late List<T> _val;

  T operator [](int index) {
    return _val[index];
  }

  List<T> getValue() {
    return _val;
  }

  RingWithArea(this.area, List<T> val) {
    this._val = val;
  }
}
