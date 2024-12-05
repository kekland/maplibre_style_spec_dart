import 'package:equatable/equatable.dart';
import 'package:maplibre_style_spec/src/_src.dart';

class TileJson with EquatableMixin {
  const TileJson(this.value);

  factory TileJson.fromJson(Map<String, dynamic> json) {
    return TileJson($TileJson.fromJson(json));
  }

  final $TileJson value;

  String get tilejson => value.tilejson;
  List<String> get tiles => value.tiles;
  String? get attribution => value.attribution;
  String? get version => value.version;
  
  @override
  List<Object?> get props => [value];

  @override
  bool get stringify => true;
}
