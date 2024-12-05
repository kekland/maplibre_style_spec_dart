// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated by tool/tilejson/generate_style_code.js

// ignore_for_file: camel_case_types, unused_import

import 'package:equatable/equatable.dart';
import 'package:maplibre_style_spec/src/_src.dart';

sealed class $TileJson {
  const $TileJson();

  String get tilejson;

  List<String> get tiles;

  String? get attribution;

  String? get version;

  factory $TileJson.fromJson(Map<String, dynamic> json) {
    final tilejson = json['tilejson'] as String;

    return switch (tilejson) {
      '1.0.0' => $TileJson_1_0_0.fromJson(json),
      '2.0.0' => $TileJson_2_0_0.fromJson(json),
      '2.0.1' => $TileJson_2_0_1.fromJson(json),
      '2.1.0' => $TileJson_2_1_0.fromJson(json),
      '2.2.0' => $TileJson_2_2_0.fromJson(json),
      '3.0.0' => $TileJson_3_0_0.fromJson(json),
      _ => throw ArgumentError('Unknown TileJSON version: $tilejson'),
    };
  }
}

class $TileJson_1_0_0 extends $TileJson with EquatableMixin {
  const $TileJson_1_0_0({
    required this.tilejson,
    this.name,
    this.description,
    this.version,
    this.attribution,
    this.formatter,
    this.legend,
    this.scheme,
    required this.tiles,
    this.grids,
    this.minzoom,
    this.maxzoom,
    this.bounds,
    this.center,
  });

  factory $TileJson_1_0_0.fromJson(Map<String, dynamic> json) {
    final tilejson = json['tilejson'] as String;
    final name = json['name'] != null? json['name'] as String : null;
    final description = json['description'] != null? json['description'] as String : null;
    final version = json['version'] != null? json['version'] as String : null;
    final attribution = json['attribution'] != null? json['attribution'] as String : null;
    final formatter = json['formatter'] != null? json['formatter'] as String : null;
    final legend = json['legend'] != null? json['legend'] as String : null;
    final scheme = json['scheme'] != null? json['scheme'] as String : null;
    final tiles = (json['tiles'] as List).cast<String>();
    final grids = json['grids'] != null? (json['grids'] as List).cast<String>() : null;
    final minzoom = json['minzoom'] != null? json['minzoom'] as int : null;
    if (minzoom != null && !(minzoom >= 0 && minzoom <= 22)) {
      throw ArgumentError('minzoom is not valid');
    }
  
    final maxzoom = json['maxzoom'] != null? json['maxzoom'] as int : null;
    if (maxzoom != null && !(maxzoom >= 0 && maxzoom <= 22)) {
      throw ArgumentError('maxzoom is not valid');
    }
  
    final bounds = json['bounds'] != null? (json['bounds'] as List).cast<num>() : null;
    final center = json['center'] != null? (json['center'] as List).cast<num>() : null;
  
    return $TileJson_1_0_0(
      tilejson: tilejson,
      name: name,
      description: description,
      version: version,
      attribution: attribution,
      formatter: formatter,
      legend: legend,
      scheme: scheme,
      tiles: tiles,
      grids: grids,
      minzoom: minzoom,
      maxzoom: maxzoom,
      bounds: bounds,
      center: center,
    );
  }

  
  @override
  final String tilejson;
  final String? name;
  final String? description;
  
  @override
  final String? version;
  
  @override
  final String? attribution;
  final String? formatter;
  final String? legend;
  final String? scheme;
  
  @override
  final List<String> tiles;
  final List<String>? grids;
  final int? minzoom;
  final int? maxzoom;
  final List<num>? bounds;
  final List<num>? center;

  @override
  List<Object?> get props => [
    tilejson,
    name,
    description,
    version,
    attribution,
    formatter,
    legend,
    scheme,
    tiles,
    grids,
    minzoom,
    maxzoom,
    bounds,
    center,
  ];
  
  @override
  bool get stringify => true;
}

class $TileJson_2_0_0 extends $TileJson with EquatableMixin {
  const $TileJson_2_0_0({
    required this.tilejson,
    this.name,
    this.description,
    this.version,
    this.attribution,
    this.template,
    this.legend,
    this.scheme,
    required this.tiles,
    this.grids,
    this.minzoom,
    this.maxzoom,
    this.bounds,
    this.center,
  });

  factory $TileJson_2_0_0.fromJson(Map<String, dynamic> json) {
    final tilejson = json['tilejson'] as String;
    final name = json['name'] != null? json['name'] as String : null;
    final description = json['description'] != null? json['description'] as String : null;
    final version = json['version'] != null? json['version'] as String : null;
    final attribution = json['attribution'] != null? json['attribution'] as String : null;
    final template = json['template'] != null? json['template'] as String : null;
    final legend = json['legend'] != null? json['legend'] as String : null;
    final scheme = json['scheme'] != null? json['scheme'] as String : null;
    final tiles = (json['tiles'] as List).cast<String>();
    final grids = json['grids'] != null? (json['grids'] as List).cast<String>() : null;
    final minzoom = json['minzoom'] != null? json['minzoom'] as int : null;
    if (minzoom != null && !(minzoom >= 0 && minzoom <= 22)) {
      throw ArgumentError('minzoom is not valid');
    }
  
    final maxzoom = json['maxzoom'] != null? json['maxzoom'] as int : null;
    if (maxzoom != null && !(maxzoom >= 0 && maxzoom <= 22)) {
      throw ArgumentError('maxzoom is not valid');
    }
  
    final bounds = json['bounds'] != null? (json['bounds'] as List).cast<num>() : null;
    final center = json['center'] != null? (json['center'] as List).cast<num>() : null;
  
    return $TileJson_2_0_0(
      tilejson: tilejson,
      name: name,
      description: description,
      version: version,
      attribution: attribution,
      template: template,
      legend: legend,
      scheme: scheme,
      tiles: tiles,
      grids: grids,
      minzoom: minzoom,
      maxzoom: maxzoom,
      bounds: bounds,
      center: center,
    );
  }

  
  @override
  final String tilejson;
  final String? name;
  final String? description;
  
  @override
  final String? version;
  
  @override
  final String? attribution;
  final String? template;
  final String? legend;
  final String? scheme;
  
  @override
  final List<String> tiles;
  final List<String>? grids;
  final int? minzoom;
  final int? maxzoom;
  final List<num>? bounds;
  final List<num>? center;

  @override
  List<Object?> get props => [
    tilejson,
    name,
    description,
    version,
    attribution,
    template,
    legend,
    scheme,
    tiles,
    grids,
    minzoom,
    maxzoom,
    bounds,
    center,
  ];
  
  @override
  bool get stringify => true;
}

class $TileJson_2_0_1 extends $TileJson with EquatableMixin {
  const $TileJson_2_0_1({
    required this.tilejson,
    this.name,
    this.description,
    this.version,
    this.attribution,
    this.template,
    this.legend,
    this.scheme,
    required this.tiles,
    this.grids,
    this.resolution,
    this.minzoom,
    this.maxzoom,
    this.bounds,
    this.center,
  });

  factory $TileJson_2_0_1.fromJson(Map<String, dynamic> json) {
    final tilejson = json['tilejson'] as String;
    final name = json['name'] != null? json['name'] as String : null;
    final description = json['description'] != null? json['description'] as String : null;
    final version = json['version'] != null? json['version'] as String : null;
    final attribution = json['attribution'] != null? json['attribution'] as String : null;
    final template = json['template'] != null? json['template'] as String : null;
    final legend = json['legend'] != null? json['legend'] as String : null;
    final scheme = json['scheme'] != null? json['scheme'] as String : null;
    final tiles = (json['tiles'] as List).cast<String>();
    final grids = json['grids'] != null? (json['grids'] as List).cast<String>() : null;
    final resolution = json['resolution'] != null? json['resolution'] as int : null;
    final minzoom = json['minzoom'] != null? json['minzoom'] as int : null;
    if (minzoom != null && !(minzoom >= 0 && minzoom <= 22)) {
      throw ArgumentError('minzoom is not valid');
    }
  
    final maxzoom = json['maxzoom'] != null? json['maxzoom'] as int : null;
    if (maxzoom != null && !(maxzoom >= 0 && maxzoom <= 22)) {
      throw ArgumentError('maxzoom is not valid');
    }
  
    final bounds = json['bounds'] != null? (json['bounds'] as List).cast<num>() : null;
    final center = json['center'] != null? (json['center'] as List).cast<num>() : null;
  
    return $TileJson_2_0_1(
      tilejson: tilejson,
      name: name,
      description: description,
      version: version,
      attribution: attribution,
      template: template,
      legend: legend,
      scheme: scheme,
      tiles: tiles,
      grids: grids,
      resolution: resolution,
      minzoom: minzoom,
      maxzoom: maxzoom,
      bounds: bounds,
      center: center,
    );
  }

  
  @override
  final String tilejson;
  final String? name;
  final String? description;
  
  @override
  final String? version;
  
  @override
  final String? attribution;
  final String? template;
  final String? legend;
  final String? scheme;
  
  @override
  final List<String> tiles;
  final List<String>? grids;
  final int? resolution;
  final int? minzoom;
  final int? maxzoom;
  final List<num>? bounds;
  final List<num>? center;

  @override
  List<Object?> get props => [
    tilejson,
    name,
    description,
    version,
    attribution,
    template,
    legend,
    scheme,
    tiles,
    grids,
    resolution,
    minzoom,
    maxzoom,
    bounds,
    center,
  ];
  
  @override
  bool get stringify => true;
}

class $TileJson_2_1_0 extends $TileJson with EquatableMixin {
  const $TileJson_2_1_0({
    required this.tilejson,
    this.name,
    this.description,
    this.version,
    this.attribution,
    this.template,
    this.legend,
    this.scheme,
    required this.tiles,
    this.grids,
    this.data,
    this.minzoom,
    this.maxzoom,
    this.bounds,
    this.center,
  });

  factory $TileJson_2_1_0.fromJson(Map<String, dynamic> json) {
    final tilejson = json['tilejson'] as String;
    final name = json['name'] != null? json['name'] as String : null;
    final description = json['description'] != null? json['description'] as String : null;
    final version = json['version'] != null? json['version'] as String : null;
    final attribution = json['attribution'] != null? json['attribution'] as String : null;
    final template = json['template'] != null? json['template'] as String : null;
    final legend = json['legend'] != null? json['legend'] as String : null;
    final scheme = json['scheme'] != null? json['scheme'] as String : null;
    final tiles = (json['tiles'] as List).cast<String>();
    final grids = json['grids'] != null? (json['grids'] as List).cast<String>() : null;
    final data = json['data'] != null? (json['data'] as List).cast<String>() : null;
    final minzoom = json['minzoom'] != null? json['minzoom'] as int : null;
    if (minzoom != null && !(minzoom >= 0 && minzoom <= 22)) {
      throw ArgumentError('minzoom is not valid');
    }
  
    final maxzoom = json['maxzoom'] != null? json['maxzoom'] as int : null;
    if (maxzoom != null && !(maxzoom >= 0 && maxzoom <= 22)) {
      throw ArgumentError('maxzoom is not valid');
    }
  
    final bounds = json['bounds'] != null? (json['bounds'] as List).cast<num>() : null;
    final center = json['center'] != null? (json['center'] as List).cast<num>() : null;
  
    return $TileJson_2_1_0(
      tilejson: tilejson,
      name: name,
      description: description,
      version: version,
      attribution: attribution,
      template: template,
      legend: legend,
      scheme: scheme,
      tiles: tiles,
      grids: grids,
      data: data,
      minzoom: minzoom,
      maxzoom: maxzoom,
      bounds: bounds,
      center: center,
    );
  }

  
  @override
  final String tilejson;
  final String? name;
  final String? description;
  
  @override
  final String? version;
  
  @override
  final String? attribution;
  final String? template;
  final String? legend;
  final String? scheme;
  
  @override
  final List<String> tiles;
  final List<String>? grids;
  final List<String>? data;
  final int? minzoom;
  final int? maxzoom;
  final List<num>? bounds;
  final List<num>? center;

  @override
  List<Object?> get props => [
    tilejson,
    name,
    description,
    version,
    attribution,
    template,
    legend,
    scheme,
    tiles,
    grids,
    data,
    minzoom,
    maxzoom,
    bounds,
    center,
  ];
  
  @override
  bool get stringify => true;
}

class $TileJson_2_2_0 extends $TileJson with EquatableMixin {
  const $TileJson_2_2_0({
    required this.tilejson,
    this.name,
    this.description,
    this.version,
    this.attribution,
    this.template,
    this.legend,
    this.scheme,
    required this.tiles,
    this.grids,
    this.data,
    this.minzoom,
    this.maxzoom,
    this.bounds,
    this.center,
  });

  factory $TileJson_2_2_0.fromJson(Map<String, dynamic> json) {
    final tilejson = json['tilejson'] as String;
    final name = json['name'] != null? json['name'] as String : null;
    final description = json['description'] != null? json['description'] as String : null;
    final version = json['version'] != null? json['version'] as String : null;
    final attribution = json['attribution'] != null? json['attribution'] as String : null;
    final template = json['template'] != null? json['template'] as String : null;
    final legend = json['legend'] != null? json['legend'] as String : null;
    final scheme = json['scheme'] != null? json['scheme'] as String : null;
    final tiles = (json['tiles'] as List).cast<String>();
    final grids = json['grids'] != null? (json['grids'] as List).cast<String>() : null;
    final data = json['data'] != null? (json['data'] as List).cast<String>() : null;
    final minzoom = json['minzoom'] != null? json['minzoom'] as int : null;
    if (minzoom != null && !(minzoom >= 0 && minzoom <= 30)) {
      throw ArgumentError('minzoom is not valid');
    }
  
    final maxzoom = json['maxzoom'] != null? json['maxzoom'] as int : null;
    if (maxzoom != null && !(maxzoom >= 0 && maxzoom <= 30)) {
      throw ArgumentError('maxzoom is not valid');
    }
  
    final bounds = json['bounds'] != null? (json['bounds'] as List).cast<num>() : null;
    final center = json['center'] != null? (json['center'] as List).cast<num>() : null;
  
    return $TileJson_2_2_0(
      tilejson: tilejson,
      name: name,
      description: description,
      version: version,
      attribution: attribution,
      template: template,
      legend: legend,
      scheme: scheme,
      tiles: tiles,
      grids: grids,
      data: data,
      minzoom: minzoom,
      maxzoom: maxzoom,
      bounds: bounds,
      center: center,
    );
  }

  
  @override
  final String tilejson;
  final String? name;
  final String? description;
  
  @override
  final String? version;
  
  @override
  final String? attribution;
  final String? template;
  final String? legend;
  final String? scheme;
  
  @override
  final List<String> tiles;
  final List<String>? grids;
  final List<String>? data;
  final int? minzoom;
  final int? maxzoom;
  final List<num>? bounds;
  final List<num>? center;

  @override
  List<Object?> get props => [
    tilejson,
    name,
    description,
    version,
    attribution,
    template,
    legend,
    scheme,
    tiles,
    grids,
    data,
    minzoom,
    maxzoom,
    bounds,
    center,
  ];
  
  @override
  bool get stringify => true;
}

class $TileJson_3_0_0 extends $TileJson with EquatableMixin {
  const $TileJson_3_0_0({
    required this.tilejson,
    required this.tiles,
    required this.vectorLayers,
    this.attribution,
    this.bounds,
    this.center,
    this.data,
    this.description,
    this.fillzoom,
    this.grids,
    this.legend,
    this.maxzoom,
    this.minzoom,
    this.name,
    this.scheme,
    this.template,
    this.version,
  });

  factory $TileJson_3_0_0.fromJson(Map<String, dynamic> json) {
    final tilejson = json['tilejson'] as String;
    final tiles = (json['tiles'] as List).cast<String>();
    final vectorLayers = (json['vector_layers'] as List).cast<Object>();
    final attribution = json['attribution'] != null? json['attribution'] as String : null;
    final bounds = json['bounds'] != null? (json['bounds'] as List).cast<num>() : null;
    final center = json['center'] != null? (json['center'] as List).cast<num>() : null;
    final data = json['data'] != null? (json['data'] as List).cast<String>() : null;
    final description = json['description'] != null? json['description'] as String : null;
    final fillzoom = json['fillzoom'] != null? json['fillzoom'] as int : null;
    if (fillzoom != null && !(fillzoom >= 0 && fillzoom <= 30)) {
      throw ArgumentError('fillzoom is not valid');
    }
  
    final grids = json['grids'] != null? (json['grids'] as List).cast<String>() : null;
    final legend = json['legend'] != null? json['legend'] as String : null;
    final maxzoom = json['maxzoom'] != null? json['maxzoom'] as int : null;
    if (maxzoom != null && !(maxzoom >= 0 && maxzoom <= 30)) {
      throw ArgumentError('maxzoom is not valid');
    }
  
    final minzoom = json['minzoom'] != null? json['minzoom'] as int : null;
    if (minzoom != null && !(minzoom >= 0 && minzoom <= 30)) {
      throw ArgumentError('minzoom is not valid');
    }
  
    final name = json['name'] != null? json['name'] as String : null;
    final scheme = json['scheme'] != null? json['scheme'] as String : null;
    final template = json['template'] != null? json['template'] as String : null;
    final version = json['version'] != null? json['version'] as String : null;
  
    return $TileJson_3_0_0(
      tilejson: tilejson,
      tiles: tiles,
      vectorLayers: vectorLayers,
      attribution: attribution,
      bounds: bounds,
      center: center,
      data: data,
      description: description,
      fillzoom: fillzoom,
      grids: grids,
      legend: legend,
      maxzoom: maxzoom,
      minzoom: minzoom,
      name: name,
      scheme: scheme,
      template: template,
      version: version,
    );
  }

  
  @override
  final String tilejson;
  
  @override
  final List<String> tiles;
  final List<Object> vectorLayers;
  
  @override
  final String? attribution;
  final List<num>? bounds;
  final List<num>? center;
  final List<String>? data;
  final String? description;
  final int? fillzoom;
  final List<String>? grids;
  final String? legend;
  final int? maxzoom;
  final int? minzoom;
  final String? name;
  final String? scheme;
  final String? template;
  
  @override
  final String? version;

  @override
  List<Object?> get props => [
    tilejson,
    tiles,
    vectorLayers,
    attribution,
    bounds,
    center,
    data,
    description,
    fillzoom,
    grids,
    legend,
    maxzoom,
    minzoom,
    name,
    scheme,
    template,
    version,
  ];
  
  @override
  bool get stringify => true;
}
