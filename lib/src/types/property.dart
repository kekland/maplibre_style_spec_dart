// ignore_for_file: null_check_on_nullable_type_parameter

import 'package:equatable/equatable.dart';
import 'package:maplibre_style_spec/src/_src.dart';

T? _parseJsonForKnownTypes<T>(dynamic json) {
  if (json is T) {
    return json;
  } else if ((T == List<num>) && json is List) {
    return json.cast<num>() as T;
  } else if ((T == List<String>) && json is List) {
    return json.cast<String>() as T;
  } else if (T == Color && json is String) {
    return Color.fromJson(json) as T;
  } else if (T == Formatted && json is String) {
    return Formatted.fromJson(json) as T;
  } else if (T == Padding && json is List<num>) {
    return Padding.fromJson(json) as T;
  } else if (T == ResolvedImage) {
    return ResolvedImage.fromJson(json) as T;
  } else if (T == Sprite && (json is String || json is List)) {
    return Sprite.fromJson(json) as T;
  } else if (T == VariableAnchorOffsetCollection) {
    return VariableAnchorOffsetCollection.fromJson(json) as T;
  } else if (isTypeEnum<T>() && json is String) {
    return parseEnumJson<T>(json);
  } else {
    return null;
  }
}

abstract class Property<T> with EquatableMixin {
  const Property({
    required this.isExpression,
    this.value,
    this.expression,
    this.defaultValue,
  });

  const Property.value(this.value, {this.defaultValue})
      : expression = null,
        isExpression = false;

  const Property.expression(this.expression, {this.defaultValue})
      : value = null,
        isExpression = true;

  final T? value;
  final Expression<T>? expression;
  final T? defaultValue;

  final bool isExpression;

  T evaluate(EvaluationContext context) {
    if (isExpression) {
      try {
        return expression!.evaluate(context);
      } catch (e) {
        print('Error evaluating expression: $e. Using default value: $defaultValue');
        return defaultValue!;
      }
    } else {
      return value!;
    }
  }

  @override
  List<Object?> get props => [value, expression, defaultValue];

  @override
  bool get stringify => true;
}

class ConstantProperty<T> extends Property<T> {
  const ConstantProperty.value(T super.value, {super.defaultValue}) : super.value();

  factory ConstantProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<T>(json);
    if (value != null) return ConstantProperty.value(value);

    throw UnimplementedError();
  }

  ConstantProperty<T> withDefaultValue(T? defaultValue) {
    return ConstantProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
  }
}

class DataDrivenProperty<T> extends Property<T> {
  const DataDrivenProperty.value(T super.value, {super.defaultValue}) : super.value();
  const DataDrivenProperty.expression(Expression<T> super.expression, {super.defaultValue}) : super.expression();

  factory DataDrivenProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<T>(json);
    if (value != null) return DataDrivenProperty.value(value);

    return DataDrivenProperty.expression(Expression<T>.fromJson(json));
  }

  DataDrivenProperty<T> withDefaultValue(T? defaultValue) {
    if (isExpression) {
      return DataDrivenProperty.expression(expression!, defaultValue: defaultValue ?? this.defaultValue);
    } else {
      return DataDrivenProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
    }
  }
}

class CrossFadedProperty<T> extends Property<T> {
  const CrossFadedProperty.value(T super.value, {super.defaultValue}) : super.value();
  const CrossFadedProperty.expression(Expression<T> super.expression, {super.defaultValue}) : super.expression();

  factory CrossFadedProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<T>(json);
    if (value != null) return CrossFadedProperty.value(value);

    return CrossFadedProperty.expression(Expression<T>.fromJson(json));
  }

  CrossFadedProperty<T> withDefaultValue(T? defaultValue) {
    if (isExpression) {
      return CrossFadedProperty.expression(expression!, defaultValue: defaultValue ?? this.defaultValue);
    } else {
      return CrossFadedProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
    }
  }
}

class DataConstantProperty<T> extends Property<T> {
  const DataConstantProperty.value(T super.value, {super.defaultValue}) : super.value();
  const DataConstantProperty.expression(Expression<T> super.expression, {super.defaultValue}) : super.expression();

  factory DataConstantProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<T>(json);
    if (value != null) return DataConstantProperty.value(value);

    return DataConstantProperty.expression(Expression<T>.fromJson(json));
  }

  DataConstantProperty<T> withDefaultValue(T? defaultValue) {
    if (isExpression) {
      return DataConstantProperty.expression(expression!, defaultValue: defaultValue ?? this.defaultValue);
    } else {
      return DataConstantProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
    }
  }
}

class ColorRampProperty extends Property<Color> {
  const ColorRampProperty.value(Color super.value, {super.defaultValue}) : super.value();
  const ColorRampProperty.expression(Expression<Color> super.expression, {super.defaultValue}) : super.expression();

  factory ColorRampProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<Color>(json);
    if (value != null) return ColorRampProperty.value(value);

    return ColorRampProperty.expression(Expression<Color>.fromJson(json));
  }

  ColorRampProperty withDefaultValue(Color? defaultValue) {
    if (isExpression) {
      return ColorRampProperty.expression(expression!, defaultValue: defaultValue ?? this.defaultValue);
    } else {
      return ColorRampProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
    }
  }
}

class CrossFadedDataDrivenProperty<T> extends Property<T> {
  const CrossFadedDataDrivenProperty.value(T super.value, {super.defaultValue}) : super.value();
  const CrossFadedDataDrivenProperty.expression(Expression<T> super.expression, {super.defaultValue})
      : super.expression();

  factory CrossFadedDataDrivenProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<T>(json);
    if (value != null) return CrossFadedDataDrivenProperty.value(value);

    return CrossFadedDataDrivenProperty.expression(Expression<T>.fromJson(json));
  }

  CrossFadedDataDrivenProperty<T> withDefaultValue(T? defaultValue) {
    if (isExpression) {
      return CrossFadedDataDrivenProperty.expression(expression!, defaultValue: defaultValue ?? this.defaultValue);
    } else {
      return CrossFadedDataDrivenProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
    }
  }
}
