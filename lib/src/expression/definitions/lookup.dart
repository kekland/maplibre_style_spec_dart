import 'package:maplibre_style_spec/src/_src.dart';
import 'package:maplibre_style_spec/src/expression/generator/annotations.dart';

@ExpressionAnnotation('AtExpression', rawName: 'at')
dynamic atExpressionImpl(
  EvaluationContext context,
  Expression<int> index,
  Expression<List> array,
) {
  final _index = index(context);
  final _array = array(context);

  if (_index < 0 || _index >= _array.length) {
    throw Exception('Index $_index is out of bounds');
  }

  return _array[_index];
}

@ExpressionAnnotation('InExpression', rawName: 'in')
dynamic inExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> needle,
  Expression<dynamic> haystack,
) {
  final _needle = needle(context);
  final _haystack = haystack(context);

  if (_haystack is List) {
    return _haystack.contains(_needle);
  }
  if (_haystack is String) {
    return _haystack.contains(_needle);
  }

  throw Exception('Unsupported type ${_haystack.runtimeType} for "in" operator');
}

@ExpressionAnnotation('IndexOfExpression', rawName: 'index-of')
dynamic indexOfExpression(
  EvaluationContext context,
  Expression<dynamic> needle,
  Expression<dynamic> haystack,
) {
  final _needle = needle(context);
  final _haystack = haystack(context);

  if (_haystack is List) {
    return _haystack.indexOf(_needle);
  }
  if (_haystack is String) {
    return _haystack.indexOf(_needle);
  }

  throw Exception('Unsupported type ${_haystack.runtimeType} for "indexOf" operator');
}

@ExpressionAnnotation('SliceExpression', rawName: 'slice')
dynamic sliceExpression(
  EvaluationContext context,
  Expression<dynamic> input,
  Expression<int> start,
  Expression<int>? end,
) {
  final _input = input(context);
  final _start = start(context);
  final _end = end?.evaluate(context);

  if (_start < 0 || _start >= _input.length) {
    throw Exception('Start index $_start is out of bounds');
  }

  if (_end != null && (_end < 0 || _end >= _input.length)) {
    throw Exception('End index $_end is out of bounds');
  }

  if (_input is List) {
    return _input.sublist(_start, _end);
  }

  if (_input is String) {
    return _input.substring(_start, _end);
  }

  throw Exception('Unsupported type ${_input.runtimeType} for "slice" operator');
}

@ExpressionAnnotation('GetExpression', rawName: 'get')
T getExpressionImpl<T>(
  EvaluationContext context,
  Expression<String> key,
  Expression<Map<String, dynamic>>? object,
) {
  final _key = key(context);
  final _object = object?.evaluate(context);

  if (_object != null) {
    final _value = _object[_key];

    if (_value is Expression) {
      return _value(context);
    }

    return _value;
  }

  return context.getProperty(_key);
}

@ExpressionAnnotation('HasExpression', rawName: 'has')
bool hasExpressionImpl(
  EvaluationContext context,
  Expression<String> key,
  Expression<Map<String, dynamic>>? object,
) {
  final _key = key(context);
  final _object = object?.evaluate(context);

  if (_object != null) {
    return _object.containsKey(_key);
  }

  return context.hasProperty(_key);
}

@ExpressionAnnotation('LengthExpression', rawName: 'length')
int lengthExpressionImpl(
  EvaluationContext context,
  Expression<dynamic> value,
) {
  final _value = value(context);

  if (_value is List) {
    return _value.length;
  }

  if (_value is String) {
    return _value.length;
  }

  throw Exception('Unsupported type ${_value.runtimeType} for "length" operator');
}
