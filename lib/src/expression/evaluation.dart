import 'package:geojson_vi/geojson_vi.dart';
import 'package:maplibre_style_spec/src/expression/expression.dart';
import 'package:maplibre_style_spec/src/types/locale.dart';

typedef ICanonicalTileID = ({num z, num x, num y, String key});

class EvaluationContext {
  EvaluationContext({
    this.id,
    required this.geometryType,
    required this.zoom,
    required this.locale,
    this.lineProgress,
    this.feature,
    this.canonical,
    Map<String, Expression>? bindings,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? featureState,
  })  : _bindings = bindings ?? {},
        _properties = properties ?? {},
        _featureState = featureState ?? {};

  static EvaluationContext empty() {
    return EvaluationContext(
      geometryType: 'Point',
      locale: Locale(languageCode: 'en'),
      zoom: 0,
    );
  }

  final String? id;
  final String geometryType;
  final double? lineProgress;
  final double zoom;
  final Locale locale;
  final Map<String, Expression> _bindings;
  final Map<String, dynamic> _properties;
  final Map<String, dynamic> _featureState;
  final GeoJSON? feature;
  final ICanonicalTileID? canonical;

  Map<String, dynamic> get properties => _properties;

  EvaluationContext extendWith({
    Map<String, Expression>? bindings,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? featureState,
  }) {
    return EvaluationContext(
      id: id,
      geometryType: geometryType,
      lineProgress: lineProgress,
      locale: locale,
      zoom: zoom,
      bindings: {..._bindings, ...?bindings},
      properties: {..._properties, ...?properties},
      featureState: {..._featureState, ...?featureState},
    );
  }

  EvaluationContext copyWith({
    String? id,
    String? geometryType,
    double? lineProgress,
    double? zoom,
    Locale? locale,
    Map<String, Expression>? bindings,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? featureState,
  }) {
    return EvaluationContext(
      id: id ?? this.id,
      geometryType: geometryType ?? this.geometryType,
      lineProgress: lineProgress ?? this.lineProgress,
      locale: locale ?? this.locale,
      zoom: zoom ?? this.zoom,
      bindings: bindings ?? _bindings,
      properties: properties ?? _properties,
      featureState: featureState ?? _featureState,
    );
  }

  Expression? getBinding(String name) {
    return _bindings[name];
  }

  dynamic getProperty(String name) {
    return _properties[name];
  }

  dynamic getFeatureState(String name) {
    return _featureState[name];
  }

  bool hasProperty(String name) {
    return _properties.containsKey(name);
  }
}
